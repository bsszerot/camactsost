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
if ( $pv{ds_type} eq "" ) { $pv{ds_type} = "DB" ; }

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;

print "Content-Type: text/html\n\n" ;

print_header_1_1_cgi() ;
print "MON ZRT КрАгрАн БЕССТ" ;
print_header_1_2_cgi() ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
print_header_2_1_cgi() ;

#$common_pg_mon_cgi_prefix = "period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&dbid=$pv{dbid}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&ds_type=$pv{ds_type}&curr_conn=$pv{curr_conn}&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}" ;
$common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;
print_pg_monitor_main_page_title("Монитор состояния PostgreSQL: ", "$COMM_PAR_PGSQL_DB_NAME") ;
print_js_block_pg_monitor() ;

print_tools_pg_main_navigation(3) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>" ;
print_tools_pg_monitor_navigation(2) ;
print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;
print_head_ash_graph() ;
print "</TD></TR><TR><TD>" ;
print_tools_pg_monitor_top_activity_SA_detail($pv{tab_detail}) ;
print "<!-- таблица третьего уровня вкладок - основной блок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;

if ($pv{tab_detail} == 1) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_sql_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_session_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   }

if ($pv{tab_detail} == 2) {
   print "<TR><TD STYLE=\"width: 100%; vertical-align: top;\">" ;
   print_sql_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','long',$pg_mon_long_record_limit) ;
   }

if ($pv{tab_detail} == 3) {
   print "<TR><TD STYLE=\"width: 100%; vertical-align: top;\">" ;
   print_session_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','long',$pg_mon_long_record_limit) ;
   }

if ($pv{tab_detail} == 4) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_sql_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_sql_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   }

if ($pv{tab_detail} == 5) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_session_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_session_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   }

if ($pv{tab_detail} == 6) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_sah_events($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_events($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   }

#print "<!-- конец таблицы четвёртого уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы третьего уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
