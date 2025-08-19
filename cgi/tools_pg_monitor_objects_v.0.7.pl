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

print_tools_pg_main_navigation(2) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>" ;
if ( $pv{tab_detail} eq "" ) { $pv{tab_detail} = 1 ; }
print_tools_pg_monitor_object_navigation($pv{tab_detail}) ;
print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;

if ($pv{tab_detail} == 1) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">OID</TD><TD CLASS=\"head\">Name</TD><TD CLASS=\"head\">Type</TD><TD CLASS=\"head\">Owner</TD></TR>" ; 
   $request_objects = "select c.oid, c.relname,
                              CASE WHEN c.relkind = 'r' THEN 'ordinary table'
                                   WHEN c.relkind = 'i' THEN 'index'
                                   WHEN c.relkind = 'S' THEN 'sequence'
                                   WHEN c.relkind = 't' THEN 'TOAST table'
                                   WHEN c.relkind = 'v' THEN 'view'
                                   WHEN c.relkind = 'm' THEN 'materialized view'
                                   WHEN c.relkind = 'c' THEN 'composite type'
                                   WHEN c.relkind = 'f' THEN 'foreign table'
                                   WHEN c.relkind = 'p' THEN 'partitioned tablepartitioned index'
                                   WHEN c.relkind = 'I' THEN 'partitioned index' END,
                              u.rolname from pg_class c, pg_authid u where c.relowner = u.oid order by c.oid" ;

   my $dbh_objects = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_objects = $dbh_objects->prepare($request_objects) ; $sth_objects->execute() ; $count_rows = 0 ;
   while (my ($oid, $relname, $reltype, $relowner) = $sth_objects->fetchrow_array() ) {
         print "<TR><TD>$oid</TD><TD>$relname</TD><TD>$reltype</TD><TD>$relowner</TD></TR> " ;
         $count_rows++ ;
         }
   $sth_objects->finish() ;
   $dbh_objects->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"5\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"5\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;
   }

if ($pv{tab_detail} == 2) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ; 
   print "<TR><TD CLASS=\"head\">OID</TD>
              <TD CLASS=\"head\">schema</TD>
              <TD CLASS=\"head\">table</TD>
              <TD CLASS=\"head\">owner</TD>
              <TD CLASS=\"head\">tablespace</TD>
              <TD CLASS=\"head\">table size</TD>
              <TD CLASS=\"head\">hasindexes</TD>
              <TD CLASS=\"head\">hasrules</TD>
              <TD CLASS=\"head\">hastriggers</TD>
              <TD CLASS=\"head\">rowsecurity</TD></TR>" ; 

   $query_where_sz = "" ; if ( $pv{one_oid_detail} ne "" && $pv{one_oid_detail} > 0 ) { $query_where_sz = " AND c.oid = $pv{one_oid_detail} " ; }
   $request_tables = "SELECT c.oid, n.nspname AS schemaname, c.relname AS tablename, pg_get_userbyid(c.relowner) AS tableowner, t.spcname AS tablespace, pg_table_size(c.oid), relhasindex,
                             c.relhasrules, c.relhastriggers, c.relrowsecurity
                             FROM pg_class c
                                  LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
                                  LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
                                  WHERE c.relkind = ANY (ARRAY['r'::\"char\", 'p'::\"char\"]) $query_where_sz" ;

   my $dbh_tables = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_tables = $dbh_tables->prepare($request_tables) ; $sth_tables->execute() ; $count_rows = 0 ;
   while (my ($oid, $schemaname, $tablename, $tableowner, $tablespace, $table_size, $hasindexes, $hasrules, $hastriggers, $rowsecurity) = $sth_tables->fetchrow_array() ) {
         print "<TR><TD>$oid</TD>
                    <TD>$schemaname</TD>
                    <TD><A HREF=\"/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=2&one_oid_detail=$oid\">$tablename</A></TD>
                    <TD>$tableowner</TD>
                    <TD>$tablespace</TD>
                    <TD>$table_size</TD>
                    <TD>$hasindexes</TD>
                    <TD>$hasrules</TD>
                    <TD>$hastriggers</TD>
                    <TD>$rowsecurity</TD></TR>" ; 
         $count_rows++ ;
         }
   $sth_tables->finish() ;
   $dbh_tables->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"10\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"10\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;

# если запрошена детализация - вывести ниже текст индекса
   if ( $pv{one_oid_detail} ne "" && $pv{one_oid_detail} > 0 ) { 
      $request_table_detail = "select * from ddlx_create($pv{one_oid_detail})" ;
      my $dbh_table_detail = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_table_detail = $dbh_table_detail->prepare($request_table_detail) ; $sth_table_detail->execute() ; $count_rows = 0 ;
      while (my ($table_ddl_create_script) = $sth_table_detail->fetchrow_array() ) { print "<P>Создание таблицы (DDLX):</P><PRE>$table_ddl_create_script</PRE>" ; }
      $sth_table_detail->finish() ; $dbh_table_detail->disconnect() ;
      }
   }

if ($pv{tab_detail} == 3) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">schema</TD><TD CLASS=\"head\">table</TD><TD CLASS=\"head\">index</TD><TD CLASS=\"head\">tablespace</TD></TR>" ; 

   $query_where_sz = "" ; if ( $pv{one_indexname} ne "" ) { $query_where_sz = " WHERE indexname = '$pv{one_indexname}' " ; }
   $request_indexes = "select schemaname, tablename, indexname, tablespace from pg_indexes $query_where_sz" ;

   my $dbh_indexes = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_indexes = $dbh_indexes->prepare($request_indexes) ; $sth_indexes->execute() ; $count_rows = 0 ;
   while (my ($schemaname, $tablename, $indexname, $tablespace) = $sth_indexes->fetchrow_array() ) {
         print "<TR><TD>$schemaname</TD>
                    <TD>$tablename</TD>
                    <TD><A HREF=\"/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=3&one_indexname=$indexname\">$indexname</A></TD>
                    <TD>$tablespace</TD></TR> " ;
         $count_rows++ ;
         }
   $sth_indexes->finish() ;
   $dbh_indexes->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"4\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"4\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;

# если запрошена детализация - вывести ниже текст индекса
   if ( $pv{one_indexname} ne "" ) { 
      $request_indexes_detail = "select indexdef from pg_indexes $query_where_sz" ;
      my $dbh_indexes_detail = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_indexes_detail = $dbh_indexes_detail->prepare($request_indexes_detail) ; $sth_indexes_detail->execute() ; $count_rows = 0 ;
      while (my ($indexdef) = $sth_indexes_detail->fetchrow_array() ) { print "<P>Текст индекса:</P><PRE>$indexdef</PRE>" ; }
      $sth_indexes_detail->finish() ;
      $dbh_indexes_detail->disconnect() ;
      }

   }

if ($pv{tab_detail} == 4) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">schemaname</TD><TD CLASS=\"head\">viewname</TD><TD CLASS=\"head\">viewowner</TD></TR> " ;

   $query_where_sz = "" ; if ( $pv{one_viewname} ne "" ) { $query_where_sz = " WHERE viewname = '$pv{one_viewname}' " ; }
   $request_views = "select schemaname, viewname, viewowner from pg_views $query_where_sz" ;

   my $dbh_views = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_views = $dbh_views->prepare($request_views) ; $sth_views->execute() ; $count_rows = 0 ;
   while (my ($schemaname, $viewname, $viewowner) = $sth_views->fetchrow_array() ) {
         print "<TR><TD>$schemaname</TD>
                    <TD><A HREF=\"/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=4&one_viewname=$viewname\">$viewname</A></TD>
                    <TD>$viewowner</TD></TR> " ;
         $count_rows++ ;
         }
   $sth_views->finish() ;
   $dbh_views->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"3\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"3\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;

# если запрошена детализация - вывести ниже текст представления
   if ( $pv{one_viewname} ne "" ) {
      $request_views_detail = "select definition from pg_views $query_where_sz" ;
      my $dbh_views_detail = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_views_detail = $dbh_views_detail->prepare($request_views_detail) ; $sth_views_detail->execute() ; $count_rows = 0 ;
      while (my ($definition) = $sth_views_detail->fetchrow_array() ) { print "<P>Текст представления:</P><PRE>$definition</PRE>" ; }
      $sth_views_detail->finish() ;
      $dbh_views_detail->disconnect() ;
      }
   }

if ($pv{tab_detail} == 5) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR>" ;
   #print"<TDCLASS=\"head\">oid</TD><TDCLASS=\"head\">proname</TD><TDCLASS=\"head\">pronamespace</TD><TDCLASS=\"head\">proowner</TD><TDCLASS=\"head\">prolang</TD><TDCLASS=\"head\">procost</TD><TDCLASS=\"head\">prorows</TD><TDCLASS=\"head\">provariadic</TD><TDCLASS=\"head\">prosupport</TD><TDCLASS=\"head\">prokind</TD><TDCLASS=\"head\">prosecdef</TD><TDCLASS=\"head\">proleakproof</TD><TDCLASS=\"head\">proisstrict</TD><TDCLASS=\"head\">proretset</TD><TDCLASS=\"head\">provolatile</TD><TDCLASS=\"head\">proparallel</TD><TDCLASS=\"head\">pronargs</TD><TDCLASS=\"head\">pronargdefaults</TD><TDCLASS=\"head\">prorettype</TD><TDCLASS=\"head\">proargtypes</TD><TDCLASS=\"head\">proallargtypes</TD><TDCLASS=\"head\">proargmodes</TD><TDCLASS=\"head\">proargnames</TD><TDCLASS=\"head\">proargdefaults</TD><TDCLASS=\"head\">protrftypes</TD><TDCLASS=\"head\">prosrc</TD><TDCLASS=\"head\">probin</TD><TDCLASS=\"head\">prosqlbody</TD><TDCLASS=\"head\">proconfig</TD><TDCLASS=\"head\">proacl</TD></TR>";

   print "<TD CLASS=\"head\">oid</TD>
          <TD CLASS=\"head\">proname</TD>
          <TD CLASS=\"head\">pronamespace</TD>
          <TD CLASS=\"head\">proowner</TD>
          <TD CLASS=\"head\">prolang</TD>
          <TD CLASS=\"head\">procost</TD>
          <TD CLASS=\"head\">prorows</TD>
          <TD CLASS=\"head\">prokind</TD>
          <TD CLASS=\"head\">proacl</TD>
          </TR>" ;

   $query_where_sz = "" ; if ( $pv{one_oid_detail} ne "" && $pv{one_oid_detail} > 0 ) { $query_where_sz = " WHERE oid = $pv{one_oid_detail} " ; }
   $request_proc = "select oid, proname, pronamespace, proowner, prolang, procost, prorows, prokind, proacl from pg_proc $query_where_sz" ;

   my $dbh_proc = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_proc = $dbh_proc->prepare($request_proc) ; $sth_proc->execute() ; $count_rows = 0 ;
   while (my ($oid, $proname, $pronamespace, $proowner, $prolang, $procost, $prorows, $prokind, $proacl) = $sth_proc->fetchrow_array() ) {
         print "<TR>" ;
         print "<TD>$oid</TD>
                <TD><A HREF=\"/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=5&one_oid_detail=$oid\">$proname</A></TD>
                <TD>$pronamespace</TD>
                <TD>$proowner</TD>
                <TD>$prolang</TD>
                <TD>$procost</TD>
                <TD>$prorows</TD>
                <TD>$prokind</TD>
                <TD>$proacl</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_proc->finish() ;
   $dbh_proc->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"9\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"9\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;

# если запрошена детализация - вывести ниже текст процедуры
   if ( $pv{one_oid_detail} ne "" && $pv{one_oid_detail} > 0 ) {
      $request_proc_detail = "select prosrc from pg_proc $query_where_sz" ;
      my $dbh_proc_detail = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_proc_detail = $dbh_proc_detail->prepare($request_proc_detail) ; $sth_proc_detail->execute() ; $count_rows = 0 ;
      while (my ($prosrc) = $sth_proc_detail->fetchrow_array() ) { print "<P>Текст процедуры или функции:</P><PRE>$prosrc</PRE>" ; }
      $sth_proc_detail->finish() ;
      $dbh_proc_detail->disconnect() ;
      }
   }

if ($pv{tab_detail} == 6) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\" COLSPAN=\"3\">trigger</TD>
              <TD CLASS=\"head\" COLSPAN=\"4\">event_object</TD>
              <TD CLASS=\"head\" COLSPAN=\"5\">action</TD>
              <TD CLASS=\"head\" COLSPAN=\"4\">action_reference</TD>
              <TD CLASS=\"head\" ROWSPAN=\"2\">created</TD>
          </TR>" ;
   print "<TR><TD CLASS=\"head\">catalog</TD>
              <TD CLASS=\"head\">schema</TD>
              <TD CLASS=\"head\">name</TD>
              <TD CLASS=\"head\">manipulation</TD>
              <TD CLASS=\"head\">catalog</TD>
              <TD CLASS=\"head\">schema</TD>
              <TD CLASS=\"head\">table</TD>
              <TD CLASS=\"head\">order</TD>
              <TD CLASS=\"head\">condition</TD>
              <TD CLASS=\"head\">statement</TD>
              <TD CLASS=\"head\">orientation</TD>
              <TD CLASS=\"head\">timing</TD>
              <TD CLASS=\"head\">old_table</TD>
              <TD CLASS=\"head\">new_table</TD>
              <TD CLASS=\"head\">old_row</TD>
              <TD CLASS=\"head\">new_row</TD>
          </TR>" ;
   $query_where_sz = "" ; if ( $pv{one_oid_detail} ne "" && $pv{one_oid_detail} > 0 ) { $query_where_sz = " WHERE oid = $pv{one_oid_detail} " ; }
   $request_triggers = "select trigger_catalog, trigger_schema, trigger_name, event_manipulation, event_object_catalog, event_object_schema, event_object_table, action_order, action_condition, action_statement,
                               action_orientation, action_timing, action_reference_old_table, action_reference_new_table, action_reference_old_row, action_reference_new_row, created
                               from information_schema.triggers $query_where_sz" ;

   my $dbh_triggers = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_triggers = $dbh_triggers->prepare($request_triggers) ; $sth_triggers->execute() ; $count_rows = 0 ;
   while (my ($trigger_catalog, $trigger_schema, $trigger_name, $event_manipulation, $event_object_catalog, $event_object_schema, $event_object_table, $action_order, $action_condition, $action_statement, $action_orientation, $action_timing, $action_reference_old_table, $action_reference_new_table, $action_reference_old_row, $action_reference_new_row, $created) = $sth_triggers->fetchrow_array() ) {
         print "<TR><TD>$trigger_catalog</TD>
                    <TD>$trigger_schema</TD>
                    <TD><A HREF=\"/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=6&one_oid_detail=$seqrelid\">$trigger_name</A></TD>
                    <TD>$event_manipulation</TD>
                    <TD>$event_object_catalog</TD>
                    <TD>$event_object_schema</TD>
                    <TD>$event_object_table</TD>
                    <TD>$action_order</TD>
                    <TD>$action_condition</TD>
                    <TD>$action_statement</TD>
                    <TD>$action_orientation</TD>
                    <TD>$action_timing</TD>
                    <TD>$action_reference_old_table</TD>
                    <TD>$action_reference_new_table</TD>
                    <TD>$action_reference_old_row</TD>
                    <TD>$action_reference_new_row</TD>
                    <TD>$created</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_triggers->finish() ;
   $dbh_triggers->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"17\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"17\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;
   }

if ($pv{tab_detail} == 7) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">seqrelid</TD>
              <TD CLASS=\"head\">relname</TD>
              <TD CLASS=\"head\">seqtypid</TD>
              <TD CLASS=\"head\">seqstart</TD>
              <TD CLASS=\"head\">seqincrement</TD>
              <TD CLASS=\"head\">seqmax</TD>
              <TD CLASS=\"head\">seqmin</TD>
              <TD CLASS=\"head\">seqcache</TD>
              <TD CLASS=\"head\">seqcycle</TD>
          </TR>" ;

   $query_where_sz = "" ; if ( $pv{one_oid_detail} ne "" && $pv{one_oid_detail} > 0 ) { $query_where_sz = " AND oid = $pv{one_oid_detail} " ; }
   $request_seq = "select s.seqrelid, c.relname, s.seqtypid, s.seqstart, s.seqincrement, s.seqmax, s.seqmin, s.seqcache, s.seqcycle from pg_catalog.pg_sequence s, pg_catalog.pg_class c where s.seqrelid = c.oid $query_where_sz" ;

   my $dbh_seq = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_seq = $dbh_seq->prepare($request_seq) ; $sth_seq->execute() ; $count_rows = 0 ;
   while (my ($seqrelid, $relname, $seqtypid, $seqstart, $seqincrement, $seqmax, $seqmin, $seqcache, $seqcycle) = $sth_seq->fetchrow_array() ) {
         print "<TR><TD>$seqrelid</TD>
                    <TD><A HREF=\"/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=7&one_oid_detail=$seqrelid\">$relname</A></TD>
                    <TD>$seqtypid</TD>
                    <TD>$seqstart</TD>
                    <TD>$seqincrement</TD>
                    <TD>$seqmax</TD>
                    <TD>$seqmin</TD>
                    <TD>$seqcache</TD>
                    <TD>$seqcycle</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_seq->finish() ;
   $dbh_seq->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"9\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"9\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;

# если запрошена детализация - вывести ниже текст процедуры
   if ( $pv{one_oid_detail} ne "" && $pv{one_oid_detail} > 0 ) {
      $request_seq_detail = "select prosrc from pg_proc $query_where_sz" ;
      my $dbh_seq_detail = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_seq_detail = $dbh_seq_detail->prepare($request_seq_detail) ; $sth_seq_detail->execute() ; $count_rows = 0 ;
      while (my ($prosrc) = $sth_seq_detail->fetchrow_array() ) { print "<P>Текст процедуры или функции:</P><PRE>$prosrc</PRE>" ; }
      $sth_seq_detail->finish() ;
      $dbh_seq_detail->disconnect() ;
      }
   }

print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
