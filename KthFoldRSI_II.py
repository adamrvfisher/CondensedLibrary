# -*- coding: utf-8 -*-
"""

@author: Adam Reinhold Von Fisher - https://www.linkedin.com/in/adamrvfisher/

"""

#This is a Kth fold optimization using RSI indicator as a signal

#Import modules
from KthFoldRSIParamGenerator import KthFoldRSIParamGenerator
from KthFoldRSIParamTester import KthFoldRSIParamTester
from KthFoldRSIFinalParamTester import KthFoldRSIFinalParamTester
from KthFoldRSIDecisionOptimizer import KthFoldRSIDecisionOptimizer
from YahooGrabber import YahooGrabber
import numpy as np
import pandas as pd
from pandas.parser import CParserError
import itertools as it
import math
#from YahooSourceDailyGrabber import YahooSourceDailyGrabber

#Variable assignment
DataSetNames = [] 
ParameterSets = []
TestSetNames = []
TestParameterSets = []
TestParamsLength = []
FinalParameterSet = pd.DataFrame()
TotalFinalParams = 200
#Input ticker
ticker = 'GLD'
#Input number of iterations for brute force optimization
NumIterations = 15000
#Input K folds
k = 3
#K range
kRange = range(0,k)

#Condensed data from Database 
#Asset = YahooSourceDailyGrabber(ticker)
#Asset = Asset[-1500:]
#Asset = Asset[['Open', 'High', 'Low', 'Close', 'Adj Close']]

#Request data
while True:
    try:
        Asset = YahooGrabber(ticker)
    except CParserError:
        continue
    break

Asset = Asset[-1500:]

#Split data into K non-overlapping sections
DataSetList = np.array_split(Asset, k)

#Generate data set, parameter set, and test set names
for i in kRange:
    DataSetNames.append(str('DataSet'+ str(i)))
    ParameterSets.append('DS' + str(i) + 'Params' )
    TestSetNames.append(str('TestSet'+ str(i)))
    TestParameterSets.append('TS' + str(i) + 'Params')
#Assign datasets to their respective variables
for ii in DataSetNames:
    globals()[ii] = DataSetList[int(ii[7:])]

#Assign blank DataFrames for TestSets
for iii in TestSetNames:
    globals()[iii] = pd.DataFrame()

#Find params for each data set
for iiii in ParameterSets: 
    globals()[iiii] = KthFoldRSIParamGenerator(
                            globals()['DataSet' + iiii[2:-6]], NumIterations)
                            
#Create test sets from params
TSlist = list(it.combinations(ParameterSets, len(ParameterSets) - 1))
TSlist.reverse()

#Concatenate params to test sets
#For all TestSets to be populated by respective DataSets
for TestSet, DataSets in zip(TestSetNames, TSlist):
    for DataSet in list(DataSets):
        #Add respective DataSets to TestSet
        globals()[TestSet] = pd.concat([globals()[TestSet], globals()[DataSet]], axis = 1)
        globals()[TestSet] = globals()[TestSet].loc[:,~globals()[TestSet].columns.duplicated()]

#Pass test set params to tester, sort params
for TestParameterSet, TestSetName, DataSetName in zip(
                            TestParameterSets, TestSetNames, DataSetNames):
    globals()[TestParameterSet] = KthFoldRSIParamTester(
                                    globals()[DataSetName], globals()[TestSetName])
                                    
#Find minimum number of params in finished test sets
for t in TestParameterSets:
    TestParamsLength.append(len(globals()[t].columns))
MinParamsPerFold = min(TestParamsLength)
#Incase there are more MinParams than 200/kfolds..
MaxParamsPerFold = math.floor(TotalFinalParams/k)
if MinParamsPerFold > MaxParamsPerFold:
    MinParamsPerFold = MaxParamsPerFold

#Drop all params from post-TestParameterSets over MinParams
for t in TestParameterSets:
    globals()[t] = globals()[t].drop(globals()[t].columns[MinParamsPerFold:], axis = 1)

#Concatenate all params
for t in TestParameterSets:
    FinalParameterSet = pd.concat([FinalParameterSet, globals()[t]], axis = 1)

#Rename columns 
FinalParameterSet.columns = range(0,len(FinalParameterSet.columns))

#Sub index for dictionary making
SubIndex = range(1,len(Asset)+1)
#For every date, make a 
AssetDictionary = { s : Asset.loc[Asset.index[:s],:] for s in SubIndex}
DecisionList = []
for s in SubIndex:
    ModifiedAsset = AssetDictionary[s]
    AggregateDecision = KthFoldRSIFinalParamTester(ModifiedAsset, FinalParameterSet)
    DecisionList.append(AggregateDecision)  
    print(s)
    print(AggregateDecision)
TheDecision = pd.Series(DecisionList, index=Asset.index)
Asset['AggregateDecision'] = TheDecision

#Log return calculation
Asset['LogRet'] = np.log(Asset['Adj Close']/Asset['Adj Close'].shift(1))
Asset['LogRet'] = Asset['LogRet'].fillna(0)
#Finding optimal decision thresholds for interpretting aggregate decision making
DecisionThreshold = KthFoldRSIDecisionOptimizer(Asset, 5000)
#Determining regime
Asset['Regime'] = np.where(Asset['AggregateDecision'] > DecisionThreshold[DecisionThreshold.columns[0]][0], 1 , 0)
Asset['Regime'] = np.where(Asset['AggregateDecision'] < DecisionThreshold[DecisionThreshold.columns[0]][1], -1, Asset['Regime'])
#Apply position to log returns
Asset['Strategy'] = (Asset['LogRet'] * Asset['Regime'].shift(1))
#Returns on $1
Asset['Multiplier'] = Asset['Strategy'][:].cumsum().apply(np.exp)
Asset['Multiplier'].plot(grid=True, figsize=(8,5))