# -*- coding: utf-8 -*-
"""

@author: Adam Reinhold Von Fisher - https://www.linkedin.com/in/adamrvfisher/

"""

#This is part of a time series analysis and strategy testing tool
#Kth fold optimization using RSI indicator as a signal

def KthFoldRSIFinalParamTester(Asset, FinalParameterSet):
    
    #import modules
    import numpy as np

    #Variable assignment
    Direction = 0
    NumParams = len(FinalParameterSet.iloc[0])    
    
    #For all params in parameter set
    for p in FinalParameterSet:
        #Prep variable for .diff()
        ClosePrice = Asset['Adj Close']
        #Assign params
        a = FinalParameterSet[p].iloc[0]
        b = FinalParameterSet[p].iloc[1]
        c = FinalParameterSet[p].iloc[2]
        d = FinalParameterSet[p].iloc[3]
        e = FinalParameterSet[p].iloc[4]
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
        #Parameter regime suggestion..
        ParameterDecision = Asset['Regime'].iloc[-1]
        #Add to aggregate decision..
        Direction = Direction + ParameterDecision
        
    AggregateDecision = Direction/NumParams
    return AggregateDecision
        
