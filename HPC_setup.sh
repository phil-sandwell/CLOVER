
# Set up anaconda
module load anaconda3/personal

anaconda-setup

# Create new environment
conda create -n CLOVER

# Activate environment
source activate CLOVER

# install packages:
conda install python=3.7 pandas numpy scipy
