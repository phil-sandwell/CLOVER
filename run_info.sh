wd=$(pwd)

echo 'Name,PV size start (kW),PV size end (kW),Storage size first (kWh),Storage size first - post deg (kWh),Storage size last (kWh),Storage size last - post deg(kWh),LCUE ($/kWh),Initial Capital ($),Emissions Instensity (gCO2e/kWh),Self Consumption (%),Blackouts (%),Unmet Energy (%)' > run_info.csv

for file in *csv
do
	name=$(echo $file | sed 's/.csv//g')

	first_line=$(head -n 2 $file | tail -n 1)
	first_line_arr=($(echo "$first_line" | sed 's/,/ /g'))
	last_line=$(tail -n 1 $file)
	last_line_arr=($(echo "$last_line" | sed 's/,/ /g'))
	
	PV_size_first=${first_line_arr[4-1]}
	PV_size_first_post_degrad=${first_line_arr[6-1]}
	PV_size_last=${last_line_arr[4-1]}
	PV_size_last_post_degrad=${last_line_arr[6-1]}
	Stor_size_first=${first_line_arr[5-1]}
	Stor_size_first_post_degrad=${first_line_arr[7-1]}
	Stor_size_last=${last_line_arr[5-1]}
	Stor_size_last_post_degrad=${last_line_arr[7-1]}
	LCUE=${last_line_arr[17-1]}
	LCSE=${last_line_arr[18-1]}
	Initial_capital=${first_line_arr[9-1]}
	Em_intens=${last_line_arr[19-1]}
	Unmet_energy=${last_line_arr[21-1]}
	Self_cons=${last_line_arr[22-1]}
	Blackouts=${last_line_arr[20-1]}
	
	echo "${name},${PV_size_first},${PV_size_last},${Stor_size_first},${Stor_size_first_post_degrad},${Stor_size_last},${Stor_size_last_post_degrad},${LCUE},${Initial_capital},${Em_intens},${Self_cons},${Blackouts},${Unmet_energy}" >> run_info.csv
done