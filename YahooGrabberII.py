# -*- coding: utf-8 -*-
"""

@author: Adam Reinhold Von Fisher - https://www.linkedin.com/in/adamrvfisher/

"""

#This is a HTML scraper, I/O, and formatting tool that requests OHLC data from Yahoo!

#Define function
def YahooGrabberII(ticker):
    try:        
        #Import modules
        import requests
        import pandas as pd
        import time as t
        import json
        from json import JSONDecodeError
        
        #Start timer
        starttime = t.time()
        
        #Variable assignment
        Asset = pd.DataFrame()
        #Assign URL for post request
        url = ('http://finance.yahoo.com/quote/' + ticker + '/history?period1=-2552017587' +
               '&period2=2552397400&interval=1d&filter=history&frequency=1d')
        #Make post request
        page = requests.post(url)
        print(page)
        #Format response to text
        textI = page.text
        
        #Locate text in response
        markerI = textI.find('[{"date":')
        #Assign trimmed response
        textI = textI[markerI:]
        
        #Locate text in trimmed response
        markerII = textI.find(',"isPending":false')
        #Assign trimmed response
        textI = textI[:markerII]
        #text to json
        textI = json.loads(textI)
        
        for i in reversed(textI):
            Asset = Asset.append(i, ignore_index = True)
            
        #Rename columns
        Asset = Asset.rename(columns={"adjclose": "Adj Close", "close": "Close", "date": "Date", 
                           "high": "High", "low": "Low", "open": "Open", "volume": "Volume"})    
            
        #Format datetime index
        Asset['Date'] = pd.to_datetime(Asset['Date'], unit = 's')
        Asset['Date'] = Asset['Date'].dt.date
        
        #Set index to Date
        Asset = Asset.set_index('Date')
        
        if 'type' in Asset.columns:
            #Fill Asset price data type as PRICE 
            Asset['type'] = Asset['type'].fillna('PRICE')
        
            #Modify Asset
            Asset = Asset.loc[Asset['type'] == 'PRICE']
        
        #Assign columns to drop
        DropColumns = ['amount', 'data', 'type', 'denominator', 'numerator', 'splitRatio']
        
        #For every column in columns to drop
        for column in DropColumns:
            #If column exists
            if column in Asset.columns:
                #Drop column
                Asset = Asset.drop(column, axis = 1)
        
        #End timer    
        endtime = t.time()
        #Time calculation
        duration = endtime - starttime
        #Display time taken for request and formatting
        print("Data request for " + ticker + " took " + str(duration) +" seconds.") 
    except JSONDecodeError:
        print('URL failed for ' + ticker + '.')
    return Asset
