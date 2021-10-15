#!/usr/bin/env sh
temp=`mktemp -d`
OK=0
CANCLE=1
ALL=3
Broadcast=0
ESC=255

delete(){
	rm -r $temp
	return
}
trap_ctrl_c(){
	echo "Ctrl+C pressed." >&1
	delete
	exit 2
}
trap "trap_ctrl_c" 2
Entrance_Page(){
	while : 
	do
		dialog --title "System Info Panel" --extra-button --extra-label "Setting" --cancel-label "EXIT" --menu "Please select the command you want to use" 29 70 30 \
			1 "POST ANNOUNCENT" \
			2 "USER LIST" 2> $temp/tmp_page.txt
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $CANCLE ]; then
			return
		fi
		select=$(cat $temp/tmp_page.txt)
		case $select in
			1)
				Announcement
				;;
			2)
				Users_list
				;;
		esac
	done
}
Announcement(){
	Broadcast=0
	cat /etc/passwd | awk '{split ( $0, a, ":" ); if(a[2] ~/\*/) print a[1] " " a[3] " " $NF}' | awk '{if($NF ~/.*nologin/);else print $2 " " $1 " off "}'| awk '{printf("%s",$0)}' > $temp/user_list.txt
	while :
	do
		dialog --title 'POST ANNOUNCENT' --extra-button --extra-label "ALL" --checklist 'Please choose who you want to post' 29 70 30 `cat $temp/user_list.txt`  2> $temp/select_user.txt
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
	 	if [ $result -eq $CANCLE ]; then
			return
		elif [ $result -eq $ALL ]; then
			Broadcast=1
			Typeing_MSG
			break
		elif [ $result -eq $OK ]; then
			test -s $temp/select_user.txt
			file_no_data=$?
			if [ $file_no_data -eq 1 ]; then
				while :
				do
					dialog --title "POST ANNOUNCENT" --msgbox "You does not select any user." 29 70
					result=$?
					if [ $result -eq $ESC ]; then
						echo "Esc." >&2
						delete
						exit 1
					fi
					if [ $result -eq $OK ]; then
						break
					fi
					break
				done
			elif [ $file_no_data -eq 0 ]; then
				Typeing_MSG
				break
			fi
		fi
		
		
	done
}
Typeing_MSG(){
	while :
	do
		dialog --title "Post an announcement" --inputbox "Enter your meesages:" 10 50 2> $temp/MSG.txt
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $OK ]; then
			test -s $temp/MSG.txt
			file_no_data=$?
			if [ $file_no_data -eq 1 ]; then
				while :
				do
					dialog --title "Post an announcement" --msgbox "You does not type anything." 29 70
					result=$?
					if [ $result -eq $ESC ]; then
						echo "Esc." >&2
						delete
						exit 1
					fi
					if [ $result -eq $OK ]; then
						break
					fi
					break
				done
			elif [ $Broadcast -eq 1 ]; then
				sudo wall $temp/MSG.txt
				return
			else
				for user in `cat $temp/select_user.txt`; do
					USER=`id -nu $user`
					MSG=`cat $temp/MSG.txt`
					echo $MSG | sudo write "$USER"
				done
				return
			fi
		elif [ $result -eq $CANCLE ]; then
			return
		fi
	done
}
Users_list(){
	cat /etc/passwd | awk '{split ( $0, a, ":" ); if(a[2] ~/\*/) print a[1] " " a[3] " " $NF}' | awk '{if($NF ~/.*nologin/);else print $1 " "}'| awk '{printf("%s",$0)}' > $temp/user_Panel.txt
	echo "`who`" | awk '{printf("%s ",$1)}' > $temp/online.txt
	> $temp/user_list_online.txt
	for user in `cat $temp/user_Panel.txt`; do
		same=0
		for online_user in `cat $temp/online.txt`; do
			if [ $online_user = $user ]; then
				same=1
			fi
		done
		if [ $same = 1 ]; then
			echo "`id -u $user` $user[*] " >> $temp/user_list_online.txt
		else
			echo "`id -u $user` $user " >> $temp/user_list_online.txt
		fi
	done
	while :
	do
		dialog --title "" --ok-label "SELECT" --cancel-label "EXIT" --menu "User Info Pannel"  29 70 30 `cat $temp/user_list_online.txt` 2> $temp/user.txt
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $CANCLE ]; then
			return
		fi
		User_action
	done
}
User_action(){
	LOCK=0
	User=`cat $temp/user.txt | xargs -J % id -nu %`
	sudo cat /etc/master.passwd | awk '{split($0, a, "$");print a[1]}' | awk '{split($0, a, ":");if($1 ~/.*LOCKED.*/)print a[1]" "aa[2]}' > $temp/Locked.txt
	for lock in `cat $temp/Locked.txt`; do
		if [ $User = $lock ]; then
			LOCK=1
			break
		fi
	done
	while :
	do
		if [ $LOCK -eq 0 ]; then
			dialog --title "" --ok-label "SELECT" --cancel-label "EXIT" --menu "User `cat $temp/user.txt | xargs -J % id -nu %`" 29 70 30 \
			1 "LOCK IT" \
			2 "GROUP INFO" \
			3 "PORT INFO" \
			4 "LOGIN HISTORY" \
			5 "SUDO LOG" 2> $temp/tmp_action.txt
			result=$?
		elif [ $LOCK -eq 1 ]; then
			dialog --title "" --ok-label "SELECT" --cancel-label "EXIT" --menu "User `cat $temp/user.txt | xargs -J % id -nu %`" 29 70 30 \
			1 "UNLOCK IT" \
			2 "GROUP INFO" \
			3 "PORT INFO" \
			4 "LOGIN HISTORY" \
			5 "SUDO LOG" 2> $temp/tmp_action.txt
			result=$?
		fi
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $CANCLE ]; then
			return
		fi
		select=$(cat $temp/tmp_action.txt)
		case $select in
			1)
				if [ $LOCK -eq 0 ]; then
					Lock
				elif [ $LOCK -eq 1 ]; then
					UNLock
				fi
				LOCK=0
				User=`cat $temp/user.txt | xargs -J % id -nu %`
				sudo cat /etc/master.passwd | awk '{split($0, a, "$");print a[1]}' | awk '{split($0, a, ":");if($1 ~/.*LOCKED.*/)print a[1]" "aa[2]}' > $temp/Locked.txt
				for lock in `cat $temp/Locked.txt`; do
					if [ $User = $lock ]; then
						LOCK=1
						break
					fi
				done
				;;
			2)
				Group 
				;;
			3)
				Port
				;;
			4)
				Login
				;;
			5)
				Sudo_log
				;;
		esac
	done
}
Lock(){
	while :
	do
		dialog --title "LOCK IT" --yesno "Are you sure you want to do this?" 29 70
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $OK ]; then
			sudo pw lock `cat $temp/user.txt`
			dialog --title "LOCK IT" --msgbox "LOCK SUCCEED!" 29 70
			result=$?
			if [ $result -eq $ESC ]; then
				echo "Esc." >&2
				delete
				exit 1
			fi
		fi
		return
	done
}
UNLock(){
	while :
	do
		dialog --title "UNLOCK IT" --yesno "Are you sure you want to do this?" 29 70
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $OK ]; then
			sudo pw unlock `cat $temp/user.txt`
			dialog --title "UNLOCK IT" --msgbox "UNLOCK SUCCEED!" 29 70
			result=$?
			if [ $result -eq $ESC ]; then
				echo "Esc." >&2
				delete
				exit 1
			fi
		fi
		return
	done
}
Group(){
	groups `cat $temp/user.txt` > $temp/group_name.txt
	cat /etc/group | awk '{split($0, a, ":"); print a[1]" "a[3]}' > $temp/group_all.txt
	echo "GROUP_ID GROUP_NAME" > $temp/group_list.txt
	for group in `cat $temp/group_name.txt`; do
		Find=0
		for group_A in `cat $temp/group_all.txt`; do
			if [ $Find -eq 1 ]; then
				echo $group_A | awk '{printf("%s ", $0)}' >> $temp/group_list.txt
				break
			fi
			if [ $group_A = $group ]; then
				Find=1
			fi
		done
		echo $group >> $temp/group_list.txt
	done
	while :
	do
		dialog --title "GROUP"  --exit-label "OK" --extra-button --extra-label "Export"  --textbox $temp/group_list.txt 29 70
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $OK ]; then
			return
		elif [ $result -eq $ALL ]; then
			cat $temp/group_list.txt > $temp/output.txt
			File_Locate
		fi
	done
}
File_Locate(){
	while :
	do
		dialog --title "Export to file" --inputbox "Enter the path:" 29 70 2> $temp/locate.txt
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $OK ]; then
			echo $HOME | awk '{printf("%s",$0)}' > $temp/dir.txt
			if [ `cat $temp/locate.txt | cut -c1-1` = "~" ]; then
				cat $temp/locate.txt | cut -c2- >> $temp/dir.txt
			else
				cat $temp/locate.txt > $temp/dir.txt
			fi
			cat $temp/output.txt > `cat $temp/dir.txt`
			fail=$?
			if [ $fail -ne 0 ]; then
				dialog --title "Export to file" --msgbox "Fail! Error directory or file type." 29 70
			fi
		fi
		return
	done
}
Port(){
	User=`cat $temp/user.txt | xargs -J % id -nu %`
	sockstat -4 -P tcp,udp | awk '{print $1" "$3" "$5" "$6}' > $temp/port_all.txt
	>$temp/port_used.txt
	i=""
	for port in `cat $temp/port_all.txt`; do
		if [ $(echo -n "$i"| wc -m) -eq 0 ] && [ $port == $User ]; then
			i="0"
		elif [ $(echo -n "$i"| wc -m) -eq 1 ]; then
			i="00"
			echo $port | awk '{printf("%s ",$0)}' >> $temp/port_used.txt
		elif [ $(echo -n "$i"| wc -m) -eq 2 ]; then
			i="000"
			echo $port | awk '{printf("%s_",$0)}' >> $temp/port_used.txt
		elif [ $(echo -n "$i"| wc -m) -eq 3 ]; then
			i=""
			echo $port | awk '{printf("%s ", $0)}'>> $temp/port_used.txt
		else
			echo $port > $temp/fail.txt
		fi
	done
	test -s $temp/port_used.txt
	file_no_data=$?
	if [ $file_no_data -eq 1 ]; then
		while :
		do
			dialog --title "Port INFO(PID and Port)" --msgbox "This user does not use any port now." 29 70
			result=$?
			if [ $result -eq $ESC ]; then
				echo "Esc." >&2
				delete
				exit 1
			fi
			if [ $result -eq $OK ]; then
				return
			fi
			return
		done
	fi
	while :
	do
		
		dialog --title "Port INFO(PID and Port)" --menu ""  -- 29 70 30 `cat $temp/port_used.txt` 2> $temp/port_select.txt
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $OK ]; then
			Process
		elif [ $result -eq $CANCLE ]; then
			return
		fi
	done
}
Process(){
	ps -c -v -j `cat $temp/port_select.txt` | awk '{print $1" "$2" "$11" "$12" "$13" "$14" "$15}' > $temp/port_info.txt
	cat $temp/port_info.txt | awk '{if($1 ~/PID/);else print $1}' > $temp/tmp_PID.txt
	cat $temp/port_info.txt | awk '{if($2 ~/STAT/);else print $2}' > $temp/tmp_STAT.txt
	cat $temp/port_info.txt | awk '{if($3 ~/%CPU/);else print $3}'> $temp/tmp_CPU.txt
	cat $temp/port_info.txt | awk '{if($4 ~/%MEM/);else print $4}' > $temp/tmp_MEM.txt
	cat $temp/port_info.txt | awk '{if($5 ~/COMMAND/);else print $5}' > $temp/tmp_CMD.txt
	cat $temp/port_info.txt | awk '{if($7 ~/PPID/);else print $7}'> $temp/tmp_PPID.txt
	cat $temp/user.txt | xargs -J % id -nu % | awk '{print "USER "$0}' > $temp/port_data.txt
	cat $temp/tmp_PID.txt | awk '{print "PID "$0}' >> $temp/port_data.txt
	cat $temp/tmp_PPID.txt | awk '{print "PPID "$0}' >> $temp/port_data.txt
	cat $temp/tmp_STAT.txt | awk '{print "STAT "$0}' >> $temp/port_data.txt
	cat $temp/tmp_CPU.txt | awk '{print "%CPU "$0}' >> $temp/port_data.txt
	cat $temp/tmp_MEM.txt | awk '{print "%MEM "$0}' >> $temp/port_data.txt
	cat $temp/tmp_CMD.txt | awk '{print "COMMAND "$0":"}' >> $temp/port_data.txt
	while :
	do
		dialog --title "PROCESS STATE: `cat $temp/port_select.txt`"  --exit-label "OK" --extra-button --extra-label "Export"  --textbox $temp/port_data.txt 29 70
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $OK ]; then
			return
		elif [ $result -eq $ALL ]; then
			cat $temp/port_data.txt > $temp/output.txt
			File_Locate
		fi
	done
}
Login(){
	last -n 10 `cat $temp/user.txt | xargs -J % id -nu %` | awk '{if($0 ~/^$/)nextfile;else if($2 ~/ttyv0/)print $3" "$4" "$5" "$6;else print $4" "$5" "$6" "$7" "$3}' > $temp/login.txt
	test -s $temp/login.txt
	file_no_data=$?
	if [ $file_no_data -eq 1 ]; then
		while :
		do
			dialog --title "LOGIN HISTORY" --msgbox "There is no login history." 29 70
			result=$?
			if [ $result -eq $ESC ]; then
				echo "Esc." >&2
				delete
				exit 1
			fi
			if [ $result -eq $OK ]; then
				return
			fi
			return
		done
	fi
	while :
	do
		dialog --title "LOGIN HISTORY"  --exit-label "OK" --extra-button --extra-label "Export"  --textbox $temp/login.txt 29 70
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $OK ]; then
			return
		elif [ $result -eq $ALL ]; then
			cat $temp/login.txt > $temp/output.txt
			File_Locate
		fi
	done
}
Sudo_log(){
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
	file_no_data=$?
	if [ $file_no_data -eq 1 ]; then
		while :
		do
			dialog --title "SUDO LOG" --msgbox "This user did not use sudo in recent 30 days." 29 70
			result=$?
			if [ $result -eq $ESC ]; then
				echo "Esc." >&2
				delete
				exit 1
			fi
			if [ $result -eq $OK ]; then
				return
			fi
			return
		done
	fi
	while :
	do
		dialog --title "SUDO LOG"  --exit-label "OK" --extra-button --extra-label "Export"  --textbox $temp/sudo_log.txt 29 70
		result=$?
		if [ $result -eq $ESC ]; then
			echo "Esc." >&2
			delete
			exit 1
		fi
		if [ $result -eq $OK ]; then
			return
		elif [ $result -eq $ALL ]; then
			cat $temp/sudo_log.txt > $temp/output.txt
			File_Locate
		fi
	done
}

Entrance_Page
echo "Exit." >&1
delete
exit 0