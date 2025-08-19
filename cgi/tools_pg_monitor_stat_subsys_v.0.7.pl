#!/usr/bin/perl

# open source soft - (C) 2025 CAMActSoSt BESST - in last part of (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
require "/var/www/camactsost/cgi/common_parameter.camactsost" ;
require "$camactsost_dir_lib/lib_common_func.pl" ;
require "$camactsost_dir_lib/lib_camactsost_pg_monitor.pl" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;
if ( $pv{ds_type} eq "" ) { $pv{ds_type} = "DB" ; }

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;

print "Content-Type: text/html\n\n" ;

print_header_1_1_cgi() ;
print "MON ZRT КрАгрАн БЕССТ" ;
print_header_1_2_cgi() ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
print_header_2_1_cgi() ;

$common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;
print_pg_monitor_main_page_title("Статистики подсистем: ", "---") ;

print_js_block_pg_monitor() ;

# этот блок нужен для сохранения данных в полях конкретных объектов при вызове JS функций
print "<SPAN STYLE=\"visibility: collapse;\">" ;
print "<INPUT TYPE=\"hidden\" NAME=\"sess_state_filter\" ID=\"id_sess_state_filter\" VALUE=\"$pv{sess_state_filter}\">
       <INPUT TYPE=\"hidden\" NAME=\"db_filter\" ID=\"id_db_filter\" VALUE=\"$pv{dbid}\">
       <INPUT TYPE=\"hidden\" NAME=\"period_date_start\" ID=\"id_period_date_start\" VALUE=\"$pv{period_from}\">
       <INPUT TYPE=\"hidden\" NAME=\"pid\" ID=\"id_pid\" VALUE=\"$pv{pid}\">
       <INPUT TYPE=\"hidden\" NAME=\"serial\" ID=\"id_serial\" VALUE=\"$pv{serial}\">
       <INPUT TYPE=\"hidden\" NAME=\"query_id\" ID=\"id_query_id\" VALUE=\"$pv{query_id}\">
       <INPUT TYPE=\"hidden\" NAME=\"plan_hash\" ID=\"id_plan_hash\" VALUE=\"$pv{plan_hash}\">
       <INPUT TYPE=\"hidden\" NAME=\"period_date_stop\" ID=\"id_period_date_stop\" VALUE=\"$pv{period_to}\">
       <INPUT TYPE=\"hidden\" NAME=\"is_user_backends\" ID=\"id_is_user_backends\" VALUE =\"$pv{is_user_backends}\">
       <INPUT TYPE=\"hidden\" NAME=\"is_backgrounds\" ID=\"id_is_backgrounds\" VALUE=\"$pv{is_backgrounds}\">
       <INPUT TYPE=\"hidden\" NAME=\"is_extensions\" ID=\"id_is_extensions\" VALUE=\"$pv{is_extensions}\">
       <INPUT TYPE=\"hidden\" NAME=\"ds_type\" ID=\"id_ds_type\" VALUE=\"$pv{ds_type}\"> " ;
print "</SPAN>" ;

print_tools_pg_main_navigation(4) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>" ;
if ( $pv{tab_detail} eq "" ) { $pv{tab_detail} = 1 ; }
print_tools_pg_monitor_stat_subsys_detail($pv{tab_detail}) ;

print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;

if ($pv{child_tab_detail} eq "") { $pv{child_tab_detail} = "1" ; }
#print_tools_pg_monitor_stat_tab_child_detail($pv{child_tab_detail}) ;

if ($pv{tab_detail} == 1) {
   print_stat_snap_filters() ;
   if ($pv{stat_src_type} eq "range" && $pv{stat_is_graph_out} eq "true") { set_common_pg_mon_cgi_prefix() ;
       print "<BR><TABLE BORDER=\"1\" STYLE=\"text-align: left; width: 1100pt; border: 1pt navy; border-style: solid;\">" ;
       print "<TR><TD CLASS=\"td_left\">Бэкэндов в моменте<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=numbackends&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      numbackends</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=numbackends\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=numbackends\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Транзаций завершено COMMIT<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=xact_commit&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      xact_commit</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=xact_commit\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=xact_commit\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Транхзакций откачено ROLLBACK<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=xact_rollback&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      xact_rollback</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=xact_rollback\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=xact_rollback\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Чтения физические, блоков<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blks_read&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      blks_read</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blks_read\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blks_read\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Чтения из кэша, блоков<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blks_hit&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      blks_hit</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blks_hit\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blks_hit\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Записей возвращено<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_returned&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      tup_returned</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_returned\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_returned\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Записей забрано<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_fetched&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      tup_fetched</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_fetched\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_fetched\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Записей вставлено<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_inserted&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      tup_inserted</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_inserted\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_inserted\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Записей обновлено<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_updated&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      tup_updated</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_updated\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_updated\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Записей удалено<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_deleted&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      tup_deleted</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_deleted\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=tup_deleted\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Конфликтов<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=conflicts&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      conflicts</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=conflicts\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=conflicts\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Временное пространство, файлов<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=temp_files&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      temp_files</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=temp_files\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=temp_files\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Временное пространство, байт<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=temp_bytes&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      temp_bytes</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=temp_bytes\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=temp_bytes\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Взаимоблокировок<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=deadlocks&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      deadlocks</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=deadlocks\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=deadlocks\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Ошибок контрольных сумм, единиц<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=checksum_failures&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      checksum_failures</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=checksum_failures\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=checksum_failures\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Чтение, миллисекунды<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blk_read_time&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      blk_read_time</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blk_read_time\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blk_read_time\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Запись, миллисекунды<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blk_write_time&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      blk_write_time</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blk_write_time\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=blk_write_time\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Сессии, миллисекунды<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=session_time&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      session_time</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=session_time\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=session_time\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Активность, миллисекунды<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=active_time&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      active_time</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=active_time\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=active_time\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Простой в транзакциях, миллисекунды<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=idle_in_transaction_time&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      idle_in_transaction_time</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=idle_in_transaction_time\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=idle_in_transaction_time\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Сессий, единиц<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      sessions</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Сессий заброшено, единиц<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions_abandoned&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      sessions_abandoned</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions_abandoned\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions_abandoned\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Сессий fatal, единиц<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions_fatal&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      sessions_fatal</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions_fatal\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions_fatal\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Сессий убито, единиц<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions_killed&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      sessions_killed</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions_killed\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_database&data_field=sessions_killed\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              </TABLE><BR>" ;
          }
    if ($pv{stat_is_table_out} eq "true") {
       print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
       print "<TR><TD CLASS=\"td_head\" ROWSPAN=\"2\">snap_ts</TD>
                  <TD CLASS=\"td_head\" ROWSPAN=\"2\">snap_id</TD>
                  <TD CLASS=\"td_head\" ROWSPAN=\"2\">datid</TD>
                  <TD CLASS=\"td_head\" ROWSPAN=\"2\">datname</TD>
                  <TD CLASS=\"td_head\" ROWSPAN=\"2\">num<BR>backends</TD>
                  <TD CLASS=\"td_head\" COLSPAN=\"2\">xact</TD>
                  <TD CLASS=\"td_head\" COLSPAN=\"2\">blks</TD>
                  <TD CLASS=\"td_head\" COLSPAN=\"5\">tuples</TD>
                  <TD CLASS=\"td_head\" ROWSPAN=\"2\">conflicts</TD>
                  <TD CLASS=\"td_head\" COLSPAN=\"2\">temp</TD>
                  <TD CLASS=\"td_head\" ROWSPAN=\"2\">deadlocks</TD>
                  <TD CLASS=\"td_head\" COLSPAN=\"2\">checksum</TD>
                  <TD CLASS=\"td_head\" COLSPAN=\"2\">blk_time</TD>
                  <TD CLASS=\"td_head\" COLSPAN=\"3\">time</TD>
                  <TD CLASS=\"td_head\" COLSPAN=\"4\">sessions</TD>
                  <TD CLASS=\"td_head\" ROWSPAN=\"2\">stats_reset</TD>
              </TR> " ;
       print "<TR><TD CLASS=\"td_head\">commit</TD><TD CLASS=\"td_head\">rollback</TD>
                  <TD CLASS=\"td_head\">read</TD><TD CLASS=\"td_head\">hit</TD>
                  <TD CLASS=\"td_head\">returned</TD><TD CLASS=\"td_head\">fetched</TD><TD CLASS=\"td_head\">inserted</TD><TD CLASS=\"td_head\">updated</TD><TD CLASS=\"td_head\">deleted</TD>
                  <TD CLASS=\"td_head\">files</TD><TD CLASS=\"td_head\">bytes</TD>
                  <TD CLASS=\"td_head\">failures</TD><TD CLASS=\"td_head\">last_failure</TD>
                  <TD CLASS=\"td_head\">read</TD><TD CLASS=\"td_head\">write</TD>
                  <TD CLASS=\"td_head\">session</TD><TD CLASS=\"td_head\">active</TD><TD CLASS=\"td_head\">idle_in_transaction</TD>
                  <TD CLASS=\"td_head\">all</TD><TD CLASS=\"td_head\">abandoned</TD><TD CLASS=\"td_head\">fatal</TD><TD CLASS=\"td_head\">killed</TD>
              </TR> " ;

       if ($pv{stat_obj} ne "undefined") { $ext_where_conditions .= " AND t.datid = $pv{stat_obj}" ; }
       if ($pv{stat_obj_id} ne "") { $ext_where_conditions .= " AND t.datid = $pv{stat_obj_id}" ; }
#       if ($pv{stat_part_name} ne "") { $ext_where_conditions .= " AND t.datname like '%$pv{stat_part_name}%" ; }
 
       if ($pv{stat_src_type} eq "curr") { $request_stat_databases = "select '-', 'текущее', t.datid, t.datname, t.numbackends, t.xact_commit, t.xact_rollback, t.blks_read, t.blks_hit, t.tup_returned, t.tup_fetched, t.tup_inserted, t.tup_updated, t.tup_deleted, t.conflicts, t.temp_files, t.temp_bytes, t.deadlocks, t.checksum_failures, t.checksum_last_failure, t.blk_read_time, t.blk_write_time, t.session_time, t.active_time, t.idle_in_transaction_time, t.sessions, t.sessions_abandoned, t.sessions_fatal, t.sessions_killed, t.stats_reset from pg_catalog.pg_stat_database t where 1=1 $ext_where_conditions" ; }
       if ($pv{stat_src_type} eq "snap") { $request_stat_databases = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.datid, t.datname, t.numbackends, t.xact_commit, t.xact_rollback, t.blks_read, t.blks_hit, t.tup_returned, t.tup_fetched, t.tup_inserted, t.tup_updated, t.tup_deleted, t.conflicts, t.temp_files, t.temp_bytes, t.deadlocks, t.checksum_failures, t.checksum_last_failure, t.blk_read_time, t.blk_write_time, t.session_time, t.active_time, t.idle_in_transaction_time, t.sessions, t.sessions_abandoned, t.sessions_fatal, t.sessions_killed, t.stats_reset from bestat_database t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id = $pv{stat_src_snap_id} $ext_where_conditions" ; }
       if ($pv{stat_src_type} eq "range") {
          if ($pv{stat_obj} ne "undefined" || $pv{stat_obj_id} ne "") { $request_stat_databases = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.datid, t.datname, t.numbackends, t.xact_commit, t.xact_rollback, t.blks_read, t.blks_hit, t.tup_returned, t.tup_fetched, t.tup_inserted, t.tup_updated, t.tup_deleted, t.conflicts, t.temp_files, t.temp_bytes, t.deadlocks, t.checksum_failures, t.checksum_last_failure, t.blk_read_time, t.blk_write_time, t.session_time, t.active_time, t.idle_in_transaction_time, t.sessions, t.sessions_abandoned, t.sessions_fatal, t.sessions_killed, t.stats_reset from bestat_database_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions" ; }
          else { $request_stat_databases = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, 'all', 'all', t.numbackends, t.xact_commit, t.xact_rollback, t.blks_read, t.blks_hit, t.tup_returned, t.tup_fetched, t.tup_inserted, t.tup_updated, t.tup_deleted, t.conflicts, t.temp_files, t.temp_bytes, t.deadlocks, t.checksum_failures, t.checksum_last_failure, t.blk_read_time, t.blk_write_time, t.session_time, t.active_time, t.idle_in_transaction_time, t.sessions, t.sessions_abandoned, t.sessions_fatal, t.sessions_killed, t.stats_reset from bestat_database_sum_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions" ; }
          }
#---debug---print "<BR>=== $request_stat_databases ===<BR>" ;
       my $dbh_stat_databases = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
       my $sth_stat_databases = $dbh_stat_databases->prepare($request_stat_databases) ; $sth_stat_databases->execute() ; $count_rows = 0 ;
       while (my ($snap_ts, $snap_id, $datid, $datname, $numbackends, $xact_commit, $xact_rollback, $blks_read, $blks_hit, $tup_returned, $tup_fetched, $tup_inserted, $tup_updated, $tup_deleted, $conflicts, $temp_files, $temp_bytes, $deadlocks, $checksum_failures, $checksum_last_failure, $blk_read_time, $blk_write_time, $session_time, $active_time, $idle_in_transaction_time, $sessions, $sessions_abandoned, $sessions_fatal, $sessions_killed, $stats_reset) = $sth_stat_databases->fetchrow_array() ) {
             $snap_ts =~ s/\s/&nbsp;/g ;
             print "<TR><TD CLASS=\"td_right\">$snap_ts</TD><TD CLASS=\"td_right\">$snap_id</TD>
                        <TD CLASS=\"td_right\">$datid</TD><TD CLASS=\"td_left\">$datname</TD>
                        <TD CLASS=\"td_right\">$numbackends</TD>
                        <TD CLASS=\"td_right\">$xact_commit</TD><TD CLASS=\"td_right\">$xact_rollback</TD>
                        <TD CLASS=\"td_right\">$blks_read</TD><TD CLASS=\"td_right\">$blks_hit</TD>
                        <TD CLASS=\"td_right\">$tup_returned</TD><TD CLASS=\"td_right\">$tup_fetched</TD><TD CLASS=\"td_right\">$tup_inserted</TD><TD CLASS=\"td_right\">$tup_updated</TD><TD CLASS=\"td_right\">$tup_deleted</TD>
                        <TD CLASS=\"td_right\">$conflicts</TD>
                        <TD CLASS=\"td_right\">$temp_files</TD><TD CLASS=\"td_right\">$temp_bytes</TD>
                        <TD CLASS=\"td_right\">$deadlocks</TD>
                        <TD CLASS=\"td_right\">$checksum_failures</TD><TD CLASS=\"td_left\">$checksum_last_failure</TD>
                        <TD CLASS=\"td_right\">$blk_read_time</TD><TD CLASS=\"td_right\">$blk_write_time</TD>
                        <TD CLASS=\"td_right\">$session_time</TD><TD CLASS=\"td_right\">$active_time</TD><TD CLASS=\"td_right\">$idle_in_transaction_time</TD>
                        <TD CLASS=\"td_right\">$sessions</TD><TD CLASS=\"td_right\">$sessions_abandoned</TD><TD CLASS=\"td_right\">$sessions_fatal</TD><TD CLASS=\"td_right\">$sessions_killed</TD>
                        <TD CLASS=\"td_left\">$stats_reset</TD>
                    </TR> " ;
             $count_rows++ ;
             }
       $sth_stat_databases->finish() ;
       $dbh_stat_databases->disconnect() ;
       if ($count_rows == 0) { print "<TR><TD COLSPAN=\"30\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"30\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
       print "</TABLE>" ;
       }
   }

if ($pv{tab_detail} == 2) {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">name</TD>
                 <TD CLASS=\"td_head\">off</TD>
                 <TD CLASS=\"td_head\">size</TD>
                 <TD CLASS=\"td_head\">allocated_size</TD>
             </TR> " ;
      $request_shmem_allocations = "select name, off, size, allocated_size from pg_catalog.pg_shmem_allocations" ;
      my $dbh_shmem_allocations = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_shmem_allocations = $dbh_shmem_allocations->prepare($request_shmem_allocations) ; $sth_shmem_allocations->execute() ; $count_rows = 0 ;
      while (my ($name, $off, $size, $allocated_size) = $sth_shmem_allocations->fetchrow_array() ) {
            print "<TR><TD>$name</TD>
                       <TD>$off</TD>
                       <TD>$size</TD>
                       <TD>$allocated_size</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_shmem_allocations->finish() ;
      $dbh_shmem_allocations->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"4\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"4\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
   }

if ($pv{tab_detail} == 3) {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">name</TD>
                 <TD CLASS=\"td_head\">blks_zeroed</TD>
                 <TD CLASS=\"td_head\">blks_hit</TD>
                 <TD CLASS=\"td_head\">blks_read</TD>
                 <TD CLASS=\"td_head\">blks_written</TD>
                 <TD CLASS=\"td_head\">blks_exists</TD>
                 <TD CLASS=\"td_head\">flushes</TD>
                 <TD CLASS=\"td_head\">truncates</TD>
                 <TD CLASS=\"td_head\">stats_reset</TD>
             </TR> " ;
      $request_stat_slru = "select name, blks_zeroed, blks_hit, blks_read, blks_written, blks_exists, flushes, truncates, stats_reset from pg_catalog.pg_stat_slru" ;
      my $dbh_stat_slru = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_slru = $dbh_stat_slru->prepare($request_stat_slru) ; $sth_stat_slru->execute() ; $count_rows = 0 ;
      while (my ($name, $blks_zeroed, $blks_hit, $blks_read, $blks_written, $blks_exists, $flushes, $truncates, $stats_reset) = $sth_stat_slru->fetchrow_array() ) {
            print "<TR><TD>$name</TD>
                       <TD>$blks_zeroed</TD>
                       <TD>$blks_hit</TD>
                       <TD>$blks_read</TD>
                       <TD>$blks_written</TD>
                       <TD>$blks_exists</TD>
                       <TD>$flushes</TD>
                       <TD>$truncates</TD>
                       <TD>$stats_reset</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_slru->finish() ;
      $dbh_stat_slru->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"9\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"9\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
   }

if ($pv{tab_detail} == 4) {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">archived_count</TD>
                 <TD CLASS=\"td_head\">last_archived_wal</TD>
                 <TD CLASS=\"td_head\">last_archived_time</TD>
                 <TD CLASS=\"td_head\">failed_count</TD>
                 <TD CLASS=\"td_head\">last_failed_wal</TD>
                 <TD CLASS=\"td_head\">last_failed_time</TD>
                 <TD CLASS=\"td_head\">stats_reset</TD></TR> " ;
      $request_stat_archiver = "select archived_count, last_archived_wal, last_archived_time, failed_count, last_failed_wal, last_failed_time, stats_reset from pg_catalog.pg_stat_archiver" ;
      my $dbh_stat_archiver = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_archiver = $dbh_stat_archiver->prepare($request_stat_archiver) ; $sth_stat_archiver->execute() ; $count_rows = 0 ;
      while (my ($archived_count, $last_archived_wal, $last_archived_time, $failed_count, $last_failed_wal, $last_failed_time, $stats_reset) = $sth_stat_archiver->fetchrow_array() ) {
            print "<TR><TD>$archived_count</TD>
                       <TD>$last_archived_wal</TD>
                       <TD>$last_archived_time</TD>
                       <TD>$failed_count</TD>
                       <TD>$last_failed_wal</TD>
                       <TD>$last_failed_time</TD>
                       <TD>$stats_reset</TD></TR> " ;
            $count_rows++ ;
            }
      $sth_stat_archiver->finish() ;
      $dbh_stat_archiver->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"7\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"7\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
   }

if ($pv{tab_detail} == 5) {
   print_stat_snap_filters() ;
   if ($pv{stat_src_type} eq "range" && $pv{stat_is_graph_out} eq "true") { set_common_pg_mon_cgi_prefix() ;
      print "<BR><TABLE BORDER=\"1\" STYLE=\"text-align: left; width: 1100pt; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_left\">Количество контрольных точек<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoints_timed&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     checkpoints_timed</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoints_timed\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoints_timed\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Запросов контрольных точек<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoints_req&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     checkpoints_req</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoints_req\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoints_req\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Время записи контрольных точек<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoint_write_time&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     checkpoint_write_time</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoint_write_time\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoint_write_time\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Время fsync контрольных точек<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoint_sync_time&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     checkpoint_sync_time</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoint_sync_time\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=checkpoint_sync_time\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Выгружено контрольными точками, буферов<BR><BR>
                        <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_checkpoint&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     buffers_checkpoint</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_checkpoint\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_checkpoint\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Чистых буферов<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_clean&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     buffers_clean</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_clean\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_clean\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Очисток, maxwritten<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=maxwritten_clean&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     maxwritten_clean</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=maxwritten_clean\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=maxwritten_clean\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Вынесено пользовательскими процессами, буферов<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_backend&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     buffers_backend</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_backend\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_backend\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Вынесено пользовательскими процессами, операций fsync<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_backend_fsync&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     buffers_backend_fsync</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_backend_fsync\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_backend_fsync\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Буферов размещено<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_alloc&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     buffers_alloc</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_alloc\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_bgwriter&data_field=buffers_alloc\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             </TABLE><BR>" ;
         }
      if ($pv{stat_is_table_out} eq "true") {
        print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
        print "<TR><TD CLASS=\"td_head\">snap_ts</TD>
                   <TD CLASS=\"td_head\">snap_id</TD>
                   <TD CLASS=\"td_head\">checkpoints_timed</TD>
                   <TD CLASS=\"td_head\">checkpoints_req</TD>
                   <TD CLASS=\"td_head\">checkpoint_write_time</TD>
                   <TD CLASS=\"td_head\">checkpoint_sync_time</TD>
                   <TD CLASS=\"td_head\">buffers_checkpoint</TD>
                   <TD CLASS=\"td_head\">buffers_clean</TD>
                   <TD CLASS=\"td_head\">maxwritten_clean</TD>
                   <TD CLASS=\"td_head\">buffers_backend</TD>
                   <TD CLASS=\"td_head\">buffers_backend_fsync</TD>
                   <TD CLASS=\"td_head\">buffers_alloc</TD>
                   <TD CLASS=\"td_head\">stats_reset</TD>
                </TR> " ;

     if ($pv{stat_src_type} eq "curr") { $request_stat_bgwriter = "select '-', 'текущее', t.checkpoints_timed, t.checkpoints_req, t.checkpoint_write_time, t.checkpoint_sync_time, t.buffers_checkpoint, t.buffers_clean, t.maxwritten_clean, t.buffers_backend, t.buffers_backend_fsync, t.buffers_alloc, t.stats_reset from pg_catalog.pg_stat_bgwriter t" ; }
     if ($pv{stat_src_type} eq "snap") { $request_stat_bgwriter = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.checkpoints_timed, t.checkpoints_req, t.checkpoint_write_time, t.checkpoint_sync_time, t.buffers_checkpoint, t.buffers_clean, t.maxwritten_clean, t.buffers_backend, t.buffers_backend_fsync, t.buffers_alloc, t.stats_reset from bestat_bgwriter t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id = $pv{stat_src_snap_id}" ; }
     if ($pv{stat_src_type} eq "range") { $request_stat_bgwriter = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.checkpoints_timed, t.checkpoints_req, t.checkpoint_write_time, t.checkpoint_sync_time, t.buffers_checkpoint, t.buffers_clean, t.maxwritten_clean, t.buffers_backend, t.buffers_backend_fsync, t.buffers_alloc, t.stats_reset from bestat_bgwriter_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
#---debug---print "<BR>=== $request_stat_bgwriter ===<BR>" ;
     my $dbh_stat_bgwriter = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
     my $sth_stat_bgwriter = $dbh_stat_bgwriter->prepare($request_stat_bgwriter) ; $sth_stat_bgwriter->execute() ; $count_rows = 0 ;
     while (my ($snap_ts, $snap_id, $checkpoints_timed, $checkpoints_req, $checkpoint_write_time, $checkpoint_sync_time, $buffers_checkpoint, $buffers_clean, $maxwritten_clean, $buffers_backend, $buffers_backend_fsync, $buffers_alloc, $stats_reset) = $sth_stat_bgwriter->fetchrow_array() ) {
           $snap_ts =~ s/\s/&nbsp;/g ; $stats_reset =~ s/\s/&nbsp;/g ;
           print "<TR><TD CLASS=\"td_right\">$snap_ts</TD>
                      <TD CLASS=\"td_right\">$snap_id</TD>
                      <TD CLASS=\"td_right\">$checkpoints_timed</TD>
                      <TD CLASS=\"td_right\">$checkpoints_req</TD>
                      <TD CLASS=\"td_right\">$checkpoint_write_time</TD>
                      <TD CLASS=\"td_right\">$checkpoint_sync_time</TD>
                      <TD CLASS=\"td_right\">$buffers_checkpoint</TD>
                      <TD CLASS=\"td_right\">$buffers_clean</TD>
                      <TD CLASS=\"td_right\">$maxwritten_clean</TD>
                      <TD CLASS=\"td_right\">$buffers_backend</TD>
                      <TD CLASS=\"td_right\">$buffers_backend_fsync</TD>
                      <TD CLASS=\"td_right\">$buffers_alloc</TD>
                      <TD CLASS=\"td_right\">$stats_reset</TD>
                   </TR> " ;
           $count_rows++ ;
           }
     $sth_stat_bgwriter->finish() ;
     $dbh_stat_bgwriter->disconnect() ;
     if ($count_rows == 0) { print "<TR><TD COLSPAN=\"13\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"13\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
     print "</TABLE>" ;
     }
   }

if ($pv{tab_detail} == 6) {
   print_stat_snap_filters() ;
   if ($pv{stat_src_type} eq "range" && $pv{stat_is_graph_out} eq "true") { set_common_pg_mon_cgi_prefix() ;
       print "<BR><TABLE BORDER=\"1\" STYLE=\"text-align: left; width: 1100pt; border: 1pt navy; border-style: solid;\">" ;
       print "<TR><TD CLASS=\"td_left\">Записей журналов<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_records&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      wal_records</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_records\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_records\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Сгенерировано полных страниц журналов<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_fpi&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      wal_fpi</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_fpi\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_fpi\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Сгенерировано журналов, байт<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_bytes&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      wal_bytes</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_bytes\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_bytes\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Заполнено буферов журналов<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_buffers_full&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      wal_buffers_full</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_buffers_full\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_buffers_full\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Операций записи журналов<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_write&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      wal_write</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_write\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_write\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Операций fsync журналов<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_sync&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      wal_sync</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_sync\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_sync\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Время записи журналов, миллисек.<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_write_time&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      wal_write_time</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_write_time\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_write_time\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              <TR><TD CLASS=\"td_left\">Время операций fsym журналов, миллисек.<BR><BR>
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_sync_time&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                      wal_sync_time</TD><TD CLASS=\"td_left\">
                      <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_sync_time\" TARGET=\"_blank\">
                         <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_wal&data_field=wal_sync_time\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
              </TABLE><BR>" ;
          }
   if ($pv{stat_is_table_out} eq "true") {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">snap_ts</TD>
                 <TD CLASS=\"td_head\">snap_id</TD>
                 <TD CLASS=\"td_head\">wal_records</TD>
                 <TD CLASS=\"td_head\">wal_fpi</TD>
                 <TD CLASS=\"td_head\">wal_bytes</TD>
                 <TD CLASS=\"td_head\">wal_buffers_full</TD>
                 <TD CLASS=\"td_head\">wal_write</TD>
                 <TD CLASS=\"td_head\">wal_sync</TD>
                 <TD CLASS=\"td_head\">wal_write_time</TD>
                 <TD CLASS=\"td_head\">wal_sync_time</TD>
                 <TD CLASS=\"td_head\">stats_reset</TD>
              </TR> " ;

     if ($pv{stat_src_type} eq "curr") { $request_stat_wal = "select '-', 'текущее', t.wal_records, t.wal_fpi, t.wal_bytes, t.wal_buffers_full, t.wal_write, t.wal_sync, t.wal_write_time, t.wal_sync_time, t.stats_reset from pg_catalog.pg_stat_wal t" ; }
     if ($pv{stat_src_type} eq "snap") { $request_stat_wal = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.wal_records, t.wal_fpi, t.wal_bytes, t.wal_buffers_full, t.wal_write, t.wal_sync, t.wal_write_time, t.wal_sync_time, t.stats_reset from bestat_wal t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id = $pv{stat_src_snap_id}" ; }
     if ($pv{stat_src_type} eq "range") { $request_stat_wal = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.wal_records, t.wal_fpi, t.wal_bytes, t.wal_buffers_full, t.wal_write, t.wal_sync, t.wal_write_time, t.wal_sync_time, t.stats_reset from bestat_wal_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
#---debug---print "<BR>=== $request_stat_wal ===<BR>" ;
      my $dbh_stat_wal = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_wal = $dbh_stat_wal->prepare($request_stat_wal) ; $sth_stat_wal->execute() ; $count_rows = 0 ;
      while (my ($snap_ts, $snap_id, $wal_records, $wal_fpi, $wal_bytes, $wal_buffers_full, $wal_write, $wal_sync, $wal_write_time, $wal_sync_time, $stats_reset) = $sth_stat_wal->fetchrow_array() ) {
             $snap_ts =~ s/\s/&nbsp;/g ;
            print "<TR><TD CLASS=\"td_left\">$snap_ts</TD>
                       <TD CLASS=\"td_right\">$snap_id</TD>
                       <TD CLASS=\"td_right\">$wal_records</TD>
                       <TD CLASS=\"td_right\">$wal_fpi</TD>
                       <TD CLASS=\"td_right\">$wal_bytes</TD>
                       <TD CLASS=\"td_right\">$wal_buffers_full</TD>
                       <TD CLASS=\"td_right\">$wal_write</TD>
                       <TD CLASS=\"td_right\">$wal_sync</TD>
                       <TD CLASS=\"td_right\">$wal_write_time</TD>
                       <TD CLASS=\"td_right\">$wal_sync_time</TD>
                       <TD CLASS=\"td_left\">$stats_reset</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_wal->finish() ;
      $dbh_stat_wal->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"11\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"11\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
      }
   }

if ($pv{tab_detail} == 7) {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">pid</TD>
                 <TD CLASS=\"td_head\">status</TD>
                 <TD CLASS=\"td_head\">receive_start_lsn</TD>
                 <TD CLASS=\"td_head\">receive_start_tli</TD>
                 <TD CLASS=\"td_head\">written_lsn</TD>
                 <TD CLASS=\"td_head\">flushed_lsn</TD>
                 <TD CLASS=\"td_head\">received_tli</TD>
                 <TD CLASS=\"td_head\">last_msg_send_time</TD>
                 <TD CLASS=\"td_head\">last_msg_receipt_time</TD>
                 <TD CLASS=\"td_head\">latest_end_lsn</TD>
                 <TD CLASS=\"td_head\">latest_end_time</TD>
                 <TD CLASS=\"td_head\">slot_name</TD>
                 <TD CLASS=\"td_head\">sender_host</TD>
                 <TD CLASS=\"td_head\">sender_port</TD>
                 <TD CLASS=\"td_head\">conninfo</TD>
             </TR> " ;
      $request_stat_wal = "select pid, status, receive_start_lsn, receive_start_tli, written_lsn, flushed_lsn, received_tli, last_msg_send_time, last_msg_receipt_time, latest_end_lsn, latest_end_time, slot_name, sender_host, sender_port, conninfo from pg_catalog.pg_stat_wal_receiver" ;
      my $dbh_stat_wal = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_wal = $dbh_stat_wal->prepare($request_stat_wal) ; $sth_stat_wal->execute() ; $count_rows = 0 ;
      while (my ($pid, $status, $receive_start_lsn, $receive_start_tli, $written_lsn, $flushed_lsn, $received_tli, $last_msg_send_time, $last_msg_receipt_time, $latest_end_lsn, $latest_end_time, $slot_name, $sender_host, $sender_port, $conninfo) = $sth_stat_wal->fetchrow_array() ) {
            print "<TR><TD>$pid</TD>
                       <TD>$status</TD>
                       <TD>$receive_start_lsn</TD>
                       <TD>$receive_start_tli</TD>
                       <TD>$written_lsn</TD>
                       <TD>$flushed_lsn</TD>
                       <TD>$received_tli</TD>
                       <TD>$last_msg_send_time</TD>
                       <TD>$last_msg_receipt_time</TD>
                       <TD>$latest_end_lsn</TD>
                       <TD>$latest_end_time</TD>
                       <TD>$slot_name</TD>
                       <TD>$sender_host</TD>
                       <TD>$sender_port</TD>
                       <TD>$conninfo</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_wal->finish() ;
      $dbh_stat_wal->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"15\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"15\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
   }

if ($pv{tab_detail} == 8) {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">pid</TD>
                 <TD CLASS=\"td_head\">usesysid</TD>
                 <TD CLASS=\"td_head\">usename</TD>
                 <TD CLASS=\"td_head\">application_name</TD>
                 <TD CLASS=\"td_head\">client_addr</TD>
                 <TD CLASS=\"td_head\">client_hostname</TD>
                 <TD CLASS=\"td_head\">client_port</TD>
                 <TD CLASS=\"td_head\">backend_start</TD>
                 <TD CLASS=\"td_head\">backend_xmin</TD>
                 <TD CLASS=\"td_head\">state</TD>
                 <TD CLASS=\"td_head\">sent_lsn</TD>
                 <TD CLASS=\"td_head\">write_lsn</TD>
                 <TD CLASS=\"td_head\">flush_lsn</TD>
                 <TD CLASS=\"td_head\">replay_lsn</TD>
                 <TD CLASS=\"td_head\">write_lag</TD>
                 <TD CLASS=\"td_head\">flush_lag</TD>
                 <TD CLASS=\"td_head\">replay_lag</TD>
                 <TD CLASS=\"td_head\">sync_priority</TD>
                 <TD CLASS=\"td_head\">sync_state</TD>
                 <TD CLASS=\"td_head\">reply_time</TD>
             </TR> " ;
      $request_stat_replication = "select pid, usesysid, usename, application_name, client_addr, client_hostname, client_port, backend_start, backend_xmin, state, sent_lsn, write_lsn, flush_lsn, replay_lsn, write_lag, flush_lag, replay_lag, sync_priority, sync_state, reply_time from pg_catalog.pg_stat_replication" ;
      my $dbh_stat_replication = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_replication = $dbh_stat_replication->prepare($request_stat_replication) ; $sth_stat_replication->execute() ; $count_rows = 0 ;
      while (my ($pid, $usesysid, $usename, $application_name, $client_addr, $client_hostname, $client_port, $backend_start, $backend_xmin, $state, $sent_lsn, $write_lsn, $flush_lsn, $replay_lsn, $write_lag, $flush_lag, $replay_lag, $sync_priority, $sync_state, $reply_time) = $sth_stat_replication->fetchrow_array() ) {
            print "<TR><TD>$pid</TD>
                       <TD>$usesysid</TD>
                       <TD>$usename</TD>
                       <TD>$application_name</TD>
                       <TD>$client_addr</TD>
                       <TD>$client_hostname</TD>
                       <TD>$client_port</TD>
                       <TD>$backend_start</TD>
                       <TD>$backend_xmin</TD>
                       <TD>$state</TD>
                       <TD>$sent_lsn</TD>
                       <TD>$write_lsn</TD>
                       <TD>$flush_lsn</TD>
                       <TD>$replay_lsn</TD>
                       <TD>$write_lag</TD>
                       <TD>$flush_lag</TD>
                       <TD>$replay_lag</TD>
                       <TD>$sync_priority</TD>
                       <TD>$sync_state</TD>
                       <TD>$reply_time</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_replication->finish() ;
      $dbh_stat_replication->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"20\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"20\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
   }

if ($pv{tab_detail} == 9) {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">slot_name</TD>
                 <TD CLASS=\"td_head\">spill_txns</TD>
                 <TD CLASS=\"td_head\">spill_count</TD>
                 <TD CLASS=\"td_head\">spill_bytes</TD>
                 <TD CLASS=\"td_head\">stream_txns</TD>
                 <TD CLASS=\"td_head\">stream_count</TD>
                 <TD CLASS=\"td_head\">stream_bytes</TD>
                 <TD CLASS=\"td_head\">total_txns</TD>
                 <TD CLASS=\"td_head\">total_bytes</TD>
                 <TD CLASS=\"td_head\">stats_reset</TD>
             </TR> " ;
      $request_stat_replication_slots = "select slot_name, spill_txns, spill_count, spill_bytes, stream_txns, stream_count, stream_bytes, total_txns, total_bytes, stats_reset from pg_catalog.pg_stat_replication_slots" ;
      my $dbh_stat_replication_slots = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_replication_slots = $dbh_stat_replication_slots->prepare($request_stat_replication_slots) ; $sth_stat_replication_slots->execute() ; $count_rows = 0 ;
      while (my ($slot_name, $spill_txns, $spill_count, $spill_bytes, $stream_txns, $stream_count, $stream_bytes, $total_txns, $total_bytes, $stats_reset) = $sth_stat_replication_slots->fetchrow_array() ) {
            print "<TR><TD>$slot_name</TD>
                       <TD>$spill_txns</TD>
                       <TD>$spill_count</TD>
                       <TD>$spill_bytes</TD>
                       <TD>$stream_txns</TD>
                       <TD>$stream_count</TD>
                       <TD>$stream_bytes</TD>
                       <TD>$total_txns</TD>
                       <TD>$total_bytes</TD>
                       <TD>$stats_reset</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_replication_slots->finish() ;
      $dbh_stat_replication_slots->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"10\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"10\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
   }

if ($pv{tab_detail} == 10) {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">subid</TD>
                 <TD CLASS=\"td_head\">subname</TD>
                 <TD CLASS=\"td_head\">pid</TD>
                 <TD CLASS=\"td_head\">relid</TD>
                 <TD CLASS=\"td_head\">received_lsn</TD>
                 <TD CLASS=\"td_head\">last_msg_send_time</TD>
                 <TD CLASS=\"td_head\">last_msg_receipt_time</TD>
                 <TD CLASS=\"td_head\">latest_end_lsn</TD>
                 <TD CLASS=\"td_head\">latest_end_time</TD>
             </TR> " ;
      $request_stat_subscription = "select subid, subname, pid, relid, received_lsn, last_msg_send_time, last_msg_receipt_time, latest_end_lsn, latest_end_time from pg_catalog.pg_stat_subscription" ;
      my $dbh_stat_subscription = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_subscription = $dbh_stat_subscription->prepare($request_stat_subscription) ; $sth_stat_subscription->execute() ; $count_rows = 0 ;
      while (my ($subid, $subname, $pid, $relid, $received_lsn, $last_msg_send_time, $last_msg_receipt_time, $latest_end_lsn, $latest_end_time) = $sth_stat_subscription->fetchrow_array() ) {
            print "<TR><TD>$subid</TD>
                       <TD>$subname</TD>
                       <TD>$pid</TD>
                       <TD>$relid</TD>
                       <TD>$received_lsn</TD>
                       <TD>$last_msg_send_time</TD>
                       <TD>$last_msg_receipt_time</TD>
                       <TD>$latest_end_lsn</TD>
                       <TD>$latest_end_time</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_subscription->finish() ;
      $dbh_stat_subscription->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"9\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"9\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
   }

if ($pv{tab_detail} == 11) {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">subid</TD>
                 <TD CLASS=\"td_head\">subname</TD>
                 <TD CLASS=\"td_head\">apply_error_count</TD>
                 <TD CLASS=\"td_head\">sync_error_count</TD>
                 <TD CLASS=\"td_head\">stats_reset</TD>
             </TR> " ;
      $request_stat_subscription_stats = "select subid, subname, apply_error_count, sync_error_count, stats_reset from pg_catalog.pg_stat_subscription_stats" ;
      my $dbh_stat_subscription_stats = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_subscription_stats = $dbh_stat_subscription_stats->prepare($request_stat_subscription_stats) ; $sth_stat_subscription_stats->execute() ; $count_rows = 0 ;
      while (my ($subid, $subname, $apply_error_count, $sync_error_count, $stats_reset) = $sth_stat_subscription_stats->fetchrow_array() ) {
            print "<TR><TD>$subid</TD>
                       <TD>$subname</TD>
                       <TD>$apply_error_count</TD>
                       <TD>$sync_error_count</TD>
                       <TD>$stats_reset</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_subscription_stats->finish() ;
      $dbh_stat_subscription_stats->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"5\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"5\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
   }

print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
