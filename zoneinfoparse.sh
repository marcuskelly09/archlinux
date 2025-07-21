# Functions

function check_user_input_validity () {
	func_output=""
	
	# $1 is the input, $2 is the length of the input array
	# Checks to see if input is within the indexes of the array
	if [[ $1 > 0 && $1 -le $2 ]]; then
		func_output="valid"
		return 0
	else
		func_output="invalid"
		return 1
	fi
}

function get_base_timezones {
	alltimezones=()
	alltimezonesindexed=()
	count=0

	readarray -t allzones <<<$(timedatectl list-timezones --no-pager)
	
	# Removes repeated base time zones
	for zone in "${allzones[@]}"; do
		base="${zone%/*}"
		base_string_length=${#base}

		ispresent="false"
		for region in "${alltimezones[@]}"; do
			if [[ $base == $region ]]; then
				ispresent="true"	
			fi
		done
		
		if [[ $ispresent == "false" ]]; then
			alltimezones+=("$base")
		fi
	done

	# Adds indexes to base timezones
	for zone in "${alltimezones[@]}"; do
		((++count))
		alltimezonesindexed+=("[${count}] $zone")
	done
	
	# Lists all time zones in format [x] timezone in columns
	IFS=$'\n'
	column -c 120 <<< "${alltimezonesindexed[*]}"
}

function add_page () {
	readarray -t allzones <<<$(timedatectl list-timezones --no-pager)
	region="${alltimezones[(($1 - 1))]}"
	page+=($region)
	echo "Page: $page"
}

function get_tree_timezones() {
	readarray -t allzones <<<$(timedatectl list-timezones --no-pager)
	base_input=$1
	page_listings=()
	page_listings_indexed=()
	count=0

	# Checks for matching zones to input
	for zone in "${allzones[@]}"; do
		if [[ $base_input == ${zone%/*} ]]; then
			page_listings+=($zone)
		fi
	done

	# Addes indexes to tree timezones
	for zone in "${page_listings[@]}"; do
		((++count))
		page_listings_indexed+=("[$count] $zone")
	done

	column -c 120 <<< "${page_listings_indexed[*]}"
	exit
}

loop="true"
page=()
while [[ $loop == "true" ]]; do
	# Checks if user it at home page
	if [[ "${page[-1]}" == "" ]]; then
		clear
		echo "Please select you time zone, if the option you select has submenus, you can navigate them by selecting them"
		echo ""
		get_base_timezones
		echo ""
		echo "Please select a timezone"
		read input

		check_user_input_validity $input ${#alltimezones[@]}

		if [[ $func_output == "valid" ]]; then
			add_page $input
		fi
	else
		clear
		get_tree_timezones $region
	fi
done
