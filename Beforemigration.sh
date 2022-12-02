echo -n User:
read user
echo -n Password:
read -s pass

(
echo HostIP

ip=$(hostname -I | awk '{print $1}')
echo ${ip}

echo show slave status:

mysql -u $user -p$pass -se "show slave status\G"
echo ==================================================================
echo show master status:
mysql -u $user -p$pass -se "show master status\G"

echo ==================================================================
echo mysql connection user count

mysql -u $user -p$pass -se "select count(*) from information_schema.processlist order by db;"

echo ==================================================================
echo mysql connection  user db

mysql -u $user -p$pass -se "set session sql_mode='';Select count(*) as Count ,DB,SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(HOST,'.',3),'.',2),'.',-4) as 'IP' from information_schema.processlist where user not in ('system user') group by ip,DB order by count desc;"

echo ==================================================================
echo binlog_format

mysql -u $user -p$pass -se "show global variables like '%binlog_format%';"
echo ==================================================================
echo super_read_only

mysql -u $user -p$pass -se "show global variables like '%super_read_only%';"
echo ==================================================================
echo Binlog

mysql -u $user -p$pass -se "show global variables like 'log_bin';"
echo ==================================================================
echo sql_mode

mysql -u $user -p$pass -se "show global variables like '%sql_mode%';"

) > beforemigration.sql
