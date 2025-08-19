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

print_tools_pg_main_navigation(3) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;

print_tools_pg_monitor_navigation(5) ;
print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;

print "<TR><TD COLSPAN=\"4\">" ;

if ($pv{tab_detail} == 1) { 
   print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">Имя БД [oid]</TD>
              <TD CLASS=\"head\">PID [ub_start]</TD>
              <TD CLASS=\"head\">Статус</TD>
              <TD CLASS=\"head\">Leader PID</TD>
              <TD CLASS=\"head\">Имя пользователя</TD>
              <TD CLASS=\"head\">Клиент<BR>host IP:port</TD>
              <TD CLASS=\"head\">Type<BR>backend</TD>
              <TD CLASS=\"head\">Application<BR>name</TD>
              <TD CLASS=\"head\">Query ID<BR>[text query]</TD>
              <TD CLASS=\"head\">Query<BR>start</TD>
              <TD CLASS=\"head\">State<BR>change</TD>
              <TD CLASS=\"head\">Wait<BR>event type</TD>
              <TD CLASS=\"head\">Wait<BR>event</TD>
              <TD CLASS=\"head\">Backend XID</TD>
              <TD CLASS=\"head\">Xact start</TD>
              <TD CLASS=\"head\">Backend XMIN</TD>
          </TR>" ;

   $request_sessions = "select datid, datname, pid, leader_pid, usesysid, usename, application_name, client_addr, client_hostname, client_port, backend_start,
                               xact_start, query_start, state_change, wait_event_type, wait_event, state, backend_xid, backend_xmin, query_id, query, backend_type
                               from pg_stat_activity order by datid asc, pid asc" ;


   my $dbh_sessions = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_sessions = $dbh_sessions->prepare($request_sessions) ; $sth_sessions->execute() ; $count_rows = 0 ;
   while (my ($datid, $datname, $pid, $leader_pid, $usesysid, $usename, $application_name, $client_addr, $client_hostname, $client_port, $backend_start, $xact_start, $query_start, $state_change, $wait_event_type, $wait_event, $state, $backend_xid, $backend_xmin, $query_id, $query, $backend_type) = $sth_sessions->fetchrow_array() ) {

   if ($client_hostname ne "") { $client_hostname = "[$client_hostname]" ; } if ($client_port ne "") { $client_port = ":$client_port" ; }
   $query_start =~ s/(\S+)\s(\S+)\.(.*)/$1&nbsp;$2/g ; $state_change =~ s/(\S+)\s(\S+)\.(.*)/$1&nbsp;$2/g ; $xact_start =~ s/(\S+)\s(\S+)\.(.*)/$1&nbsp;$2/g ;

   print "<TR><TD TITLE=\"[db_oid: $datid]\">$datname</TD>
              <TD STYLE=\"text-align: right;\" TITLE=\"[backend_start: $backend_start]\">$pid</TD>
              <TD>$state</TD>
              <TD>$leader_pid</TD>
              <TD TITLE=\"[$usesysid]\">$usename</TD>
              <TD>$client_hostname $client_addr$client_port</TD>
              <TD>$backend_type</TD>
              <TD>$application_name</TD>
              <TD TITLE=\"$query\">$query_id</TD>
              <TD>$query_start</TD>
              <TD>$state_change</TD>
              <TD>$wait_event_type</TD>
              <TD>$wait_event</TD>
              <TD STYLE=\"text-align: right;\">$backend_xid</TD>
              <TD>$xact_start</TD>
              <TD STYLE=\"text-align: right;\">$backend_xmin</TD>
          </TR>" ;
         }
   $sth_sessions->finish() ;
   $dbh_sessions->disconnect() ;
   }

print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
