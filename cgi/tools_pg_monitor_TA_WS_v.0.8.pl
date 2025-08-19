#!/usr/bin/perl

# open source soft - (C) 2025 CAMActSoSt BESST - in last part of (C) 2023 camactsost BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
require "/var/www/camactsost/cgi/common_parameter.camactsost" ;
require "$camactsost_dir_lib/lib_common_func.pl" ;
#require "$camactsost_dir_lib/lib_camactsost_common.pl" ;
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
       <INPUT TYPE=\"hidden\" NAME=\"is_user_backends\" ID=\"id_is_user_backends\" VALUE =\"$pv{is_user_backends}\">
       <INPUT TYPE=\"hidden\" NAME=\"is_backgrounds\" ID=\"id_is_backgrounds\" VALUE=\"$pv{is_backgrounds}\">
       <INPUT TYPE=\"hidden\" NAME=\"is_extensions\" ID=\"id_is_extensions\" VALUE=\"$pv{is_extensions}\"> " ;
print "</SPAN>" ;

print_tools_pg_main_navigation(3) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;

print_tools_pg_monitor_navigation(3) ;
print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;
print_wait_sampling_head_ash_graph() ;
print "</TD></TR><TR><TD>" ;
print_tools_pg_monitor_top_activity_WS_detail($pv{tab_detail}) ;

print "<!-- таблица четвёртого уровня вкладок - блок детализации -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;

if ($pv{tab_detail} == 1) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_sql_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_session_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'short',$pg_mon_short_record_limit) ;
  }

if ($pv{tab_detail} == 2) {
   print "<TR><TD STYLE=\"width: 100%; vertical-align: top;\">" ;
   print_wait_sampling_sql_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'long',$pg_mon_long_record_limit) ;
   }

if ($pv{tab_detail} == 3) {
   print "<TR><TD STYLE=\"width: 100%; vertical-align: top;\">" ;
   print_wait_sampling_session_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'long',$pg_mon_long_record_limit) ;
   }

if ($pv{tab_detail} == 4) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_sql_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_sql_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'short',$pg_mon_short_record_limit) ;
   }

if ($pv{tab_detail} == 5) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_session_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_session_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'short',$pg_mon_short_record_limit) ;
   }

if ($pv{tab_detail} == 6) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_sah_events($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_events($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'short',$pg_mon_short_record_limit) ;
   }

print "<!-- конец таблицы четвёртого уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы третьего уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
