import pandas as pd
import numpy as np

def transposeToDummy(df,naDrop=True,toNumpy=True):
    # Check df status
    if df is None:
        return None
    
    if df.isna().any().any():
        if naDrop:
            df = df.dropna()
        else:
            print("There is missing data in the DataFrame.")
            return None
        
    # Add dummy variables
    df = pd.get_dummies(df,drop_first=True)  

    # Convert bool columns to 1 or 0
    bool_cols = df.select_dtypes(include=bool).columns
    df[bool_cols] = df[bool_cols].astype(int)

    # Convert dataframe to numpy
    if toNumpy:
        df = df.to_numpy()
    return df


    