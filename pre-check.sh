#!/bin/sh

echo -n User:
read user
echo -n Password:
read -s pass




[[ ! -d precheck  ]] && mkdir precheck
[[ -d precheck ]] && cd precheck





(
echo ==================================================================
echo Hostname:

hostname -I


echo ==================================================================
echo Version:

cat /etc/os-release | grep VERSION

echo ==================================================================
echo Core:

lscpu | grep  'CPU(s):'

echo ==================================================================
echo Ram and Swap:

free -h


echo ==================================================================
echo Disk:

df -h


echo ==================================================================
echo Mysql cnf:

cat /etc/my.cnf

echo ==================================================================
echo Filter in cnf:

cat /etc/my.cnf | grep 'skip_slave';cat /etc/my.cnf | grep 'read_only';cat /etc/my.cnf | grep 'binlog-do';cat /etc/my.cnf | grep 'replicate-';cat /etc/my.cnf | grep 'sql_mode';cat /etc/my.cnf | grep 'log-slave-updates';

echo ==================================================================
echo Count of Database,Table,triggers,foreign:key:


mysql -u $user -p$pass -e  "select count(*) as 'Table' from information_schema.tables where table_schema not in ('mysql','information_schema','performance_schema','sys') and table_type<>'VIEW'; select count(*) as 'Trigger' from information_schema.triggers where trigger_schema not in('mysql','sys','information_schema','performance_schema');select count(*) Routine from information_schema.routines where routine_schema not in ('mysql','sys','information_schema','performance_schema');select count(*) Event  from information_schema.events where event_schema not in ('mysql','sys','information_schema','performance_schema');select count(*) View from information_schema.tables where table_schema not in ('mysql','information_schema','performance_schema','sys') and table_type ='VIEW';select count(*) as Foreign_key from information_schema.KEY_COLUMN_USAGE where TABLE_SCHEMA not in ('mysql','performance_schema','information_schema','sys')and POSITION_IN_UNIQUE_CONSTRAINT =1;SELECT count(*) as Database_count FROM information_schema.SCHEMATA where SCHEMA_NAME not in ('information_schema','performance_schema','mysql','sys');"

echo ==================================================================
echo Table Datanase,schema,collection:

mysql -u $user -p$pass -se "select TABLE_SCHEMA, TABLE_NAME,TABLE_COLLATION from information_schema.tables where table_schema not in ('mysql','information_schema','performance_schema','sys') and table_type<>'VIEW';"

echo ==================================================================
echo Size of Database:

mysql -u $user -p$pass -se "SELECT table_schema AS 'Database',ROUND(SUM(data_length + index_length) / 1024 / 1024 /1024 ,2) AS 'Size (GB)' FROM information_schema.TABLES where table_schema  not in ('information_schema','mysql','performance_schema','sys') GROUP BY table_schema;"

echo ==================================================================
echo Important variables:

mysql -u $user -p$pass -se "show GLOBAL VARIABLES WHERE Variable_name in ('log_slave_updates','collation_connection','collation_database','collation_server','character_set_client','character_set_connection','character_set_database','character_set_filesystem','character_set_results','character_set_server','character_set_system','character_sets_dir','default_collation_for_utf8mb4','innodb_io_capacity','innodb_io_capacity_max','sql_mode','innodb_flush_log_at_trx_commit','sync_binlog');"

echo ==================================================================
echo User,Host in Mysql:

mysql -u $user -p$pass -se "select user,host from mysql.user where user not in ('mysql.infoschema','mysql.session','mysql.sys','pmm_monitoring','jusdb')order by user;"


echo ==================================================================
echo Checking MyISAM:

mysql -u $user -p$pass -se "SELECT table_schema,table_name, engine ,table_collation FROM information_schema.tables WHERE table_schema not in ('information_schema','performance_schema','mysql','sys') and not engine = 'InnoDB' ORDER BY table_name DESC;"

)>precheckdata
