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

print_tools_pg_monitor_navigation(4) ;
print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\"><BR>" ;

print_tools_pg_monitor_locks_detail($pv{tab_detail}) ;
print "<!-- таблица четвёртого - детализации - уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD>" ;

if ($pv{tab_detail} == 1) { 
   print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">locktype</TD>
              <TD CLASS=\"head\">database</TD>
              <TD CLASS=\"head\">relation</TD>
              <TD CLASS=\"head\">page</TD>
              <TD CLASS=\"head\">tuple</TD>
              <TD CLASS=\"head\">virtualxid</TD>
              <TD CLASS=\"head\">transactionid</TD>
              <TD CLASS=\"head\">classid</TD>
              <TD CLASS=\"head\">objid</TD>
              <TD CLASS=\"head\">objsubid</TD>
              <TD CLASS=\"head\">virtualtransaction</TD>
              <TD CLASS=\"head\">pid</TD>
              <TD CLASS=\"head\">mode</TD>
              <TD CLASS=\"head\">granted</TD>
              <TD CLASS=\"head\">fastpath</TD>
              <TD CLASS=\"head\">waitstart</TD>
          </TR>" ;

# согласно документации relation = pg_class.oid работают только для текеущей БД и БД is null - для других вкладок
   $request_locks = "select locktype, database, relation, page, tuple, virtualxid, transactionid, classid, objid, objsubid, virtualtransaction, pid, mode, granted, fastpath, waitstart
                               from pg_locks order by database, relation, pid" ;


   my $dbh_locks = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_locks = $dbh_locks->prepare($request_locks) ; $sth_locks->execute() ; $count_rows = 0 ;
   while (my ($locktype, $database, $relation, $page, $tuple, $virtualxid, $transactionid, $classid, $objid, $objsubid, $virtualtransaction, $pid, $mode, $granted, $fastpath, $waitstart) = $sth_locks->fetchrow_array() ) {
   if ( $granted eq "1" ) { $granted = "удерживает [$granted]" ; } if ( $granted eq "0" ) { $granted = "ожидает [$granted]" ; }
   print "<TR><TD>$locktype</TD>
              <TD>$database</TD>
              <TD>$relation</TD>
              <TD>$page</TD>
              <TD>$tuple</TD>
              <TD>$virtualxid</TD>
              <TD>$transactionid</TD>
              <TD>$classid</TD>
              <TD>$objid</TD>
              <TD>$objsubid</TD>
              <TD>$virtualtransaction</TD>
              <TD>$pid</TD>
              <TD>$mode</TD>
              <TD>$granted</TD>
              <TD>$fastpath</TD>
              <TD>$waitstart</TD>
          </TR>" ;
         }
   $sth_locks->finish() ;
   $dbh_locks->disconnect() ;
   }

print "<!-- конец таблицы третьего уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
