#!/bin/sh

echo -n User:
read user
echo -n Password:
read -s pass




[[ ! -d dbdatachecker  ]] && mkdir dbdatachecker
[[ -d dbdatachecker ]] && cd dbdatachecker




while true
do

        (
        echo ==================================================================
        echo show full processlist:

        mysql -u $user -p$pass -se  "show full processlist" | grep -v Sleep


        echo ==================================================================
        echo Locking Query:


        mysql -u $user -p$pass -se  "SELECT r.trx_id waiting_trx_id,r.trx_mysql_thread_id waiting_thread,r.trx_query waiting_query,b.trx_id blocking_trx_id,b.trx_mysql_thread_id blocking_thread,b.trx_query blocking_query FROM performance_schema.data_lock_waits w INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_engine_transaction_id INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_engine_transaction_id;"

        echo ==================================================================
        echo Master status:

        mysql -u $user -p$pass -se "show master status\G"

        echo ==================================================================
        echo Slave status:


        mysql -u $user -p$pass -se "show slave status\G"

        echo ==================================================================
        echo User,Host in processlist:

        mysql -u $user -p$pass -se "select count(*),user,db from information_schema.processlist group by COMMAND;"
        
        echo ==================================================================
        echo Transaction: InnoDB History Length:

        mysql -u $user -p$pass -se "select name, count from information_schema.INNODB_METRICS where name like '%hist%';"


        echo ==================================================================
        echo IOPS:

        iostat -x
        
        
        )>"$(date +"%Y_%m_%d_%I_%M_%p").log"
sleep 60
done
