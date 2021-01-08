# -*- coding: utf-8 -*-
"""
===============================================================================
                            GRID GENERATION FILE
===============================================================================
                            Most recent update:
                                3 May 2019
===============================================================================
Made by:
    Philip Sandwell
Copyright:
    Philip Sandwell, 2018
For more information, please email:
    philip.sandwell@googlemail.com
===============================================================================
"""
import pandas as pd
import random

class Grid():
    def __init__(self,**kwargs):
        self.location = kwargs.get('location')
        self.CLOVER_filepath = '.'
        self.location_filepath = self.CLOVER_filepath + '/Locations/' + self.location
        self.location_inputs = pd.read_csv(self.location_filepath + '/Location Data/Location inputs.csv',header=None,index_col=0)[1]
        # Replace input values with keywords if specified
        if kwargs.get('location_inputs'):
            for i in kwargs.get('location_inputs'):
                if not i[0] in self.location_inputs.index:
                    print("Couldn't find entry",i[0],"in location_inputs. Perhaps it's misspelt in kwargs? Printing list of possible variables and exiting.")
                    print(self.location_inputs.index)
                    exit(1)
            self.location_inputs[i[0]] = i[1]
        self.generation_filepath = self.location_filepath + '/Generation/Grid/'
        self.grid_inputs = pd.read_csv(self.generation_filepath + 'Grid inputs.csv',index_col=0)
        # Replace input values with keywords if specified
        if kwargs.get('grid_inputs'):
            for i in kwargs.get('grid_inputs'):
                if not i[0] in self.grid_inputs.index:
                    print("Couldn't find entry",i[0],"in grid_inputs. Perhaps it's misspelt in kwargs? Printing list of possible variables and exiting.")
                    print(self.grid_inputs.index)
                    exit(1)
            self.grid_inputs[i[0]] = i[1]
#%%
    def get_lifetime_grid_status(self):
        """
        Function:
            Automatically calculates the grid availability profiles of all input types
        Inputs:
            "Grid inputs.csv"
        Outputs:
            .csv files of the availability of all input grid profiles for the duration
            of the simulation period
        """
        grid_types = list(self.grid_inputs)
        for i in range(Grid(kwargs).grid_inputs.shape[1]):
            grid_hours = pd.DataFrame(self.grid_inputs[grid_types[i]])
            grid_status = []
            for day in range(365 * int(self.location_inputs['Years'])):
                for hour in range(grid_hours.size):
                    if random.random() < grid_hours.iloc[hour].values:
                        grid_status.append(1)
                    else:
                        grid_status.append(0)
            grid_name = grid_types[i]
            grid_times = pd.DataFrame(grid_status)
            grid_times.to_csv(self.generation_filepath + grid_name + '_grid_status.csv')

    def change_grid_coverage(self,grid_type='bahraich', hours=12):
        grid_profile = self.grid_inputs[grid_type]
        baseline_hours = np.sum(grid_profile)
        new_profile = pd.DataFrame([0]*24)
        for hour in range(24):
            m = interp1d([0,baseline_hours,24],[0,grid_profile[hour],1])
            new_profile.iloc[hour] = m(hours).round(3)
        new_profile.columns = [grid_type+'_'+ str(hours)]
        return new_profile
    
    def save_grid_coverage(self,grid_type='bahraich',hours=12):
        new_profile = self.change_grid_coverage(grid_type,hours)
        new_profile_name = grid_type+'_'+ str(hours)
        output = self.grid_inputs
        if new_profile_name in output.columns:
            output[new_profile_name] = new_profile
        else:
            output = pd.concat([output,new_profile],axis=1)
        output.to_csv(self.generation_filepath + 'Grid inputs.csv')
