#no ithems

0 "root" off \
0 "toor" off \
66 "uucp" off \
1001 "pin" off \
1002 "judge" off

cat user_list.txt | xargs -J % -n1 dialog --title 'POST ANNOUNCENT' --extra-button --extra-label "ALL" --checklist 'Please choose who you want to post' 29 70 30 %
			--file user_list.txt 2> tmp_announcement.txt
for user in `cat select_user.txt`; do
echo `cat /etc/passwd | awk '{split ( $0, a, ":" ); if(a[3] ~/$user/) print}'`
done




Port(){
	while :
	do
		dialog --title "" --menu "User Info Pannel" 29 70 2 \
			1001 "vargrant" \
			1002 "user1" 2> test.txt
		result=$?
	done
}

if [ $Month = "Jan" ]; then
echo "Date "$Month" Dev "$Day > $temp/sudo_log2.txt
elif [ $Month = "Feb" ]; then
echo "Date "$Month" Jan "$Day > $temp/sudo_log2.txt
elif [ $Month = "Mar" ]; then
echo "Date "$Month" Febv "$Day > $temp/sudo_log2.txt
elif [ $Month = "Apr" ]; then
echo "Date "$Month" Mar "$Day > $temp/sudo_log2.txt
elif [ $Month = "May" ]; then
echo "Date "$Month" Apr "$Day > $temp/sudo_log2.txt
elif [ $Month = "Jun" ]; then
echo "Date "$Month" May "$Day > $temp/sudo_log2.txt
elif [ $Month = "Jul" ]; then
echo "Date "$Month" Jun "$Day > $temp/sudo_log2.txt
elif [ $Month = "Aug" ]; then
echo "Date "$Month" Jul "$Day > $temp/sudo_log2.txt
elif [ $Month = "Sep" ]; then
echo "Date "$Month" Aug "$Day > $temp/sudo_log2.txt
elif [ $Month = "Oct" ]; then
echo "Date "$Month" Sep "$Day > $temp/sudo_log2.txt
elif [ $Month = "Nov" ]; then
echo "Date "$Month" Oct "$Day > $temp/sudo_log2.txt
elif [ $Month = "Dev" ]; then
echo "Date "$Month" Nov "$Day > $temp/sudo_log2.txt
fi


cat $temp/user.txt | xargs -J % id -nu % | awk '{print "USER_TEMP "$0}'> $temp/sudo_log1.txt
Month=`date|awk '{print $2}'`
Day=`date|awk '{print $3}'`
if [ $Month = "Jan" ]; then
echo "Date "$Month" Dev "$Day > $temp/sudo_log2.txt
elif [ $Month = "Feb" ]; then
echo "Date "$Month" Jan "$Day > $temp/sudo_log2.txt
elif [ $Month = "Mar" ]; then
echo "Date "$Month" Febv "$Day > $temp/sudo_log2.txt
elif [ $Month = "Apr" ]; then
echo "Date "$Month" Mar "$Day > $temp/sudo_log2.txt
elif [ $Month = "May" ]; then
echo "Date "$Month" Apr "$Day > $temp/sudo_log2.txt
elif [ $Month = "Jun" ]; then
echo "Date "$Month" May "$Day > $temp/sudo_log2.txt
elif [ $Month = "Jul" ]; then
echo "Date "$Month" Jun "$Day > $temp/sudo_log2.txt
elif [ $Month = "Aug" ]; then
echo "Date "$Month" Jul "$Day > $temp/sudo_log2.txt
elif [ $Month = "Sep" ]; then
echo "Date "$Month" Aug "$Day > $temp/sudo_log2.txt
elif [ $Month = "Oct" ]; then
echo "Date "$Month" Sep "$Day > $temp/sudo_log2.txt
elif [ $Month = "Nov" ]; then
echo "Date "$Month" Oct "$Day > $temp/sudo_log2.txt
elif [ $Month = "Dev" ]; then
echo "Date "$Month" Nov "$Day > $temp/sudo_log2.txt
fi
sudo cat /var/log/auth.log | awk '{ if($5 ~/sudo*/) print }' >> $temp/sudo_log2.txt
cat $temp/sudo_log2.txt | awk '{if($1~/Date/){Mon1=$2;Mon2=$3;Day=$4};if($1==Mon1) print ;else if($1==Mon2 && $2 > Day) print}' > $temp/sudo_log3.txt
cat $temp/sudo_log3.txt | awk '{split ( $0, a, "COMMAND=" ) ; if($5 ~/sudo*/) print $6 " used sudo to do `" a[2] "` on " $1 " " $2 " " $3; else print}' >> $temp/sudo_log1.txt
cat $temp/sudo_log1.txt | awk '{if($1~/USER_TEMP/)User=$2;else if($1==User)print}' > $temp/sudo_log.txt
test -s $temp/sudo_log.txt
