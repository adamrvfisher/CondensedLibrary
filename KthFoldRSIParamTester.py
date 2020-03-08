# -*- coding: utf-8 -*-
"""

@author: Adam Reinhold Von Fisher - https://www.linkedin.com/in/adamrvfisher/

"""

#This is part of a time series analysis and strategy testing tool
#Kth fold optimization using RSI indicator as a signal

def KthFoldRSIParamTester(Asset, ParameterSet):
    
    #Import modules
    import numpy as np
    import pandas as pd
    #Set desired number of datasets
    DataSet = pd.DataFrame()
    #Clean data
    ParameterSet = ParameterSet.loc[:,~ParameterSet.columns.duplicated()]
    #For all parameters in param set
    for p in ParameterSet:
        #Prep variable for .diff()
        ClosePrice = Asset['Adj Close']
        #Variable assignment
        Empty = [] #reusable list
        #Assign params
        a = ParameterSet[p].iloc[0]
        b = ParameterSet[p].iloc[1]
        c = ParameterSet[p].iloc[2]
        d = ParameterSet[p].iloc[3]
        e = ParameterSet[p].iloc[4]
        #Up/Down average window
        window = int(a) 
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
    #    if EndReturns > EndGains:
    #        continue
        if Asset['Strategy'].std() == 0:
            continue
        #Performance statistic
        Sharpe = (Asset['Strategy'].mean()/Asset['Strategy'].std())
        #Sharpe constraint optional
        if Sharpe < 0:
            continue
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
        DataSet[p] = EmptySeries.values
        #Clear list for next iteration
        Empty[:] = []
    
    #Sorting by performance - get performance measure for all params
    z1 = DataSet.iloc[7]
    #Take top 20% only
    w1 = np.percentile(z1, 80)
    v1 = [] #this variable stores the Nth percentile of top performers
    TSParams = pd.DataFrame() #this variable stores your params for specific dataset
    #Append if meets threshold
    for h in z1:
        if h > w1:
            v1.append(h)
    #Concatenate all params to return
    for j in v1:
        r = DataSet.columns[(DataSet == j).iloc[7]]    
        TSParams = pd.concat([TSParams,DataSet[r]], axis = 1)
    #Sort and reverse 
    TSParams = TSParams.T.sort_values(by = 7, ascending = False).T
    #Return params
    return TSParams
