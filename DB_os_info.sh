#!/usr/bin/env bash
# Bash script to collect Remote Machine Details over ssh,
# Requirements: sshpass package needs to be installed on collector machine.
# Input: Hostname/IP Address & Username & Password
# Output: stored in DB_OS_Info.csv file as well as displayed on the screen in DEBUG mode
#Hostname/Remote IP Address
read -p "Enter the Hostname/IP Address: " hostname
#Remote User
read -p "Enter UserName: " user
#Password
#read -p "Enter Password: " pass
# Run mysql commands with sudo or not?
read -p "Run mysql commands with sudo[yes/no]: " choice
if [ "$choice" = "yes" ];
then
prefix="sudo "
echo "Running script with " $prefix
else
echo "Running without sudo"
fi
#Debugging Purpose
#echo $hostname $user $pass
#Pass='read12345'

### Commands to be run on remote server ###
CPU="cat /proc/cpuinfo | grep processor | wc -l"
#COREperSock="cat /proc/cpuinfo | grep 'cpu cores'|head -1|cut -d ':' -f2"
#CPUModel="cat /proc/cpuinfo | grep 'model name' | head -1|cut -d ':' -f2|tr -d ' '"
RAM="free -gt | grep 'Mem:'| awk -F ' ' '{print \$2}'"
OSVer="uname -i"
OSEd="(lsb_release -ds 2>/dev/null || cat /etc/*release 2>/dev/null | grep 'PRETTY_NAME' | cut -d '=' -f2) | awk -F '\"' '{ print $2 }'"
HOSTNAME="hostname"
DBVersion="mysql -V|cut -d ' ' -f 6|cut -d ',' -f 1|cut -c-3"
DBPatchLevel="mysql -V|cut -d ' ' -f 6|cut -d ',' -f 1"

DBName=$prefix"mysql -udbreader -pread12345  -e \"select distinct TABLE_SCHEMA as DatabaseName from information_schema.TABLES where TABLE_SCHEMA not in ('mysql','test','sys','information_schema','performance_schema')\"|awk '{print $1}' | tr '\n' ';'"
DBCount=$prefix" mysql -udbreader -pread12345  -e \"select count(distinct TABLE_SCHEMA) as DBCount from information_schema.TABLES where TABLE_SCHEMA not in ('mysql','test','sys','information_schema','performance_schema')\"|cut -d '|' -f 1|awk 'NR == 2 {print $1}'"
#DBSize="mysql -udbreader -pread12345 -e \"SELECT table_schema "Data Base Name", sum( data_length + index_length ) / 1024 / 1024 "Data Base Size in MB" FROM information_schema.TABLES GROUP BY table_schema'\""
DBSize=$prefix"mysql -udbreader -pread12345  -e \"select sum(data_length + index_length)/1024/1024 as DBSize from information_schema.TABLES where TABLE_SCHEMA not in ('mysql','test','sys','information_schema','performance_schema') GROUP BY table_schema \"|awk '{print $1}' | tr '\n' ';'"
DBPort=$prefix"mysql -udbreader -pread12345 -e \"SELECT @@port\"|awk 'NR == 2'"
#MountSize="ps -ef|grep mysqld|awk '{print \$10}'|cut -d '' -f1|awk 'NR == 2 {print \$1}'|cut -d '=' -f2 | cut -d '/' -f2 | xargs -I 'mount' df -h /mount | awk 'BEGIN{OFS=\",\";} NR==2 {print \$2,\$3,\$4;}'"
MountSize="ps -ef|grep mysqld|awk '{print \$10}'|cut -d '' -f1|awk 'NR == 2 {print $1}'|cut -d '=' -f2 | cut -d '/' -f2 | xargs -I 'mount' df -h /mount | awk 'BEGIN{OFS=\",\";} NR==2 {print \$2,\$3,\$4;}'"
Replication="/bin/echo NA"
HADR="echo NA"
LastSuccessfulBackup="/bin/echo NA"
DBMemory=$prefix"mysql -udbreader -pread12345 -e 'SELECT (@@key_buffer_size + @@query_cache_size + @@innodb_buffer_pool_size + @@innodb_additional_mem_pool_size + @@innodb_log_buffer_size + @@read_buffer_size + @@read_rnd_buffer_size + @@sort_buffer_size + @@join_buffer_size + @@binlog_cache_size + @@thread_stack)/(1024 * 1024 * 1024) AS DB_MEMORY_GB;'|awk 'NR==2'"

### End Commands List ###

#host=`sshpass -p $pass ssh -o StrictHostKeyChecking=no  $user@$hostname $HOSTNAME `
#cpu=`sshpass -p $pass ssh -o StrictHostKeyChecking=no  $user@$hostname $CPU`
#core=`sshpass -p $pass ssh -o StrictHostKeyChecking=no  $user@$hostname $COREperSock`
#model=`sshpass -p $pass ssh -o StrictHostKeyChecking=no  $user@$hostname $CPUModel`
#ramkb=`sshpass -p $pass ssh -o StrictHostKeyChecking=no  $user@$hostname $RAM`
#osver=`sshpass -p $pass ssh -o StrictHostKeyChecking=no  $user@$hostname $OSVer`
#osed=`sshpass -p $pass ssh -o StrictHostKeyChecking=no  $user@$hostname $OSEd`

#echo $ramkb

#ramgb=`echo "scale=2; $ramkb / 1000^2" | bc`

#echo $host
#echo $cpu
#echo $core
#echo $model
#echo $ramgb
#echo $osver
#echo $osed

#echo "Appending to csv file..."
#echo $host,$cpu,$core,$model,$ramgb,$osver,$osed >> output.csv


### SSH Query to remote server ###
out=`ssh -o StrictHostKeyChecking=no  $user@$hostname /bin/bash << EOF
$HOSTNAME;echo ',';
$DBName;echo ',';
$DBSize;echo ',';
$DBCount;echo ',';
$DBVersion;echo ','
$DBPort;echo ',';
$DBMemory;echo ',';
$DBPatchLevel;echo ',';
$MountSize;echo ',';
$LastSuccessfulBackup;echo ',';
$Replication;echo ',';
$HADR;echo ',';
$OSEd;echo ',';
$OSVer;echo ',';
$CPU;echo ',';
$RAM;

EOF`

### End SSH Body ###

#Debugging Purpose
echo $out

### Data Values Extraction from out variable generated from SSH Command ###

HOSTNAME=`echo $out | cut -d ',' -f1`
#DBName is converted to array subsequently
db=`echo $out | cut -d ',' -f2`
size=`echo $out | cut -d ',' -f3`
#$DBName;echo ',';
#$DBSize;echo ',';
DBCount=`echo $out | cut -d ',' -f4`
DBVersion=`echo $out | cut -d ',' -f5`
DBPort=`echo $out | cut -d ',' -f6`
DBMemory=`echo $out | cut -d ',' -f7`
DBPatchLevel=`echo $out | cut -d ',' -f8`
#Mount Point - Total Size, Consumed, Free
MountSize=`echo $out | cut -d ',' -f9-11`
LastSuccessfulBackup=`echo $out | cut -d ',' -f12`
Replication=`echo $out | cut -d ',' -f13`
HADR=`echo $out | cut -d ',' -f14`
OSEd=`echo $out | cut -d ',' -f15| tr '"' ' '`
OSVer=`echo $out | cut -d ',' -f16`
CPU=`echo $out | cut -d ',' -f17`
RAM=`echo $out | cut -d ',' -f18`


### End Extraction ###

### Array of Databases and corresponding size in MB ##
db_arr=(`echo $db | tr ';' ' '`)
size_arr=(`echo $size | tr ';' ' '`)
### End Array Init ##

### For Loop Body ###
# Calculate count of array execution
len=${#db_arr[@]}

### If Output File not exists then create one ###
if [ ! -f DB_OS_Info.csv ]; then
echo "Hostname,DBName,DBSize,DBCount,DBVersion,DBPort,DBMemory,DBPatchLevel,DBMountTotalSize,DBMountUsedSize,DBMountFree,LastSuccessfulBackup,Replication-Mirroring,HADR,OSEd,OSVersion,CPU#,RAMSize" > DB_OS_Info.csv
fi
### File Creation Complete ###

for (( i=1; i<$len; i++))
do
echo $HOSTNAME, ${db_arr[$i]}, ${size_arr[$i]}, $DBCount, $DBVersion, $DBPort, $DBMemory, $DBPatchLevel , $MountSize, $LastSuccessfulBackup, $Replication, $HADR, $OSEd,$OSVer, $CPU, $RAM >> DB_OS_Info.csv
done

### End For Loop ###
### End of Script #####
