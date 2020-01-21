# -*- coding: utf-8 -*-
"""

@author: Adam Reinhold Von Fisher - https://www.linkedin.com/in/adamrvfisher/

"""

#Entity Creation - Folder Framework

#Modify the structure and contents of the directory hierarchy to be populated by processes

#Import modules
import os 

#Assign directory location - unique to localhost
DL = "F:\\Users\\UserName\\FolderName"

#Create the folder from which everything flows.
if not os.path.exists(DL):
    os.makedirs(DL)
    
#Create and edit the primary set of folders; keep it clean
    
#This is where input data is stored
if not os.path.exists(DL + "\\DataSources"):
    os.makedirs(DL + "\\DataSources")
#This is where model output is stored
if not os.path.exists(DL + "\\ModelOutput"):
    os.makedirs(DL + "\\ModelOutput")
#This is where automated/batch files are stored
if not os.path.exists(DL + "\\BatchFiles"):
    os.makedirs(DL + "\\BatchFiles")
#This is where execution/API logs are stored
if not os.path.exists(DL + "\\ExecutionLogs"):
    os.makedirs(DL + "\\ExecutionLogs")    
    
#Create and edit a secondary set of folders within a primary folder; keep it clean

#This is the YahooSource
if not os.path.exists(DL + "\\DataSources\\YahooSource"):
    os.makedirs(DL + "\\DataSources\\YahooSource")
#This is the NASDAQSource
if not os.path.exists(DL + "\\DataSources\\NASDAQSource"):
    os.makedirs(DL + "\\NASDAQSource")
#This is the YahooSource ModelOutput
if not os.path.exists(DL + "\\ModelOutput\\YahooSource"):
    os.makedirs(DL + "\\ModelOutput\\YahooSource")
    
#Create and edit a tertiary set of folders within a secondary folder; keep it clean

#These are YahooSource subfolders
#This is populated by a CSVfetch
if not os.path.exists(DL + "\\DataSources\\YahooSource\\DividendData"):
    os.makedirs(DL + "\\DataSources\\YahooSource\\DividendData")
#This is populated by a CSVfetch
if not os.path.exists(DL + "\\FDL\\DataSources\\YahooSource\\TimeSeriesData"):
    os.makedirs(DL + "\\DataSources\\YahooSource\\TimeSeriesData")
#Concatenate dividend, time series, qualitative, and database modification
if not os.path.exists(DL + "\\DataSources\\YahooSource\\ProcessedData"):
    os.makedirs(DL + "\\DataSources\\YahooSource\\ProcessedData")

#These are NASDAQSource subfolders
#This can be populated by a concatenation and cleaning of NASDAQ data on AMEX NYSE NASDAQ listed stocks
if not os.path.exists(DL + "\\DataSources\\NASDAQSource\\QualitativeData"):
    os.makedirs(DL + "\\DataSources\\NASDAQSource\\QualitativeData")    
#This a ticker list from qualitative data
if not os.path.exists(DL + "\\DataSources\\NASDAQSource\\UniverseLists"):
    os.makedirs(DL + "\\DataSources\\NASDAQSource\\UniverseLists")   
    
#These are frequencies for ModelOutput from YahooSource
if not os.path.exists(DL + "\\ModelOutput\\YahooSource\\DAY"):
    os.makedirs(DL + "\\ModelOutput\\YahooSource\\DAY")
    
#Create and edit a quarternary set of folders within a tertiary folder; keep it clean
if not os.path.exists(DL + "\\DataSources\\YahooSource\\ProcessedData\\DAY"):
    os.makedirs(DL + "\\DataSources\\YahooSource\\ProcessedData\DAY")
if not os.path.exists(DL + "\\DataSources\\YahooSource\\ProcessedData\\WEK"):
    os.makedirs(DL + "\\DataSources\\YahooSource\\ProcessedData\\WEK")
if not os.path.exists(DL + "\\DataSources\\YahooSource\\ProcessedData\\MON"):
    os.makedirs(DL + "\\DataSources\\YahooSource\\ProcessedData\\MON")
if not os.path.exists(DL + "\\DataSources\\YahooSource\\ProcessedData\\DIV"):
    os.makedirs(DL + "\\DataSources\\YahooSource\\ProcessedData\\DIV")
    
#This holds ByTicker and ByModel folders within frequencies folders for ModelOutput from YahooSource
if not os.path.exists(DL + "\\ModelOutput\\YahooSource\\DAY\\DonchianTrend"):
    os.makedirs(DL + "\\ModelOutput\\YahooSource\\DAY\\DonchianTrend")

#Create and edit a 5th set of folders within a quarternary folder; keep it clean
if not os.path.exists(DL + "\\ModelOutput\\YahooSource\\DAY\\DonchianTrend\\ReturnStreams"):
    os.makedirs(DL + "\\ModelOutput\\YahooSource\\DAY\\DonchianTrend\\ReturnStreams")
    
if not os.path.exists(DL + "\\ModelOutput\\YahooSource\\DAY\\DonchianTrend\\ModelOutput"):
    os.makedirs(DL + "\\ModelOutput\\YahooSource\\DAY\\DonchianTrend\\ModelOutput")
