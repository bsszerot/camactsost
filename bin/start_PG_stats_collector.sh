#!/usr/bin/bash
#exit 0 ; 

. /home/cragr/crypto_agregator/conf/bash_parameter.cragregator
CURR_DT=`date "+%Y%m%d%H%M%S"`

echo "cragran $CURR_DT start_PG_stats_collector - старт коллектора SAH ..." >> $LOG_MAIN_FILE

#echo $0
#ps -ef | grep -v "grep" | grep $0

IS_STARTED=`ps -ef | grep -v grep | grep start_PG_stats_collector.sh | wc -l `
if [ $IS_STARTED -gt 1 ] && [ -f $LOCK_DIR/start_PG_stats_collector ]; then
   echo "cragran $CURR_DT start_PG_stats_collector -- уже стартовано, ничего не делаем ..." >> $LOG_MAIN_FILE
   exit 1 ;
   fi

echo > $LOCK_DIR/start_PG_stats_collector
ls -l $LOCK_DIR/start_PG_stats_collector
export PGPASSWORD="$PG_PASSWORD" ;

psql -U $PG_USER -h $PG_HOST -d $PG_DB <<EEOF
update bestat_sa_history_parameters set sz_value = 'yes' where sz_parameter = 'is_collect' ;
CALL bestat_fill_sa_history(10) ;
EEOF

echo "cragran $CURR_DT start_PG_stats_collector -- функция отработала, удаляю файл блокировки ..." >> $LOG_MAIN_FILE
rm -f $LOCK_DIR/start_PG_stats_collector

echo "cragran $CURR_DT start_PG_stats_collector - стоп коллектора SAH ..." >> $LOG_MAIN_FILE
