# Import Packages
import time
import os

# Go to CLOVER directory
#cd('/Users/Shez/Google Drive/Grantham/CLOVER/CLOVER-master/')

# Import scripts
print('Importing Scripts...')
exec(open("Scripts/Load_scripts/Load.py").read())
exec(open("Scripts/Generation_scripts/Solar.py").read())

# Do load stuff
print('Generating load data...')
Load(location='Bhinjpur',no_commercial_scaling='TRUE',no_public_scaling='TRUE').number_of_devices_daily() #to get the number of each device in the community on a given day
Load(location='Bhinjpur').get_device_daily_profile() #to get the daily utilisation profile (365x24 matrix) for each device
Load(location='Bhinjpur').devices_in_use_hourly() #to generate the number of devices in use for each hour- this step is time consuming
Load(location='Bhinjpur').device_load_hourly() #to get the load of each device
Load(location='Bhinjpur').total_load_hourly() #to get the total community load, segregated into “Domestic”, “Commercial” and “Public” demand types


# Generate Solar Data - adaptable to apply to a range of locations. This is slow because renewables.ninja gets upset and blocks you if you try to get too much data too quickly.
locations = ['Bhinjpur']
dates = range(2009,2019)

for location in locations:
    print('Getting solar data for ',location)
    for date in dates:
        print('Getting solar data for ',location,' in ',date)
        Solar(location=location).save_solar_output(date)
        time.sleep(60) # Required to avoid upsetting renewables.ninja

    print('Generating 20 year PV file from data...')
    Solar(location=location).total_solar_output(2009)

