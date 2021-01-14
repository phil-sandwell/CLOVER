# Import Packages
import time
import os

location='Bhinjpur'

# Go to CLOVER directory
#cd('/Users/Shez/Google Drive/Grantham/CLOVER/CLOVER-master/')

# Import scripts
print('Importing Scripts...')
exec(open("Scripts/Conversion_scripts/Conversion.py").read())
exec(open("Scripts/Generation_scripts/Diesel.py").read())
exec(open("Scripts/Generation_scripts/Grid.py").read())
exec(open("Scripts/Generation_scripts/Solar.py").read())
exec(open("Scripts/Load_scripts/Load.py").read())
exec(open("Scripts/Simulation_scripts/Energy_System.py").read())
exec(open("Scripts/Optimisation_scripts/Optimisation.py").read())

# Run optimisation - multiplicative factors in estimated ranges based on previous runs for 2000 households (+-25% of PV&stor per household from values in these runs - but CLOVER will explore outside of this range if it doesn't find an optimal solution here.)
opt=Optimisation(location='Bhinjpur',
storage_type='LiB',
optimisation_inputs=[
['Scenario length',10],
['Iteration length',2],
['Threshold value',0.05],
['Threshold criterion','Blackouts'],
['PV size (min)',0.0],['PV size (max)',2*18],['PV size (step)',18/10],['PV size (increase)',18/2],
['Storage size (min)',0.0],['Storage size (max)',2*73],['Storage size (step)',73/20],['Storage size (increase)',73/2]
],
finance_inputs=[
['Storage cost',350],
['Storage cost decrease',5]
],
GHG_inputs=[
['Storage GHGs',272]
],
energy_system_inputs=[
['Battery cycle lifetime',1000],
['Battery minimum charge',0.2]
]
).multiple_optimisation_step()



Optimisation(location='Bhinjpur').save_optimisation(opt,filename='Bhinjpur_LiB_cyc1000_cost350_It2yrs_Opt')


print('Done!')
