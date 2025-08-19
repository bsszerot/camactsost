#!/usr/bin/perl

# open source soft - (C) 2025 CAMActSoSt BESST - in last part of (C) 2023 camactsost BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
require "/var/www/camactsost/cgi/common_parameter.camactsost" ;
require "$camactsost_dir_lib/lib_common_func.pl" ;
require "$camactsost_dir_lib/lib_camactsost_common.pl" ;
require "$camactsost_dir_lib/lib_camactsost_pg_monitor.pl" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;

print "Content-Type: text/html\n\n" ;

print_header_1_1_cgi() ;
print "MON ZRT КрАгрАн БЕССТ" ;
print_header_1_2_cgi() ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
print_header_2_1_cgi() ;

$common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;
print_pg_monitor_main_page_title("Монитор состояния PostgreSQL: ", "$COMM_PAR_PGSQL_DB_NAME") ;
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
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;

print_tools_pg_monitor_navigation(2) ;
print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;

print_head_ash_graph() ;

print "</TD></TR>
<TR><TD COLSPAN=\"4\"><HR>" ;

if ( $pv{tab_detail} != 1 && $pv{tab_detail} != 2 && $pv{tab_detail} != 3 && $pv{tab_detail} != 4 && $pv{tab_detail} != 5 && $pv{tab_detail} != 6 ) { $pv{tab_detail} = 1 ; }
print_tools_pg_monitor_session_detail($pv{tab_detail}) ;
print "<!-- таблица третьего - детализации - уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD>" ;

if ($pv{tab_detail} == 1) { print_sql_table_activity($pv{period_from},$pv{period_to},'','',$pv{pid},$pv{serial},'bestat_sa_history','long',$pg_mon_long_record_limit) ; }


# детализация - события ожидания из pg_stat_activity
if ($pv{tab_detail} == 2) {
   print "<TABLE BORDER=\"0\" WIDTH=\"100%\"><TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_sah_events($pv{period_from},$pv{period_to},$pv{query_id},$pv{plan_id},$pv{pid},$pv{pid_start},"bestat_sa_history") ;
   print "</TD>\n<TD STYLE=\"width: 50%; vertical-align: top;\">
          <!-- вторая таблица отражает данные распределения событий ожидания из pg_wait_sampling -->" ;
   print_wait_sampling_events($pv{period_from},$pv{period_to},$pv{query_id},$pv{plan_id},$pv{pid},$pv{pid_start},"bestat_ws_history") ;
   print "</TD></TR></TABLE>" ;

   }

# детализация - события ожидания из pg_wait_stats
if ($pv{tab_detail} == 6) { 
   print "<A TARGET=\"_blank\" HREF=\"$base_url/cgi/_graph_pg_WS_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&ds_type=DB&width=1450&height=500\">
           <IMG style=\"width:100%; height: 240pt;\" SRC=\"$base_url/cgi/_graph_pg_WS_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&ds_type=DB&width=2800&height=600\"></A>" ;
   }

print "<!-- конец таблицы третьего уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
