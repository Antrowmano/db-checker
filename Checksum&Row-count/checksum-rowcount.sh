echo -n User:
read user
echo -n Password:
read -s pass

[[ -d checksum ]] && cd checksum
[[ ! -d checksum  ]] && mkdir checksum && cd checksum

ip=$(hostname -i | awk -F. -v OFS=. '{print $3,$4'})

mysql -u $user -p$pass -sNe "select concat('checksum table ',table_schema,'.',table_name,';') from information_schema.tables where table_schema not in ('information_schema','sys','performance_schema','mysql') and table_name not like '%archive%';" > checksum.sql

mysql -u $user -p$pass -sN  < /home/antrowjs/countsql.sql > count.sql

mysql -u $user -p$pass  < count.sql >${ip}"_count".log 2>count.err

mysql -u $user -p$pass -sN < checksum.sql >${ip}"_checksum".log 2>checksum.err

#cd checksum
sort ${ip}"_checksum".log > ${ip}"_checksum_sort".log

sort ${ip}"_count".log > ${ip}"_count_sort".log
