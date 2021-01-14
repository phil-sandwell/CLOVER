# CLOVER
CLOVER minigrid simulation and optimisation for supporting rural electrification in developing countries

Version of CLOVER adapted for use on Imperial College's High Performance Computing service.

## Overview

This version of CLOVER has been adapted to facilitate bulk running of jobs on Imperial College's HPC. The main differences between this and forked version of CLOVER are as follows:

∙ The directory structure is adapted such that paths are defined relative to the working directory rather than absolute - this allows the entire CLOVER directory to be copied to individual nodes on the HPC, and different jobs with similar locations to run on separate nodes simultaneously.

∙ Scripts have been adapted such that they can take keyword arguments (kwargs) to override parameter values specified in location inputs. This facilitates exploration of different input values without defining new locations (or manually editing existing ones) for each value considered.

∙ A "Jobs"\* folder is added, including a number of example jobs which can be submitted to the HPC. 

∙ A launch script is added, which can be used to launch the above jobs (or other jobs depending on commands passed to this script)

∙ A "Results"\* folder is added, to which results of simulations and optimisations performed on the hpc are returned.

∙ Spaces are replaced with underscores in paths to scripts (this avoids some complication in copying files to and from the hpc, and mass processing of scripts). Not a major change per se, but github is not able to recognise files after this change, making merging branches a bit trickier. Could be partly overcome by temporarily reverting the names of these paths.

\* "Jobs" and "Results" folders are kept outside of the main github repository, with the idea that these will  not interact with github updates. Ideally "Locations" would be separated in this manner too. CLOVER scripts would need to be adapted to facilitate this change.

Generally, these changes shouldn't afffect the ability of pre-existing CLOVER jobs to run with the following changes: (1) path to scripts will need revising, and (2) location must be explicitly specified as a keyword when calling functions (as per exaple jobs included)

## Setting up

1) Get an HPC account (see https://www.imperial.ac.uk/computational-methods/hpc/)

2) Log on to hpc (using a terminal/bash if using mac/linux, or equivalent on pc). Make relevant directories. (NB. 'USERNAME' should be replaced with yor username)
	

        ssh USERNAME@login.cx1.hpc.ic.ac.uk
        mkdir /work/USERNAME/CLOVER-hpc/
        mkdir /work/USERNAME/CLOVER-hpc/Core_files/
        mkdir /work/USERNAME/CLOVER-hpc/Jobs/

3) Import CLOVER-hpc and example jobs from Github. (NB. 'USERNAME' should be replaced with yor username)

        cd /work/USERNAME/CLOVER-hpc/Core_files/
        git clone -b CLOVER-hpc https://github.com/sheridanfew/CLOVER.git .
        cd /work/USERNAME/CLOVER-hpc/Jobs/
        git clone https://github.com/sheridanfew/CLOVER-hpc-job-example.git .

4) Add your renewables.ninja API to the location file for Bhinjpur, using vi from hpc command line or a different text editor (NB. This should go in the middle of the final line: token,(YOUR_API_TOKEN,renewables.ninja API token')

        vi /work/USERNAME/CLOVER-hpc/Core_files/Locations/Bhinjpur/Location\ Data/Location\ inputs.csv

5) Run set of commands to set up CLOVER python environment containing necessary packages: (NB. May need to copy and paste commands within 'HPC_setup.sh' to command line on the hpc if this doesn't work)

        cd /work/USERNAME/CLOVER-hpc/Core_files/
        chmod +x ./HPC_setup.sh
        ./HPC_setup.sh

6) Make the launch file executable and move it to your 'bin', from which it can be called from any location.

        cd /work/USERNAME/CLOVER-hpc/Core_files/
        chmod +x ./launch_CLOVER_job_multi_share.sh
        mv launch_CLOVER_job_multi_share.sh ~/bin/


## For each job

7) If necessary, generate load and solar data - this is necessary for the included example job.  (This isn’t the best practice - this should really be done on nodes set up for running jobs rather than that you’re interacting with to avoid slowing it down for other users - but I think not so bad for only for a few locations). Scripts to do this for other locations can be made by adapting the included script for the example location. From hpc:

        cd /work/USERNAME/CLOVER-hpc/Core_files/
        module load anaconda3/personal
        source activate CLOVER
        python Load_Solar_Bhinjpur.py 

8) Navigate to Jobs directory and send your CLOVER jobs to be run!

For the example job, the command would be:

	cd /work/USERNAME/CLOVER-hpc/Jobs/
	launch_CLOVER_job_multi_share.sh -j Bhinjpur_LiB_costs Bhinjpur_LiB_cyc1000_cost1270_It2yrs_Opt/Bhinjpur_LiB_cyc1000_cost1270_It2yrs_Opt.py Bhinjpur_LiB_cyc1000_cost176_It2yrs_Opt/Bhinjpur_LiB_cyc1000_cost176_It2yrs_Opt.py Bhinjpur_LiB_cyc1000_cost350_It2yrs_Opt/Bhinjpur_LiB_cyc1000_cost350_It2yrs_Opt.py

You can get help/check what each option does by running 

        launch_CLOVER_job_multi_share.sh --help

More generally, this script can be used to run up to 8 jobs simultaneously using the following command:

	cd /work/USERNAME/CLOVER-hpc/Jobs/
	launch_CLOVER_job_multi_share.sh -j UNIQUE_NAME_FOR_THIS_SET_OF_JOBS JOB1/JOB1.py JOB2/JOB2.py ... JOB8/JOB8.py 


9) Wait for the job to finish. You can check the status of your job with the command 'qstat'. It will disappear from the queue when it has completed. The launch_CLOVER_job.sh script is currently set up to email you when a job's finished too. Easy to remove the line doing this from the launch script if it becomes a pain. Once the job is completed, results should appear in the folder /home/USERNAME/CLOVER-master/Results.

10) Copy results back to a convenient directory on your own computer when the job is finished. From a bash terminal in a convenient directory:

        scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/work/USERNAME/CLOVER-hpc/Results/NAME_OF_YOUR_JOB/ .

For the example:

	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/work/USERNAME/CLOVER-hpc/Results/Bhinjpur_LiB_cyc1000_cost1270_It2yrs_Opt/ . 
	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/work/USERNAME/CLOVER-hpc/Results/Bhinjpur_LiB_cyc1000_cost176_It2yrs_Opt/ . 
	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/work/USERNAME/CLOVER-hpc/Bhinjpur_LiB_cyc1000_cost350_It2yrs_Opt/ . 

Or using a wildcard:

	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/home/USERNAME/CLOVER-master/Results/Bhinjpur_LiB_cyc1000_cost*_It2yrs_Opt/ . 

11) Analyse results locally as you see fit. I have included a file 'run_info.sh' in this repo, which can be helpful for analysis of a large set of csv files in one directory.
