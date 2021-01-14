# CLOVER
CLOVER minigrid simulation and optimisation for supporting rural electrification in developing countries

Version of CLOVER adapted for use on Imperial College's High Performance Computing service.

###OVERVIEW###

This version of CLOVER has been adapted to facilitate bulk running of jobs on Imperial College's HPC. The main differences between this and forked version of CLOVER are as follows:

∙ The directory structure is adapted such that paths are defined relative to the working directory rather than absolute - this allows the entire CLOVER directory to be copied to individual nodes on the HPC, and different jobs with similar locations to run on separate nodes simultaneously.

∙ Scripts have been adapted such that they can take keyword arguments (kwargs) to override parameter values specified in location inputs. This facilitates exploration of different input values without defining new locations (or manually editing existing ones) for each value considered.

∙ A "Jobs" folder is added, including a number of example jobs which can be submitted to the HPC.

∙ A launch script is added, which can be used to launch the above jobs (or other jobs depending on commands passed to this script)

∙ A "Results" folder is added, to which results of simulations and optimisations preformed on the hpc are returned.

∙ Spaces are replaced with underscores in paths to scripts (this avoids some complication in copying files to and from the hpc, and mass processing of scripts). Not a major change per se, but github is not able to recognise files after this change, making merging branches a bit trickier. Could be partly overcome by temporarily reverting the names of these paths.

Generally, these changes shouldn't afffect the ability of pre-existing CLOVER jobs to run with the following changes: (1) path to scripts will need revising, and (2) location must be explicitly specified as a keyword when calling functions (as per exaple jobs included)

###SETTING UP###

1) Get an HPC account (see https://www.imperial.ac.uk/computational-methods/hpc/)

2) Open a bash terminal window and navigate to the github repository (if using mac/linux, otherwise will need to use another method to copy scripts to, and send commands on, the hpc)

3) Add your renewables.ninja API to the location file for Bhinjpur, then copy the modified version of CLOVER for the HPC to your account in the directory /home/USERNAME/. 

	scp -r CLOVER-master USERNAME@login.cx1.hpc.ic.ac.uk:/home/USERNAME/CLOVER-master

4) Modify the launch file such that your username is in place of USERNAME in the launch_CLOVER_job.sh file using a text editor, then send to your HPC 'bin' directory.

	scp launch_CLOVER_job_multi_new.sh USERNAME@login.cx1.hpc.ic.ac.uk:/home/USERNAME/bin

5) Log on to HPC using a bash terminal 

	ssh USERNAME@login.cx1.hpc.ic.ac.uk

6) Move to CLOVER-master directory

	cd /home/USERNAME/CLOVER-master

7) Run set of commands to set up CLOVER python environment containing necessary packages: (NB. May need to copy and paste commands within 'HPC_setup.sh' to commnd line on the hpc if this doesn't work)

	chmod +x ./HPC_setup.sh
	./HPC_setup.sh


###FOR EACH JOB###

8) Make python launch files to run your job by editing the template python job, put them in directories of the same name as the file, then copy to your Jobs folder

	scp -r Job_1/ USERNAME@login.cx1.hpc.ic.ac.uk:/home/USERNAME/CLOVER-master/Jobs
	scp -r Job_2/ USERNAME@login.cx1.hpc.ic.ac.uk:/home/USERNAME/CLOVER-master/Jobs


9) If necessary, generate load and solar data - this is necessary for the included example job.  (This isn’t the best practice - this should really be done on nodes set up for running jobs rather than that you’re interacting with to avoid slowing it down for other users - but not so bad as long as it’s only for a few locations). Scripts to do this for other locations can be made by adapting the included script for the example location. From hpc:

	cd /home/USERNAME/CLOVER-master
	module load anaconda3/personal
	source activate CLOVER
	python Load_Solar_Bhinjpur.py 

10) Navigate to Jobs directory and send your CLOVER jobs to be run! The script below can be run for up to 8 jobs at a time.

	cd /home/USERNAME/CLOVER-master/Jobs/
	launch_CLOVER_job_multi_new.sh -j UNIQUE_NAME_FOR_THIS_SET_OF_JOBS JOB1/JOB1.py JOB2/JOB2.py ... JOB8/JOB8.py 

You can get a list of jobs formatted correctly for this script by running the following in your ‘Jobs’ directory (probably easier to do this on your local PC in a directory which only has the jobs of interest)

	for file in */*py; do echo -en "$file "; done

For the example job, the command would be:

	launch_CLOVER_job_multi_new.sh -j Bhinjpur_LiB_costs Bhinjpur_LiB_cyc1000_cost1270_It2yrs_Opt/Bhinjpur_LiB_cyc1000_cost1270_It2yrs_Opt.py Bhinjpur_LiB_cyc1000_cost176_It2yrs_Opt/Bhinjpur_LiB_cyc1000_cost176_It2yrs_Opt.py Bhinjpur_LiB_cyc1000_cost350_It2yrs_Opt/Bhinjpur_LiB_cyc1000_cost350_It2yrs_Opt.py

You can get help/check what each option does by running launch_CLOVER_job_multi_new.sh --help

11) Wait for the job to finish. You can check the status of your job with the command 'qstat'. It will disappear from the queue when it has completed. The launch_CLOVER_job.sh script is currently set up to email you when a job's finished too. Easy to remove the line doing this from the launch script if it becomes a pain. Once the job is completed, results should appear in the folder /home/USERNAME/CLOVER-master/Results.

12) Copy results back to a convenient directory on your own computer when the job is finished. From a bash terminal in a convenient directory:

	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/home/USERNAME/CLOVER-master/Results/NAME_OF_YOUR_JOB/ .

For the example:

	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/home/USERNAME/CLOVER-master/Results/Bhinjpur_LiB_cyc1000_cost1270_It2yrs_Opt/ . 
	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/home/USERNAME/CLOVER-master/Results/Bhinjpur_LiB_cyc1000_cost176_It2yrs_Opt/ . 
	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/home/USERNAME/CLOVER-master/Results/Bhinjpur_LiB_cyc1000_cost350_It2yrs_Opt/ . 

Or using a wildcard:

	scp -r USERNAME@login.cx1.hpc.ic.ac.uk:/home/USERNAME/CLOVER-master/Results/Bhinjpur_LiB_cyc1000_cost*_It2yrs_Opt/ . 

