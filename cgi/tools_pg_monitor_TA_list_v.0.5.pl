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

###print_tools_coin_navigation(8) ;
print_tools_pg_main_navigation(4) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>" ;
#print_tools_pg_main_navigation(4) ;
print_tools_pg_monitor_navigation(1) ;
print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>
       <TR><TD COLSPAN=\"3\">" ;

print_tools_pg_monitor_TA_list_detail($pv{tab_detail}) ;
print "<!-- таблица четвёртого - детализации - уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD>" ;

if ($pv{tab_detail} == 1) {
   $sz_current_date_short = `date "+%Y-%m-%d 00:00:00"` ;
       $sz_current_date = `date "+%Y-%m-%d 23:59:59"` ;
       $pv{period_from} = ( $pv{period_from} eq "" ) ? $sz_current_date_short : $pv{period_from} ;
       $pv{period_to} = ( $pv{period_to} eq "" ) ? $sz_current_date : $pv{period_to} ;

   $img_width = "147pt" ;
   $img_height = "90pt" ;
   @conn_def_keys = sort(keys(%conn_def)) ;
   print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\"><TR><TD STYLE=\"text-align: center;\">Вся активность кластера</TD><TD STYLE=\"text-align: center;\">Фоновая активность кластера</TD><TD STYLE=\"text-align: center;\">Активность отдельных БД</TD></TR>" ;
   for($i=0;$i<$#conn_def_keys;$i++) {
      if ($conn_def{$conn_def_keys[$i]} eq "" && $conn_cred_name{$conn_def_keys[$i]} eq "" && $conn_cred_passwd{$conn_def_keys[$i]} eq "") {
         print "<TR><TD COLSPAN=\"3\" STYLE=\"text-align: center; color: brown;\">$conn_desc{$conn_def_keys[$i]} &nbsp;&nbsp;&nbsp;&nbsp; $conn_cred_name{$conn_def_keys[$i]} &nbsp;&nbsp; $conn_def{$conn_def_keys[$i]} </TD></TR>" ; }
      else {
         print "<TR><TD COLSPAN=\"3\" STYLE=\"color: brown;\">Коннектор: $conn_desc{$conn_def_keys[$i]} &nbsp;&nbsp;&nbsp;&nbsp; $conn_cred_name{$conn_def_keys[$i]} &nbsp;&nbsp; $conn_def{$conn_def_keys[$i]} </TD></TR>" ;
         print "<TR><TD STYLE=\"text-align: center;\">
                    <A TARGET=\"_blank\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_SAH_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=&sess_state_filter=&is_user_backends=true&is_backgrounds=true&is_extensions=true&ds_type=MEM&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&width=1450&height=500\">
                       <IMG style=\"width: $img_width; height: $img_height;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_SAH_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=&sess_state_filter=&is_user_backends=true&is_backgrounds=true&is_extensions=true&ds_type=MEM&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&width=2800&height=640\"></A>
                    <BR><A TARGET=\"_blank\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=&sess_state_filter=&is_user_backends=true&is_backgrounds=true&is_extensions=true&ds_type=MEM&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&tab_detail=1\">
                           кластер целиком</A>
                    </TD><TD STYLE=\"text-align: center;\">
                    <A TARGET=\"_blank\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_SAH_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=&sess_state_filter=&is_user_backends=false&is_backgrounds=true&is_extensions=true&ds_type=MEM&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&width=1450&height=500\">
                       <IMG style=\"width: $img_width; height: $img_height;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_SAH_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=&sess_state_filter=&is_user_backends=false&is_backgrounds=true&is_extensions=true&ds_type=MEM&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&width=2800&height=640\"></A>
                    <BR>кластер фоновые
                    </TD>
                    <TD STYLE=\"text-align: center;\">" ;
         $request_database = "select oid, datname from pg_catalog.pg_database where datname not in ('template0','template1') order by oid asc" ;
     
         print "<TABLE BORDER=\"0\"><TR>" ;
         my $dbh_database = DBI->connect($conn_def{$conn_def_keys[$i]}, $conn_cred_name{$conn_def_keys[$i]}, $conn_cred_passwd{$conn_def_keys[$i]} ) ; my $sth_database = $dbh_database->prepare($request_database) ; $sth_database->execute() ;
         while (my ($oid, $datname) = $sth_database->fetchrow_array() ) {
               print "<TD STYLE=\"text-align: center;\">
                          <A TARGET=\"_blank\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=$oid&sess_state_filter=&is_user_backends=true&is_backgrounds=true&is_extensions=true&ds_type=MEM&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&tab_detail=1\">
                             <IMG style=\"width: $img_width; height: $img_height;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_SAH_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=$oid&sess_state_filter=&is_user_backends=true&is_backgrounds=true&is_extensions=true&ds_type=MEM&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&width=2800&height=640\"></A>
                          <BR>$datname [$oid]</TD>" ;
               }
         $sth_database->finish() ; $dbh_database->disconnect() ;

         my $dbh_database = DBI->connect($conn_def{$conn_def_keys[$i]}, $conn_cred_name{$conn_def_keys[$i]}, $conn_cred_passwd{$conn_def_keys[$i]} ) ; my $sth_database = $dbh_database->prepare($request_database) ; $sth_database->execute() ;
         while (my ($oid, $datname) = $sth_database->fetchrow_array() ) {
               print "<TD STYLE=\"text-align: center;\">
                          <A TARGET=\"_blank\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=$oid&sess_state_filter=&is_user_backends=true&is_backgrounds=true&is_extensions=true&ds_type=MEM&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&tab_detail=1\">
                             <IMG style=\"width: $img_width; height: $img_height;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_SAH_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=$oid&sess_state_filter=&is_user_backends=true&is_backgrounds=true&is_extensions=true&ds_type=MEM&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&width=2800&height=640\"></A>
                          <BR>$datname [$oid]</TD>" ;
               }
         $sth_database->finish() ; $dbh_database->disconnect() ;

         my $dbh_database = DBI->connect($conn_def{$conn_def_keys[$i]}, $conn_cred_name{$conn_def_keys[$i]}, $conn_cred_passwd{$conn_def_keys[$i]} ) ; my $sth_database = $dbh_database->prepare($request_database) ; $sth_database->execute() ;
         while (my ($oid, $datname) = $sth_database->fetchrow_array() ) {
               print "<TD STYLE=\"text-align: center;\">
                          <A TARGET=\"_blank\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=$oid&sess_state_filter=&is_user_backends=true&is_backgrounds=true&is_extensions=true&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&ds_type=MEM&tab_detail=1\">
                             <IMG style=\"width: $img_width; height: $img_height;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_SAH_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&dbid=$oid&sess_state_filter=&is_user_backends=true&is_backgrounds=true&is_extensions=true&curr_conn=$conn_def_keys[$i]&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&ds_type=MEM&width=2800&height=640\"></A>
                          <BR>$datname [$oid]</TD>" ;
               }
         $sth_database->finish() ; $dbh_database->disconnect() ;

         print "</TR></TABLE>" ;
         print "</TD></TR>" ;
         }
      }
   print "</TABLE>" ;
   }

if ($pv{tab_detail} == 2) {
   @conn_def_keys = sort(keys(%conn_def)) ;

#-debug-print "<BR>=== ключей $#conn_def_keys ===<BR>" ;
   print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">oid</TD>
              <TD CLASS=\"head\">DB name</TD>
              <TD CLASS=\"head\">dba</TD>
              <TD CLASS=\"head\">encoding</TD>
              <TD CLASS=\"head\">locprovider</TD>
              <TD CLASS=\"head\">istemplate</TD>
              <TD CLASS=\"head\">allowconn</TD>
              <TD CLASS=\"head\">connlimit</TD>
              <TD CLASS=\"head\">frozenxid</TD>
              <TD CLASS=\"head\">minmxid</TD>
              <TD CLASS=\"head\">tablespace</TD>
              <TD CLASS=\"head\">collate</TD>
              <TD CLASS=\"head\">ctype</TD>
              <TD CLASS=\"head\">iculocale</TD>
              <TD CLASS=\"head\">collversion</TD>
              <TD CLASS=\"head\">acl</TD>
          </TR>" ;

   for($i=0;$i<$#conn_def_keys;$i++) {
#-debug-print "<BR>=== итератор $i ===<BR>" ;
      if ($conn_def{$conn_def_keys[$i]} eq "" && $conn_cred_name{$conn_def_keys[$i]} eq "" && $conn_cred_passwd{$conn_def_keys[$i]} eq "") {
         print "<TR><TD COLSPAN=\"16\" STYLE=\"text-align: center; color: brown;\">$conn_desc{$conn_def_keys[$i]} &nbsp;&nbsp;&nbsp;&nbsp;$conn_cred_name{$conn_def_keys[$i]} &nbsp;&nbsp; $conn_def{$conn_def_keys[$i]} </TD></TR>" ; }
      else {
           print "<TR><TD COLSPAN=\"16\" STYLE=\"color: brown;\">Коннектор кластера: $conn_desc{$conn_def_keys[$i]} &nbsp;&nbsp;&nbsp;&nbsp; Пользователь: $conn_cred_name{$conn_def_keys[$i]} &nbsp;&nbsp; $conn_def{$conn_def_keys[$i]} </TD></TR>" ;

           $request_database = "select oid, datname, datdba, encoding, datlocprovider, datistemplate, datallowconn, datconnlimit, datfrozenxid, datminmxid,
                                       dattablespace, datcollate, datctype, daticulocale, datcollversion, datacl
                                       from pg_catalog.pg_database" ;

           my $dbh_database = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
           my $sth_database = $dbh_database->prepare($request_database) ; $sth_database->execute() ; $count_rows = 0 ;
           while (my ($oid, $datname, $datdba, $encoding, $datlocprovider, $datistemplate, $datallowconn, $datconnlimit, $datfrozenxid, $datminmxid, $dattablespace, $datcollate, $datctype, $daticulocale, $datcollversion, $datacl) = $sth_database->fetchrow_array() ) {
                 print "<TR><TD>$oid</TD>
                            <TD>$datname</TD>
                            <TD>$datdba</TD>
                            <TD>$encoding</TD>
                            <TD>$datlocprovider</TD>
                            <TD>$datistemplate</TD>
                            <TD>$datallowconn</TD>
                            <TD>$datconnlimit</TD>
                            <TD>$datfrozenxid</TD>
                            <TD>$datminmxid</TD>
                            <TD>$dattablespace</TD>
                            <TD>$datcollate</TD>
                            <TD>$datctype</TD>
                            <TD>$daticulocale</TD>
                            <TD>$datcollversion</TD><TD>" ;
                        for ($i_acl = 0;$i_acl <= 50;$i_acl++) { if ( $datacl->[$i_acl] ne "" ) { print "$datacl->[$i_acl]," ; } }
                  print "</TD></TR>" ;
                  }
           $sth_database->finish() ;
           $dbh_database->disconnect() ;
           }
      }
   print "</TABLE>" ;
   }

#print "<!-- конец таблицы четвёртого уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы третьего уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
