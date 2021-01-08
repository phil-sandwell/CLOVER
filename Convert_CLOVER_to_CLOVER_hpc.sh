
#(from CLOVER folder)

# Reconfigure to take '.' as filepath - necessary for HPC where CLOVER is copied to the node before processing. (May wish to amend if CLOVER dir gets very big)
SRC="\/\*\*\*YOUR LOCAL FILE PATH\*\*\*\/CLOVER 4.0"
DST="."
sed -i "" -e "s/$SRC/$DST/g" Scripts/*/*py

SRC="\/\*\*\*YOUR LOCAL FILE PATH\*\*\*\/CLOVER"
DST="."
sed -i "" -e "s/$SRC/$DST/g" Scripts/*/*py

# Reconfigure to take kwargs for location
sed -i "" -e 's/__init__(self)/__init__(self,**kwargs)/g' Scripts/*/*py

SRC="self.location = 'Bahraich'"
DST="self.location = kwargs.get('location')"
sed -i "" -e "s/$SRC/$DST/g" Scripts/*/*py

SRC="self.location = ‘Bahraich’" # This is required too as there is some inconsistency in type of inverted commas used in original CLOVER scripts.
DST="self.location = kwargs.get('location')"
sed -i "" -e "s/$SRC/$DST/g" Scripts/*/*py

# Set up dependencies in taking kwargs for location

sed -i "" -e "s/Diesel()\./Diesel(kwargs)./g" Scripts/*/*py
sed -i "" -e "s/Grid()\./Grid(kwargs)./g" Scripts/*/*py
sed -i "" -e "s/Solar()\./Solar(kwargs)./g" Scripts/*/*py
sed -i "" -e "s/Finance()\./Finance(kwargs)./g" Scripts/*/*py
sed -i "" -e "s/GHGs()\./GHGs(kwargs)./g" Scripts/*/*py
sed -i "" -e "s/Load()\./Load(kwargs)./g" Scripts/*/*py
sed -i "" -e "s/Energy_System()\./Energy_System(kwargs)./g" Scripts/*/*py

# Replace spaces with underscores in filenames because spaces cause problems in file handling

rename -s ' scripts' '_scripts' Scripts/*/

for file in Scripts/*/*py;
do
   sed "s| scripts|_scripts|" $file > temp; mv temp $file;
done

# Clean up anomylous naming and dodgy spacing

for file in Scripts/*/*py;
do
   sed "s|location_input_data|location_inputs|" $file > temp; mv temp $file;
	sed "s|_inputs =  pd.read_csv|_inputs = pd.read_csv|" $file > temp; mv temp $file;
	sed "s|_inputs  = pd.read_csv|_inputs = pd.read_csv|" $file > temp; mv temp $file;
done

# Set up scripts to allow specification of inputs with kwargs (overrides those specified in location)

for name in grid location finance GHG device optimisation energy_system scenario diesel
do
	cat > ${name}_line.py << EOF
        # Replace input values with keywords if specified
        if kwargs.get('${name}_inputs'):
            for i in kwargs.get('${name}_inputs'):
                if not i[0] in self.${name}_inputs.index:
                    print("Couldn't find entry",i[0],"in ${name}_inputs. Perhaps it's misspelt in kwargs? Printing list of possible variables and exiting.")
                    print(self.${name}_inputs.index)
                    exit(1)
            self.${name}_inputs[i[0]] = i[1]
EOF

	for file in Scripts/*/*py
	do
		sed "/        self.${name}_inputs = pd.read_csv/r ${name}_line.py" $file > tmp
		mv tmp $file
	done

rm ${name}_line.py

done

