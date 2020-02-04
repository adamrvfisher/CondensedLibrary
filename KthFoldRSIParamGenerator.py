# -*- coding: utf-8 -*-
"""

@author: Adam Reinhold Von Fisher - https://www.linkedin.com/in/adamrvfisher/

"""

#This is part of a time series analysis and strategy testing tool
#Kth fold optimization using RSI indicator as a signal

def KthFoldRSIParamGenerator(Asset, NumIterations):
    #Import modules
    import numpy as np
    import random as rand
    import pandas as pd
    
    #Variable assignment
    Empty = [] #reusable list
    #Set desired number of datasets
    DataSet = pd.DataFrame()
    #Prep variable for .diff()
    ClosePrice = Asset['Adj Close']
    #Log return calculation
    Asset['LogRet'] = np.log(Asset['Adj Close']/Asset['Adj Close'].shift(1))
    Asset['LogRet'] = Asset['LogRet'].fillna(0)
    #Number of iterations for brute force optimization
    iterations = range(0, NumIterations + 1)

    #while no values in optimal params..    
    while True: 
        try:
            #For number of iterations
            for i in iterations:
                #Random RSI params
                a = rand.randint(1,30)
                b = rand.random() * 100
                c = rand.random() * 100
                if c < b:
                    continue
                d = rand.random() * 100
                e = rand.random() * 100
                if b > d:
                    continue
                if c < e:
                    continue
                #Up/Down average window
                window = a 
                #Difference in close price
                delta = ClosePrice.diff()
                #Clean data
                delta = delta[1:]
                #Up moves, down moves
                up, down = delta.copy(), delta.copy()
                up[up < 0] = 0
                down[down > 0] = 0
                #Average gain/loss
                AvgGain = up.rolling(window).mean()
                AvgGain = AvgGain.fillna(0)
                AvgLoss = down.abs().rolling(window).mean()
                AvgLoss = AvgLoss.fillna(0)
                #Relative strength calculation
                RS = AvgGain/AvgLoss
                RS = RS.fillna(0)
                #Normalization
                RSI = 100 - (100/(1.0+RS))
                #Dataframe assignment
                Asset['RSI'] = RSI
                Asset['RSI'] = Asset['RSI'].fillna(0)
                #Entry signals
                Asset['Touch'] = np.where(Asset['RSI'] < b, 1, 0) #long signal
                Asset['Touch'] = np.where(Asset['RSI'] > c, -1, Asset['Touch']) #short signal
                
                Asset['Sustain'] = np.where(Asset['Touch'].shift(1) == 1, 1, 0) 
                Asset['Sustain'] = np.where(Asset['Sustain'].shift(1) == 1, 1, 
                                                     Asset['Sustain']) 
                Asset['Sustain'] = np.where(Asset['Touch'].shift(1) == -1, -1, 0) 
                Asset['Sustain'] = np.where(Asset['Sustain'].shift(1) == -1, -1, 
                                                 Asset['Sustain']) #short
                Asset['Sustain'] = np.where(Asset['RSI'] > d, 0, Asset['Sustain']) 
                Asset['Sustain'] = np.where(Asset['RSI'] < e, 0, Asset['Sustain']) 
                #Position
                Asset['Regime'] = Asset['Touch'] + Asset['Sustain']
                Asset['Strategy'] = (Asset['Regime']).shift(1) * Asset['LogRet']
                Asset['Strategy'] = Asset['Strategy'].fillna(0)
                #For return calculation
                EndGains = 1
                EndReturns = 1
                #Return calculations
                for g in Asset['LogRet']:
                    Slate = EndReturns * (1+g)
                    EndReturns = Slate
                for q in Asset['Strategy']:
                    SlateII = EndGains * (1+q)
                    EndGains = SlateII
                #Profitability constraint
                if EndReturns > EndGains:
                    continue
                if Asset['Strategy'].std() == 0:
                    continue
                #Performance statistic
                Sharpe = (Asset['Strategy'].mean()/Asset['Strategy'].std())
                #Sharpe constraint optional
            #    if Sharpe < 0.03:
            #        continue
                #Tracking params and performance
                Empty.append(a)
                Empty.append(b)
                Empty.append(c)
                Empty.append(d)
                Empty.append(e)
                Empty.append(EndReturns)
                Empty.append(EndGains)
                Empty.append(Sharpe)
                #Save to data set
                EmptySeries = pd.Series(Empty)
                DataSet[i] = EmptySeries.values
                #Clear list for next iteration
                Empty[:] = []
        except IndexError:
            continue
        break
    
    #Sorting by performance - get performance measure for all params
    z1 = DataSet.iloc[7]
    #Take top 20% only
    w1 = np.percentile(z1, 80)
    v1 = [] #this variable stores the Nth percentile of top performers
    DSParams = pd.DataFrame() #this variable stores your params for specific dataset
    #Append if meets threshold
    for h in z1:
        if h > w1:
            v1.append(h)
    #Concatenate all params to return
    for j in v1:
        r = DataSet.columns[(DataSet == j).iloc[7]]    
        DSParams = pd.concat([DSParams,DataSet[r]], axis = 1)
    print('DataSet Finished')
    return DSParams
