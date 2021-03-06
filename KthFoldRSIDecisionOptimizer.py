# -*- coding: utf-8 -*-
"""

@author: Adam Reinhold Von Fisher - https://www.linkedin.com/in/adamrvfisher/

"""

#This is part of a time series analysis and strategy testing tool
#Kth fold optimization using RSI indicator as a signal

#Define function
def KthFoldRSIDecisionOptimizer(Asset, NumIterations):
    #Import modules
    import numpy as np
    import pandas as pd
    import time as t
    import random as rand
     
    #Number of iterations for brute force optimization
    iterations = range(0,NumIterations)
    #Variable assignments
    Empty = []
    Counter = 0
    DataSet = pd.DataFrame()
    
    start = t.time()
    for i in iterations:
        Counter = Counter + 1
        print(Counter)
        a = 1 - (rand.random() * 3)
        b = 1 - (rand.random() * 3)
        Asset['Regime'] = np.where(Asset['AggregateDecision'] > a, 1 , 0)
        Asset['Regime'] = np.where(Asset['AggregateDecision'] < b, -1, Asset['Regime'])
        Asset['Strategy'] = Asset['Regime'].shift(1)*Asset['LogRet']
        Asset['Strategy'] = Asset['Strategy'].fillna(0)
        if Asset['Strategy'].std() == 0:
            continue
        Asset['Sharpe'] = Asset['Strategy'].mean()/Asset['Strategy'].std()
        if Asset['Sharpe'][-1] < -.01:
            continue
        Asset['Multiplier'] = Asset['Strategy'].cumsum().apply(np.exp)
        Empty.append(a)
        Empty.append(b)
        #May want to optimize for max return instead of Sharpe
        Empty.append(Asset['Sharpe'][-1])
        Empty.append(Asset['Multiplier'][-1])
        emptyseries = pd.Series(Empty)
        DataSet[i] = emptyseries.values
        Empty[:] = []
    end = t.time()
    print('Optimization took',end-start,'seconds')
    z = DataSet.iloc[3]
    y = max(z)
    x = DataSet.columns[(DataSet == y).iloc[3]] #this is the column number
    return DataSet[x] #this is the dataframe index based on column number
