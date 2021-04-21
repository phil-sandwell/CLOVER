# CLOVER
CLOVER minigrid simulation and optimisation for supporting rural electrification in developing countries

## CLOVER Quick Start Guide

This guide provides a very brief guide to using CLOVER as quickly as possible following the initial download. The file structure has two branches: 
        ▪       a “Scripts” branch which contains Python files that the user runs and uses to generate outputs and perform simulations, 
        ▪       a “Locations” branch that the describes individual locations and specifics of a given scenario being investigated. 

An example location, “Bahraich” in India, is included in the initial download for reference. New locations can be set up using the generic “New_Location” folder structure. Functions are stated below without explicit definition of their input arguments for brevity. 

        1.      General Setup
                a.      In each file in the “Scripts” branch, update:
                        i.      “self.location” to the name of your location
                        ii.     “self.CLOVER_filepath” to the file path of your CLOVER folder
                        iii.    Update the file path syntax as necessary
                        iv.     Do this for all scripts
                b.      In the “Locations” folder, copy a new version of the “New_Location” file structure and rename it to your chosen location
                c.      Go to https://www.renewables.ninja/register to register a free account to gain your API token 
        2.      Establish your location
                a.      In your location folder (e.g. “Bahraich”), open the “Location Data” folder
                b.      Complete the “Location inputs.csv” template with the details of your location and your API token 
        3.      Get PV generation data
                a.      In your location folder, open the “Generation” folder and then the “PV” folder
                b.      Complete the “PV generation inputs.csv” template with the details of your location
                c.      Run Solar().save_solar_output(gen_year) for each year of ten consecutive years
                        i.      This function requires the internet access to connect to the renewables.ninja site
                        ii.     The renewables.ninja site has a limit on the number of downloads in a given time period, so needs to be done manually for each year
                        iii.    Choose any period of ten years for which renewables.ninja has data
                d.      Run Solar().total_solar_output(start_year) to combine your yearly solar outputs into a single file of twenty years
        4.      Get grid availability data
                a.      In your location folder, open the “Generation” folder and then the “Grid” folder
                b.      Complete the “Grid inputs.csv” template with the details of your location
                        i.      Grid profiles are a 1x24 matrix of hourly probabilities (0-1) that the grid is available
                        ii.     Input all grid profiles at the same time
                c.      Run Grid().get_lifetime_grid_status() to automatically generate grid availability for all specified profiles
        5.      Get diesel backup generation data
                a.      In your location folder, open the “Generation” folder and then the “Diesel” folder
                b.      Complete the “Diesel generation inputs.csv” template with the details of your location
        6.      Get load data
                a.      In your location folder, open the “Load” folder
                b.      Complete the “Devices.csv” template with the details of your location
                c.      In the “Devices utilisation” folder, complete the utilisation profiles for each device e.g. “light_times.csv”
                        i.      Utilisation profiles are a 12x24 (monthly x hourly) matrix of probabilities that the specified device is in use in that hour
                        ii.     Each device in  “Devices.csv” must have a corresponding utilisation profile
                d.      Run Load().number_of_devices_daily() to get the number of each device in the community on a given day
                e.      Run Load().get_device_daily_profile() to get the daily utilisation profile (365x24 matrix) for each device
                f.      Run Load().devices_in_use_hourly() to generate the number of devices in use for each hour
                g.      Run Load().device_load_hourly() to get the load of each device
                h.      Run Load().total_load_hourly() to get the total community load, segregated into “Domestic”, “Commercial” and “Public” demand types
        7.      Set up the energy system
                a.      In your location folder, open the “Simulation” folder
                b.      Complete the “Energy system inputs.csv” template with the details of your location
                c.      In your location folder, open the “Scenario” folder
                d.      Complete the “Scenario inputs.csv” template with the details of your location
        8.      Perform a simulation
                a.      Run Energy_System().simulation(start_year, end_year, PV_size, storage_size) with your chosen system
                b.      Record the outputs as a variable to investigate the outputs in more detail
                c.      Save the outputs using Energy_System().save_simulation(simulation_name,filename)
                d.      Open a saved simulation using Energy_System().open_simulation(filename)
        9.      Input financial information
                a.      In your location folder, open the "Impact" folder
                b.      Complete the "Financial inputs.csv" with details of your location
        10.     Input GHG information
                a.      In your location folder, open the "Impact" folder
                b.      Complete the "GHG inputs.csv" with details of your location
        11.     Set up the optimisation process
                a.      In your location folder, open the "Optimisation" folder
                b.      Complete the “Optimisation inputs.csv” template with the details of your location
        12.     Perform an optimisation
                a.      Run Optimisation().multiple_optimisation_step()
                b.      Record the outputs as a variable to investigate the outputs in more detail
                c.      Save the outputs using Optimisation().save_optimisation(optimisation_name,filename)
                d.      Open a saved optimisation using Optimisation().open_optimisation(filename)


## Use of CLOVER on Imperial High Performance Computing Service

This version of CLOVER has been adapted to facilitate bulk running of jobs on Imperial College's HPC. This allows more jobs to be run simultaneously without using up processing power of your local computer. The following steps should allow you to set up and run jobs:

### HPC Setup

1) Get an HPC account (see https://www.imperial.ac.uk/computational-methods/hpc/)

2) Log on to hpc (using a terminal/bash if using mac/linux, or equivalent on pc). Make relevant directories. (NB. 'USERNAME' should be replaced with yor username.)
	
        ssh USERNAME@login.cx1.hpc.ic.ac.uk
        mkdir /rds/general/user/${USER}/home/CLOVER-hpc/
        mkdir /rds/general/user/${USER}/home/CLOVER-hpc/Core_files/
        mkdir /rds/general/user/${USER}/home/CLOVER-hpc/Jobs/
        mkdir /rds/general/user/${USER}/home/CLOVER-hpc/Results/


3) Import CLOVER-hpc and example jobs from Github. (NB. 'USERNAME' should be replaced with yor username)

        cd /rds/general/user/${USER}/home/CLOVER-hpc/Core_files/
        git clone -b CLOVER-hpc https://github.com/sheridanfew/CLOVER.git .
        cd /rds/general/user/${USER}/home/CLOVER-hpc/Jobs/
        git clone https://github.com/sheridanfew/CLOVER-hpc-job-example.git .

4) Add your renewables.ninja API to the location file for Bhinjpur. The command below does this be replacing the appropriate renewables ninja line using sed (replace YOUR_API_TOKEN in the command below below with your API token). Alternatively, you could use vim or set up Visual Studio code for a more user-friendly way of interacting with files on the hpc.


        API_TOKEN="YOUR_API_TOKEN"
        sed -i "s/token,,renewables.ninja API token/token,${API_TOKEN},renewables.ninja API token/" /rds/general/user/${USER}/home/CLOVER-hpc/Core_files/Locations/Bhinjpur/Location\ Data/Location\ inputs.csv

5) Run set of commands to set up a CLOVER python environment containing necessary packages: (NB. You may need to copy and paste commands within 'HPC_setup.sh' to command line on the hpc if this doesn't work)

        cd /rds/general/user/${USER}/home/CLOVER-hpc/Core_files/
        chmod +x ./HPC_setup.sh
        ./HPC_setup.sh

6) Make the launch file executable and add its location to your path so that you can run it from any location.

        cd /rds/general/user/${USER}/home/CLOVER-hpc/Core_files/
        chmod +x ./Launch_Script/launch_CLOVER_jobs.sh
        echo "# Add CLOVER launch dir to path" >> /rds/general/user/${USER}/home/.bash_profile
        echo "PATH=\$PATH:/rds/general/user/${USER}/home/CLOVER-hpc/Core_files/Launch_Script/" >> /rds/general/user/${USER}/home/.bash_profile
        PATH=$PATH:/rds/general/user/${USER}/home/CLOVER-hpc/Core_files/Launch_Script/


## Commands for each HPC job

7) If necessary, generate load and solar data - this is necessary for the included example job.  (Doing this from the command line isn’t best practice - this should really be done on nodes set up for running jobs rather than that you’re interacting with to avoid slowing it down for other users - but I think not so bad for only for a few locations). Scripts to do this for other locations can be made by adapting the included Load_Solar_Bhinjpur script. Commands to do this when logged into the hpc:

        cd /rds/general/user/${USER}/home/CLOVER-hpc/Core_files/
        module load anaconda3/personal
        source activate CLOVER
        python Load_Solar_Bhinjpur.py 

8) Navigate to Jobs directory and send your CLOVER jobs to be run!

For the example job, the commands would be:

	cd /rds/general/user/${USER}/home/CLOVER-hpc/Jobs/
	launch_CLOVER_jobs.sh -j Bhinjpur_Batt_costs Bhinjpur_LowBattCost/Bhinjpur_LowBattCost.py Bhinjpur_MidBattCost/Bhinjpur_MidBattCost.py Bhinjpur_HiBattCost/Bhinjpur_HiBattCost.py

(inspecting these three python job files can help to understand how to adapt them for new jobs)

You can get help/check what each option in the launch script does by running 

        launch_CLOVER_jobs.sh --help

More generally, this script can be used to run up to 8 jobs simultaneously by adapting the following command:

	cd /rds/general/user/${USER}/home/CLOVER-hpc/Jobs/
	launch_CLOVER_jobs.sh -j UNIQUE_NAME_FOR_THIS_SET_OF_JOBS JOB1/JOB1.py JOB2/JOB2.py ... JOB8/JOB8.py 


9) Wait for the job to finish. You can check the status of your job with the command 'qstat'. It will disappear from the queue when it has completed. Once the job is completed, results should appear in the folder /rds/general/user/USERNAME/home/CLOVER-hpc/Results.

10) Copy results back to a convenient directory on your own computer when the job is finished. From a bash terminal in a convenient directory:

        scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/rds/general/user/USERNAME/home/CLOVER-hpc/Results/NAME_OF_YOUR_JOB/ .

For the example:

	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/rds/general/user/USERNAME/home/CLOVER-hpc/Results/Bhinjpur_LowBattCost/ . 
	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/rds/general/user/USERNAME/home/CLOVER-hpc/Results/Bhinjpur_MidBattCost/ . 
        scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/rds/general/user/USERNAME/home/CLOVER-hpc/Results/Bhinjpur_HiBattCost/ . 

Or using a wildcard:

	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/rds/general/user/USERNAME/home/CLOVER-master/Results/Bhinjpur_*BattCost/ . 

11) Analyse results locally as you see fit. I have included a bash script, 'run_info.sh' in this repository, which could be helpful to summarise key outputs of a large set of optimisation results csv files in one directory.

For more information, contact Phil Sandwell (philip.sandwell@gmail.com)

