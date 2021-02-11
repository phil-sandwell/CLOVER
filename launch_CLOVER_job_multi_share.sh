#!/bin/sh

#Sheridan's script to launch CLOVER jobs, following Jarv's .com launcher.

NCPUS=8
MEM=11800mb   #Simon Burbidge correction - lots of nodes with 12GB physical memory, leaves no overhead for OS
QUEUE="" #default route
TIME="71:58:02" # Two minutes to midnight :^)
USERNAME=$USER
CLOVER_PATH="/rds/general/user/${USERNAME}/home/"

function USAGE()
{
 cat << EOF
Sheridan's script to launch multiple CLOVER jobs, following Jarv's .com launcher.

Launching multiple CLOVER jobs allows efficient use of the multiple processors on nodes to which jobs are submitted. The number of jobs launched should ideally equal the number of processors requested. 
These jobs must contain the a line 'location=LOCATION_NAME_HERE' in the first few lines so that the script knows where to get Location details from.cp -r ${CLOVER_PATH}/Core_files/Locations/$LOCATION/ CLOVER/Locations/

USAGE: ./launch_CLOVER_job.sh [-nm] -j COLLECTIVE_NAME Job1.py Job2.py Job3.py ...

OPTIONS:
	-j collective job name
	-n number of cpus
	-m memory
	-q queue
	-t time

DEFAULTS (+ inspect for formatting):
	NCPUS = ${NCPUS}
	MEM   = ${MEM}
	QUEUE = ${QUEUE}
	TIME = ${TIME} (half hour limit for debug nodes)
EOF
}

while getopts ":j:m:n:q:t:?" Option
do
    case $Option in
        j    ) JOBNAME="${OPTARG}";;
        n    ) NCPUS=$OPTARG;;
        m    ) MEM=$OPTARG;;
        q    ) QUEUE=$OPTARG;;
        t    ) TIME="${OPTARG}";;
        ?    ) USAGE
               exit 0;;
        *    ) echo ""
               echo "Unimplemented option chosen."
               USAGE   # DEFAULT
    esac
done

shift $(($OPTIND - 1))
#  Decrements the argument pointer so it points to next argument.
#  $1 now references the first non option item supplied on the command line
#+ if one exists.

#exit if com doesn't exit

for file in "$@"
do

	if [ ! -f ${file} ]
		then
                echo "file $@ does not exist."
		exit 2 

	fi
done

PWD=` pwd `

# Make runfile which will then be submitted to the hpc and run on an individual node.

# Header to run file for whole set of jobs - set hpc variables,  import CLOVER etc.

 cat  > ${JOBNAME}.sh << EOF
#!/bin/sh
#PBS -l walltime=${TIME}
#PBS -l select=1:ncpus=${NCPUS}:mem=${MEM}

echo "Execution started:"
date

# Load anaconda
module load anaconda3/personal

# Activate environment
source activate CLOVER

echo "cwd:"
pwd

# Make Jobdir
if [ -a tmp_jobdir ]
then
	rm -r tmp_jobdir
fi
mkdir tmp_jobdir

cd tmp_jobdir

# Copy over/make necessary files for all CLOVER runs
mkdir CLOVER/
cp -r ${CLOVER_PATH}/Core_files/Scripts CLOVER/
mkdir CLOVER/Locations

EOF

# Sections to run each individual job

for COM in $*
do
# Get details specific to job ${COM}
 WD=${COM%/*} #subdirectory that .com file is in
 BASENAME=$(basename ${COM} | sed 's/.py//g')
 # echo "COM: $COM PWD: $PWD WD: $WD"
 LOCATION=$(grep -m 1 'location' ${COM} | sed "s/location=//g" | sed "s/'//g")


   cat >> ${JOBNAME}.sh << EOF
 if [ ! -d CLOVER/Locations/$LOCATION/ ]
  then
  cp -r ${CLOVER_PATH}/Core_files/Locations/$LOCATION/ CLOVER/Locations/
 fi

# Make directory and copy in files to run ${BASENAME}
 
mkdir ${BASENAME}/
mkdir ${BASENAME}/Jobs/
cp -r CLOVER/* ${BASENAME}
cp -r ${CLOVER_PATH}/Jobs/$BASENAME/ ${BASENAME}/Jobs/

# Make directory to copy results back to once run is completed

mkdir -p ${CLOVER_PATH}/Results/$BASENAME

# Run this job (in the background so that other jobs can run simultaneously on this node)

echo "Running python job $BASENAME"

(cd $BASENAME; python Jobs/$BASENAME/${BASENAME}.py) &

EOF

# Footer to copy all files back (this is not added directly to the runfile, but to a separate footer file added after the runs have completed)

   cat >> footer.sh << EOF
echo "Copying files back"

cp -r ${BASENAME}/Locations/$LOCATION/Simulation/Saved\ simulations/ ${CLOVER_PATH}/Results/$BASENAME
cp -r ${BASENAME}/Locations/$LOCATION/Optimisation/Saved\ optimisations/ ${CLOVER_PATH}/Results/$BASENAME

EOF

done

# Wait until all jobs complete
echo "wait" >> ${JOBNAME}.sh

# Add footer to script which copies all results back
cat footer.sh >> ${JOBNAME}.sh
rm footer.sh

# Add final commands to script
cat >> ${JOBNAME}.sh << EOF

mail -s "HPC Job Done: ${JOBNAME}" ${USERNAME}@imperial.ac.uk <<< 'Hooray!'

echo "Job finished:"
date

cd ..
rm -r tmp_jobdir

exit 0
EOF

 # Submit job to hpc
 qsub -q "${QUEUE}" ${JOBNAME}.sh

exit 0

