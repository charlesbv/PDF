#!/bin/bash                

############# FUNCTION CALCULATE_3_LAST_MONTHS

calculate_3_last_months ()
{

if [ $current_month -eq 2 ]
then
    let next_year=$current_year
    let next_month=$current_month+1

    let one_year_ago=$current_year
    let one_month_ago=1
    
    let two_year_ago=$current_year-1
    let two_month_ago=12
elif [ $current_month -eq 1 ]
then
    let next_year=$current_year
    let next_month=$current_month+1

    let one_year_ago=$current_year-1
    let one_month_ago=12

    let two_year_ago=$current_year-1
    let two_month_ago=11
elif [ $current_month -eq 12 ]
then
    let next_year=$current_year+1
    let next_month=1

    let one_year_ago=$current_year
    let one_month_ago=$current_month-1

    let two_year_ago=$current_year
    let two_month_ago=$current_month-2

else
    let next_year=$current_year
    let next_month=$current_month+1

    let one_year_ago=$current_year
#$((10#$item))
    let one_month_ago=$current_month-1
#    let one_month_ago=$((10#$current_month))-1

    let two_year_ago=$current_year
    let two_month_ago=$current_month-2
fi
}

############## END OF FUNCTION CALCULATE_3_LAST_MONTHS


#export IDL_STARTUP=~/idlstartup.pro

{

mkdir ./data
mkdir ./out 
mkdir ./out/plots
mkdir ./out/files  


current_year_to_compare=`date -u +"%Y"`
current_month_to_compare=`date -u +"%m"`
current_day_to_compare=`date -u +"%d"`
current_hour_to_compare=`date -u +"%H"`

current_month_to_compare=`echo $current_month_to_compare|sed 's/^0*//'`
current_day_to_compare=`echo $current_day_to_compare|sed 's/^0*//'`
current_hour_to_compare=`echo $current_hour_to_compare|sed 's/^0*//'`


echo "" &>/dev/tty
echo "**************************************" &>/dev/tty
echo "****** WELCOME TO THE PDF MODEL ******" &>/dev/tty
echo "**************************************" &>/dev/tty

echo "" &>/dev/tty
echo -n "Choose the UTC year of prediction (YYYY): " &>/dev/tty
read  year_pred

while [ $year_pred -lt '1965' ]  || [ $year_pred -gt $current_year_to_compare ]  || [ -z $year_pred ] ;do 
    echo 'Sorry, you need to choose a year between 1965 and' "$current_year_to_compare." &>/dev/tty
    echo -n "Choose the year of prediction (YYYY): "  &>/dev/tty
    read year_pred
done

echo "" &>/dev/tty
echo -n "Choose the UTC month of prediction (MM): " &>/dev/tty
read month_pred

if [ $year_pred -ne $current_year_to_compare ]
then
    while [ $month_pred -lt '1' ]  || [ $month_pred -gt '12' ]  || [ -z $month_pred ] ;do
	echo 'Sorry, you need to choose a month between 01 and 12.' &>/dev/tty
	echo -n "Choose the month of prediction (MM): " &>/dev/tty
	read month_pred
    done
else
    while [ $month_pred -lt '1' ]  || [ $month_pred -gt $current_month_to_compare ]  || [ -z $month_pred ] ;do
	echo 'Sorry, you need to choose a month between 01 and' "$current_month_to_compare." &>/dev/tty
        echo -n "Choose the month of prediction (MM): " &>/dev/tty
        read month_pred
    done
fi

echo "" &>/dev/tty


echo -n "Choose the UTC day of prediction (DD): " &>/dev/tty
read day_pred

if [ $year_pred -ne $current_year_to_compare ]  || [ $month_pred -ne $current_month_to_compare ] 
then
    while [ $day_pred -lt '1' ]  || [ $day_pred -gt '31' ]  || [ -z $day_pred ]  ;do
	echo 'Sorry, you need to make sure that this a correct day number for the month previously chosen.' &>/dev/tty
	echo -n "Choose the day of prediction (DD): " &>/dev/tty
	read day_pred
    done
else
    while [ $day_pred -lt '1' ]  || [ $day_pred -gt $current_day_to_compare ]  || [ -z $day_pred ]  ;do
	echo 'Sorry, you need to choose a day between 01 and' "$current_day_to_compare." &>/dev/tty
        echo -n "Choose the day of prediction (DD): " &>/dev/tty
        read day_pred
    done
fi

echo "" &>/dev/tty
echo -n "Choose the UTC hour of prediction (HH): " &>/dev/tty
read hour_pred
if [ $year_pred -ne $current_year_to_compare ]  || [ $month_pred -ne $current_month_to_compare ]  || [ $day_pred -ne $current_day_to_compare ] 
then
    while [ $hour_pred -lt '0' ]  || [ $hour_pred -gt '23' ]  || [ -z $hour_pred ]  ;do
	echo 'Sorry, you need to choose an hour between 00 and 23.' &>/dev/tty
	echo -n "Choose the hour of prediction (HH): " &>/dev/tty
	read hour_pred
    done
else
    let current_hour_to_compare_minus_2_hours=$current_hour_to_compare-2
    while [ $hour_pred -lt '0' ]  || [ $hour_pred -gt $current_hour_to_compare_minus_2_hours ]  || [ -z $hour_pred ]  ;do
	echo 'Sorry, you need to choose a hour between 00 and' "$current_hour_to_compare_minus_2_hours". &>/dev/tty
        echo -n "Choose the hour of prediction (HH): " &>/dev/tty
        read hour_pred
    done
fi

echo "" &>/dev/tty
echo -n "Do you want to use ensemble of predictions? " &>/dev/tty
read ensemble_or_not_answer
let ensemble_or_not=6
if [ $ensemble_or_not_answer = yes ] 
    then
	let ensemble_or_not=1
    elif [ $ensemble_or_not_answer = no ] 
    then
	let ensemble_or_not=0
fi
while [ $ensemble_or_not -ne 1 ]  && [ $ensemble_or_not -ne 0 ]  || [ -z $ensemble_or_not ]  ;do
    echo -n "Do you want to use ensemble of predictions? (yes/no) " &>/dev/tty
    read ensemble_or_not_answer
    let ensemble_or_not=6
    if [ $ensemble_or_not_answer = yes ] 
    then
	let ensemble_or_not=1
    elif [ $ensemble_or_not_answer = no ] 
    then
	let ensemble_or_not=0
    fi
done


echo "" &>/dev/tty
echo -n "Do you want to make a plot of the prediction? " &>/dev/tty
read plot_answer
let user_want_to_plot=6
if [ $plot_answer = yes ] 
    then
	let user_want_to_plot=1
	echo "A plot will be created in ./out/plots" &>/dev/tty
    elif [ $plot_answer = no ] 
    then
	let user_want_to_plot=0
fi
while [ $user_want_to_plot -ne 1 ]  && [ $user_want_to_plot -ne 0 ]  || [ -z $user_want_to_plot ]  ;do
    echo -n "Do you want to make a plot of the prediction? (yes/no) " &>/dev/tty
    read plot_answer
    let user_want_to_plot=6
    if [ $plot_answer = yes ] 
    then
	let user_want_to_plot=1
	echo "A plot will be created in ./out/plots" &>/dev/tty
    elif [ $plot_answer = no ] 
    then
	let user_want_to_plot=0
    fi
done


echo "" &>/dev/tty
echo -n "Do you want to make a file for the result of the prediction? " &>/dev/tty
read file_answer
let user_want_file=6
if [ $file_answer = yes ] 
    then
	let user_want_file=1
	echo "A file will be created in ./out/files" &>/dev/tty
    elif [ $file_answer = no ] 
    then
	let user_want_file=0
fi
while [ $user_want_file -ne 1 ]  && [ $user_want_file -ne 0 ]  || [ -z $user_want_file ]  ;do
    echo -n "Do you want to make a file for the result of the prediction? (yes/no) " &>/dev/tty
    read file_answer
    let user_want_file=6
    if [ $file_answer = yes ] 
    then
	let user_want_file=1
	echo "A file will be created in ./out/files" &>/dev/tty
    elif [ $file_answer = no ] 
    then
	let user_want_file=0
    fi
done





redirect_output="./out/files/execution_output"


} &>/dev/null

{

month_pred=`echo $month_pred|sed 's/^0*//'`
day_pred=`echo $day_pred|sed 's/^0*//'`
if [ $((10#$hour_pred)) -ne 0 ] 
then
    hour_pred=`echo $hour_pred|sed 's/^0*//'`
else
    hour_pred='0'
fi

let year_pred_nb=$year_pred
let month_pred_nb=$month_pred

let current_year_to_compare_nb=$current_year_to_compare
let current_month_to_compare_nb=$current_month_to_compare
let previous_month_nb=$current_month_to_compare-1


if [ $year_pred_nb = $current_year_to_compare_nb ] 
then
    let same_year_as_today=1
else
    let same_year_as_today=0
fi
if [ $month_pred_nb = $previous_month_nb ]  || [ $month_pred = $current_month_to_compare ] 
then
    let same_month_or_one_month_ago=1
else
    let same_month_or_one_month_ago=0
fi

if [ $same_year_as_today == 1 ]  && [ $same_month_or_one_month_ago == 1 ] 
then ############### USE DATA FROM SWPC

    current_year=$year_pred
    current_month=$month_pred

    calculate_3_last_months

    if [ $one_month_ago -lt 10 ] 
    then
	name_current_month="$current_year""0""$current_month""_ace_swepam_1h.txt"
    else
	name_current_month="$current_year""$current_month""_ace_swepam_1h.txt"
    fi

    if [ $one_month_ago -lt 10 ] 
    then
	name_one_month_ago="$one_year_ago""0""$one_month_ago""_ace_swepam_1h.txt"
    else
	name_one_month_ago="$one_year_ago""$one_month_ago""_ace_swepam_1h.txt"
    fi

    if [ $two_month_ago -lt 10 ] 
    then
	name_two_month_ago="$two_year_ago""0""$two_month_ago""_ace_swepam_1h.txt"
    else
	name_two_month_ago="$two_year_ago""$two_month_ago""_ace_swepam_1h.txt"
    fi


    if [ $next_month -lt 10 ] 
    then
	name_next_month="$next_year""0""$next_month""_ace_swepam_1h.txt"
    else
	name_next_month="$next_year""$next_month""_ace_swepam_1h.txt"
    fi


    echo "" &>/dev/tty
    echo "Downloading data from SWPC..." &>/dev/tty
    echo "" &>/dev/tty


    cd ./data/

    dt0=`curl -u anonymous:cbv@umich.edu -o current_month.txt ftp://ftp.swpc.noaa.gov/pub/lists/ace2/$name_current_month` 
    dt1=`curl -u anonymous:cbv@umich.edu -o one_month_ago.txt ftp://ftp.swpc.noaa.gov/pub/lists/ace2/$name_one_month_ago` 
    dt2=`curl -u anonymous:cbv@umich.edu -o two_months_ago.txt ftp://ftp.swpc.noaa.gov/pub/lists/ace2/$name_two_month_ago`

    if [ $month_pred_nb = $previous_month_nb ]
    then
	dt3=`curl -u anonymous:cbv@umich.edu -o next_month.txt ftp://ftp.swpc.noaa.gov/pub/lists/ace2/$name_next_month`
	let next_month_or_not=1
    else
	let next_month_or_not=0
    fi

    if [ $two_month_ago -lt 10 ]
    then
	name_two_month_ago="0""$two_month_ago"
    else 
	name_two_month_ago="$two_month_ago"
    fi

    if [ $month_pred -lt 10 ]
    then
	month_pred="0""$month_pred"
    else 
	month_pred="$month_pred"
    fi

    if [ $day_pred -lt 10 ]
    then
	day_pred="0""$day_pred"
    else 
	day_pred="$day_pred"
    fi

    if [ $hour_pred -lt 10 ]
    then
	hour_pred="0""$hour_pred"
    else 
	hour_pred="$hour_pred"
    fi

    start_date_chosen="$two_year_ago""$name_two_month_ago""$day_pred""$hour_pred"
    end_date_chosen="$year_pred""$month_pred""$day_pred""$hour_pred"

    cd ../src/

#/Applications/exelis/idl82/bin/
idl -e "convert_spwc_to_omni,'""$end_date_chosen""',""$next_month_or_not"
cd ../data/
rm "current_month.txt" "one_month_ago.txt" "two_months_ago.txt" 
if [ $month_pred_nb = $previous_month_nb ] 
then
    rm "next_month.txt"
fi

cd ../


############### END OF USE DATA FROM SWPC
else ############### USE DATA FROM OMNIWEB


    echo "" &>/dev/tty
    echo "Downloading data from OmniWeb..." &>/dev/tty
    echo "" &>/dev/tty

    current_year=$year_pred
    current_month=$month_pred

    calculate_3_last_months

   
    if [ $two_month_ago -lt 10 ]
    then
	name_two_month_ago="0""$two_month_ago"
    else 
	name_two_month_ago="$two_month_ago"
    fi

    if [ $month_pred -lt 10 ]
    then
	month_pred="0""$month_pred"
    else 
	month_pred="$month_pred"
    fi

    if [ $day_pred -lt 10 ]
    then
	day_pred="0""$day_pred"
    else 
	day_pred="$day_pred"
    fi

    if [ $hour_pred -lt 10 ]
    then
	hour_pred="0""$hour_pred"
    else 
	hour_pred="$hour_pred"
    fi


    if [ $next_month -lt 10 ]
    then
	name_next_month="0""$next_month"
    else
	name_next_month="$next_month"
    fi

    start_date_chosen_download="$two_year_ago""$name_two_month_ago""$day_pred"
    end_date_chosen_for_download="$next_year""$name_next_month""$day_pred"

    end_date_chosen="$year_pred""$month_pred""$day_pred"

    start_date_chosen="$two_year_ago""$name_two_month_ago""$day_pred""$hour_pred"
    end_date_chosen="$year_pred""$month_pred""$day_pred""$hour_pred"    
    name_file_downloaded="PDF_speed""_""$year_pred""-$month_pred""-$day_pred""-$hour_pred""00"".txt"

    let var_chosen="24"

    curl -d  "activity=retrieve&res=hour&spacecraft=omni2&start_date=""$start_date_chosen_download""&end_date=""$end_date_chosen_for_download""&vars=""$var_chosen""&scale=Linear&ymin=&ymax=&view=0&charsize=&xstyle=0&ystyle=0&symbol=0&symsize=&linestyle=solid&table=0&imagex=640&imagey=480&color=&back=" https://omniweb.gsfc.nasa.gov/cgi/nx1.cgi > ./data/$name_file_downloaded
   
# Test if the file from onmiWeb has been successfully downloaded

    word_error=Error
    grep -q "\<$word_error\>" "./data/""$name_file_downloaded" && echo "The data has not been successfully downloaded, probably due to an error in the start/end date(s). Please try to run the script again." &>/dev/tty && exit 1
   

############### END OF USE DATA FROM OMNIWEB
fi
echo "Downloading successfully completed." &>/dev/tty
echo "" &>/dev/tty
echo "The PDF Model is now predicting the speeds for the next 5 days..." &>/dev/tty
echo "" &>/dev/tty



cd ./src/
#/Applications/exelis/idl82/bin/
idl -e "main,""$ensemble_or_not"",""$user_want_to_plot"",""$user_want_file"",'""$end_date_chosen" 

cd ../

###### ASK if want to make a plot and a data results file



if [ $user_want_to_plot -eq 1 ]
then
    name_plot_ps="./out/plots/PDF_speed""_""$year_pred""-$month_pred""-$day_pred""-$hour_pred""00"".ps"
    name_plot_pdf="./out/plots/PDF_speed""_""$year_pred""-$month_pred""-$day_pred""-$hour_pred""00"".pdf"
    ps2pdf $name_plot_ps $name_plot_pdf 
    rm $name_plot_ps 

echo -n "Prediction successfully completed. Do you want to see the plot? " &>/dev/tty
read see_plot_answer
let see_plot=6
if [ $see_plot_answer = yes ] 
then
    open $name_plot_pdf 
    let see_plot=1
elif [ $see_plot_answer = no ] 
then
    let see_plot=0
fi
while [ $see_plot -ne 0 ]  && [ $see_plot -ne 1 ]  || [ -z $see_plot ]  ;do
    echo -n "Prediction successfully completed. Do you want to see the plot? (yes/no) " &>/dev/tty
    read see_plot_answer
    let see_plot=6
    if [ $see_plot_answer = yes ] 
    then
	open $name_plot_pdf 
	let see_plot=1
    elif [ $see_plot_answer = no ]             
    then
	let see_plot=0
    fi
done

fi



echo "" &>/dev/tty
echo "**********************************************" &>/dev/tty
echo "THANK YOU FOR USING THE PDF MODEL. A BIENTOT !" &>/dev/tty
echo "**********************************************" &>/dev/tty
echo "" &>/dev/tty                

name_execution_output="./out/files/execution_output_PDF_speed""_""$year_pred""-$month_pred""-$day_pred""-$hour_pred""00"

}  &> "$redirect_output"

mv ./out/files/execution_output "$name_execution_output" 

