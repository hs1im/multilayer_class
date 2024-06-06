import csv
import numpy as np
import pandas as pd

def dataTransform(df,naDrop=True,toNumpy=True,dropColumns=True):
    # Check df status
    if df is None:
        return None
    
    if df.isna().any().any():
        if naDrop:
            df = df.dropna()
        else:
            print("There is missing data in the DataFrame.")
            return None
    
    # Drop unnamed columns
    columns_to_drop = ['Unnamed: 0', 'Unnamed: 0.1']
    columns_to_drop = [col for col in columns_to_drop if col in df.columns]
    df = df.drop(columns_to_drop, axis=1)
    


    # Drop future's data and not used
    if dropColumns:
        columns_to_drop = ['building_id','height_ft_post_eq']
        columns_to_drop = [col for col in columns_to_drop if col in df.columns]
        df = df.drop(columns_to_drop, axis=1)

    # Drop building floors
    columns_to_drop = ['count_floors_post_eq','count_floors_pre_eq']
    columns_to_drop = [col for col in columns_to_drop if col in df.columns]
    df = df.drop(columns_to_drop, axis=1)
    
    # Transform age_building
    df['age_building'] = df['age_building']+0.1
    df['age_building'] = np.sqrt(df['age_building'])

    # Transform plinth_area_sq_ft
    df['plinth_area_sq_ft'] = np.log(df['plinth_area_sq_ft'])

    # Transform height_ft_pre_eq
    df['height_ft_pre_eq'] = np.log(df['height_ft_pre_eq'])

    # Convert dataframe to numpy
    if toNumpy:
        df = df.to_numpy()
    return df

