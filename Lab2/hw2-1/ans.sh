# Class: 1101 計算機系統管理 曾建超 曾亮齊
# Author: 陳品劭 109550206
# Date: 20211010
#!/bin/sh
sudo cat /var/log/auth.log | awk '{if($5 ~/ssh*/ && $6 ~/error/) print $11 " " $13 " failed to log"; else if($5 ~/sudo*/) print }' | awk '{split ( $0, a, "COMMAND=" ) ; if($5 ~/sudo*/) print $6 " used sudo to do `" a[2] "` on " $1 " " $2 " " $3; else print}' | awk '{if($3 ~/failed/)map[$1]++ mapIP[$2]++;else print}END{for(k in map){print k" failed to log in "map[k]" times"} for(j in mapIP){print j" failed to log in "mapIP[j] " times"} } ' | sed -e '/used/w audit_sudo.txt' -e '/\..*failed/w audit_ip.txt' -e '/[^0-9] failed/w audit_user.txt'
