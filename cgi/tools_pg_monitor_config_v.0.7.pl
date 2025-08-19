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

print_tools_pg_main_navigation(1) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>" ;
if ( $pv{tab_detail} eq "" ) { $pv{tab_detail} = 1 ; }
print_tools_pg_monitor_config_navigation($pv{tab_detail}) ;

print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;
print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;

if ($pv{tab_detail} == 1) {
   print "<TR><TD CLASS=\"head\">name</TD>
              <TD CLASS=\"head\">setting</TD>
              <TD CLASS=\"head\">unit</TD>
              <TD CLASS=\"head\">category</TD>
              <TD CLASS=\"head\">context</TD>
              <TD CLASS=\"head\">vartype</TD>
              <TD CLASS=\"head\">boot_val</TD>
          </TR>" ;

   $request_settings = "select name, setting, unit, category, context, vartype, boot_val from pg_settings" ;

   my $dbh_settings = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_settings = $dbh_settings->prepare($request_settings) ; $sth_settings->execute() ; $count_rows = 0 ;
   while (my ($name, $setting, $unit, $category, $context, $vartype, $boot_val) = $sth_settings->fetchrow_array() ) {
         print "<TR><TD>$name</TD>
                    <TD>$setting</TD>
                    <TD>$unit</TD>
                    <TD>$category</TD>
                    <TD>$context</TD>
                    <TD>$vartype</TD>
                    <TD>$boot_val</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_settings->finish() ;
   $dbh_settings->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"7\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"7\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   }

if ($pv{tab_detail} == 2) {
   print "<TR><TD CLASS=\"head\">name</TD>
              <TD CLASS=\"head\">setting</TD>
              <TD CLASS=\"head\">unit</TD>
              <TD CLASS=\"head\">category</TD>
              <TD CLASS=\"head\">short_desc</TD>
              <TD CLASS=\"head\">extra_desc</TD>
              <TD CLASS=\"head\">context</TD>
              <TD CLASS=\"head\">vartype</TD>
              <TD CLASS=\"head\">source</TD>
              <TD CLASS=\"head\">min_val</TD>
              <TD CLASS=\"head\">max_val</TD>
              <TD CLASS=\"head\">enumvals</TD>
              <TD CLASS=\"head\">boot_val</TD>
              <TD CLASS=\"head\">reset_val</TD>
              <TD CLASS=\"head\">sourcefile</TD>
              <TD CLASS=\"head\">sourceline</TD>
              <TD CLASS=\"head\">pending_restart</TD>
          </TR>" ;

   $request_settings = "select name, setting, unit, category, short_desc, extra_desc, context, vartype, source, min_val, max_val, enumvals, boot_val, reset_val, sourcefile, sourceline, pending_restart from pg_settings" ;

   my $dbh_settings = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_settings = $dbh_settings->prepare($request_settings) ; $sth_settings->execute() ; $count_rows = 0 ;
   while (my ($name, $setting, $unit, $category, $short_desc, $extra_desc, $context, $vartype, $source, $min_val, $max_val, $enumvals, $boot_val, $reset_val, $sourcefile, $sourceline, $pending_restart) = $sth_settings->fetchrow_array() ) {
         print "<TR><TD>$name</TD>
                    <TD>$setting</TD>
                    <TD>$unit</TD>
                    <TD>$category</TD>
                    <TD>$short_desc</TD>
                    <TD>$extra_desc</TD>
                    <TD>$context</TD>
                    <TD>$vartype</TD>
                    <TD>$source</TD>
                    <TD>$min_val</TD>
                    <TD>$max_val</TD>
                    <TD>$enumvals</TD>
                    <TD>$boot_val</TD>
                    <TD>$reset_val</TD>
                    <TD>$sourcefile</TD>
                    <TD>$sourceline</TD>
                    <TD>$pending_restart</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_settings->finish() ;
   $dbh_settings->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"17\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"17\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   }

if ($pv{tab_detail} == 3) {
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

   $request_database = "select oid, datname, datdba, encoding, datlocprovider, datistemplate, datallowconn, datconnlimit, datfrozenxid, datminmxid,
                               dattablespace, datcollate, datctype, daticulocale, datcollversion, datacl
                               from pg_database" ;

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
                for ($i = 0;$i <= 250;$i++) { if ( $datacl->[$i] ne "" ) { print "$datacl->[$i]," ; } }
         print "</TD></TR>" ; 
         $count_rows++ ;
         }
   $sth_database->finish() ;
   $dbh_database->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"15\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"15\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   }

if ($pv{tab_detail} == 4) {
   print "<TR><TD CLASS=\"head\">oid</TD>
              <TD CLASS=\"head\">rolname</TD>
              <TD CLASS=\"head\">rolsuper</TD>
              <TD CLASS=\"head\">rolinherit</TD>
              <TD CLASS=\"head\">rolcreaterole</TD>
              <TD CLASS=\"head\">rolcreatedb</TD>
              <TD CLASS=\"head\">rolcanlogin</TD>
              <TD CLASS=\"head\">rolreplication</TD>
              <TD CLASS=\"head\">rolbypassrls</TD>
              <TD CLASS=\"head\">rolconnlimit</TD>
              <TD CLASS=\"head\">rolpassword</TD>
              <TD CLASS=\"head\">rolvaliduntil</TD>
          </TR>" ;
   $request_authid = "select oid, rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil from pg_authid order by oid" ;
   my $dbh_authid = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_authid = $dbh_authid->prepare($request_authid) ; $sth_authid->execute() ; $count_rows = 0 ;
   while (my ($oid, $rolname, $rolsuper, $rolinherit, $rolcreaterole, $rolcreatedb, $rolcanlogin, $rolreplication, $rolbypassrls, $rolconnlimit, $rolpassword, $rolvaliduntil) = $sth_authid->fetchrow_array() ) {
         print "<TR><TD>$oid</TD>
                    <TD>$rolname</TD>
                    <TD>$rolsuper</TD>
                    <TD>$rolinherit</TD>
                    <TD>$rolcreaterole</TD>
                    <TD>$rolcreatedb</TD>
                    <TD>$rolcanlogin</TD>
                    <TD>$rolreplication</TD>
                    <TD>$rolbypassrls</TD>
                    <TD>$rolconnlimit</TD>
                    <TD>$rolpassword</TD>
                    <TD>$rolvaliduntil</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_authid->finish() ;
   $dbh_authid->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"12\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"12\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   }

if ($pv{tab_detail} == 5) {
   print "<TR><TD CLASS=\"head\">roleid</TD>
              <TD CLASS=\"head\">roleid_name</TD>
              <TD CLASS=\"head\">member</TD>
              <TD CLASS=\"head\">member_name</TD>
              <TD CLASS=\"head\">grantor</TD>
              <TD CLASS=\"head\">grantor_name</TD>
              <TD CLASS=\"head\">admin_option</TD>
          </TR>" ;
   $request_authid_member = "select am.roleid, pa1.rolname, am.member, pa2.rolname, am.grantor, pa3.rolname, admin_option 
                                  from pg_auth_members am, pg_authid pa1, pg_authid pa2, pg_authid pa3
                                  where am.roleid = pa1.oid and am.member = pa2.oid and am.grantor = pa3.oid" ;
   my $dbh_authid_member = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_authid_member = $dbh_authid_member->prepare($request_authid_member) ; $sth_authid_member->execute() ; $count_rows = 0 ;
   while (my ($roleid, $roleid_name, $member, $member_name, $grantor, $grantor_name, $admin_option) = $sth_authid_member->fetchrow_array() ) {
   print "<TR><TD>$roleid</TD>
              <TD>$roleid_name</TD>
              <TD>$member</TD>
              <TD>$member_name</TD>
              <TD>$grantor</TD>
              <TD>$grantor_name</TD>
              <TD>$admin_option</TD>
          </TR>" ;
         $count_rows++ ;
         }
   $sth_authid_member->finish() ;
   $dbh_authid_member->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"7\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"7\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   }

if ($pv{tab_detail} == 6) {
   print "<TR><TD CLASS=\"head\">grantor</TD>
              <TD CLASS=\"head\">grantee</TD>
              <TD CLASS=\"head\">table_catalog</TD>
              <TD CLASS=\"head\">table_schema</TD>
              <TD CLASS=\"head\">table_name</TD>
              <TD CLASS=\"head\">privilege_type</TD>
              <TD CLASS=\"head\">is_grantable</TD>
              <TD CLASS=\"head\">with_hierarchy</TD>
           </TR>" ;
   $request_indexes = "select grantor, grantee, table_catalog, table_schema, table_name, privilege_type, is_grantable, with_hierarchy from information_schema.table_privileges" ;

   my $dbh_indexes = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_indexes = $dbh_indexes->prepare($request_indexes) ; $sth_indexes->execute() ; $count_rows = 0 ;
   while (my ($grantor, $grantee, $table_catalog, $table_schema, $table_name, $privilege_type, $is_grantable, $with_hierarchy) = $sth_indexes->fetchrow_array() ) {
         print "<TR><TD>$grantor</TD>
                    <TD>$grantee</TD>
                    <TD>$table_catalog</TD>
                    <TD>$table_schema</TD>
                    <TD>$table_name</TD>
                    <TD>$privilege_type</TD>
                    <TD>$is_grantable</TD>
                    <TD>$with_hierarchy</TD>
                 </TR>" ;
         $count_rows++ ;
         }
   $sth_indexes->finish() ;
   $dbh_indexes->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"8\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"8\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   }

if ($pv{tab_detail} == 7) {
   print "<TR><TD CLASS=\"head\">grantor</TD>
              <TD CLASS=\"head\">grantee</TD>
              <TD CLASS=\"head\">table_catalog</TD>
              <TD CLASS=\"head\">table_schema</TD>
              <TD CLASS=\"head\">table_name</TD>
              <TD CLASS=\"head\">column_name</TD>
              <TD CLASS=\"head\">privilege_type</TD>
              <TD CLASS=\"head\">is_grantable</TD>
           </TR>" ;
   $request_privileges = "select grantor, grantee, table_catalog, table_schema, table_name, column_name, privilege_type, is_grantable from information_schema.column_privileges" ;

   my $dbh_privileges = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_privileges = $dbh_privileges->prepare($request_privileges) ; $sth_privileges->execute() ; $count_rows = 0 ;
   while (my ($grantor, $grantee, $table_catalog, $table_schema, $table_name, $column_name, $privilege_type, $is_grantable) = $sth_privileges->fetchrow_array() ) {
         print "<TR><TD>$grantor</TD>
                    <TD>$grantee</TD>
                    <TD>$table_catalog</TD>
                    <TD>$table_schema</TD>
                    <TD>$table_name</TD>
                    <TD>$column_name</TD>
                    <TD>$privilege_type</TD>
                    <TD>$is_grantable</TD>
                 </TR>" ;
         $count_rows++ ;
         }
   $sth_privileges->finish() ;
   $dbh_privileges->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"8\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"8\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   }

if ($pv{tab_detail} == 8) {
   print "<TR><TD CLASS=\"head\">grantor</TD>
              <TD CLASS=\"head\">grantee</TD>
              <TD CLASS=\"head\">specific_catalog</TD>
              <TD CLASS=\"head\">specific_schema</TD>
              <TD CLASS=\"head\">specific_name</TD>
              <TD CLASS=\"head\">routine_catalog</TD>
              <TD CLASS=\"head\">routine_schema</TD>
              <TD CLASS=\"head\">routine_name</TD>
              <TD CLASS=\"head\">privilege_type</TD>
              <TD CLASS=\"head\">is_grantable</TD>
           </TR>" ;
   $request_routine_privileges = "select grantor, grantee, specific_catalog, specific_schema, specific_name, routine_catalog, routine_schema, routine_name, privilege_type, is_grantable
                              from information_schema.routine_privileges" ;
   my $dbh_routine_privileges = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_routine_privileges = $dbh_routine_privileges->prepare($request_routine_privileges) ; $sth_routine_privileges->execute() ; $count_rows = 0 ;
   while (my ($grantor, $grantee, $specific_catalog, $specific_schema, $specific_name, $routine_catalog, $routine_schema, $routine_name, $privilege_type, $is_grantable) = $sth_routine_privileges->fetchrow_array() ) {
         print "<TR><TD>$grantor</TD>
                    <TD>$grantee</TD>
                    <TD>$specific_catalog</TD>
                    <TD>$specific_schema</TD>
                    <TD>$specific_name</TD>
                    <TD>$routine_catalog</TD>
                    <TD>$routine_schema</TD>
                    <TD>$routine_name</TD>
                    <TD>$privilege_type</TD>
                    <TD>$is_grantable</TD>
                 </TR>" ;
         $count_rows++ ;
         }
   $sth_routine_privileges->finish() ;
   $dbh_routine_privileges->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"10\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"10\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   }

if ($pv{tab_detail} == 9) {
   print "<TR><TD CLASS=\"head\">oid</TD>
              <TD CLASS=\"head\">nspnamenspowner</TD>
              <TD CLASS=\"head\">nspownernspacl</TD>
              <TD CLASS=\"head\">nspacl</TD>
          </TR>" ;
   $request_namespaces = "select oid, nspname, nspowner, nspacl from pg_catalog.pg_namespace" ;

   my $dbh_namespaces = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_namespaces = $dbh_namespaces->prepare($request_namespaces) ; $sth_namespaces->execute() ; $count_rows = 0 ;
   while (my ($oid, $nspname, $nspowner, $nspacl) = $sth_namespaces->fetchrow_array() ) {
         print "<TR><TD>$oid</TD>
                    <TD>$nspname</TD>
                    <TD>$nspowner</TD>
                    <TD>" ;
                for ($i = 0;$i <= 150;$i++) { if ( $nspacl->[$i] ne "" ) { print "$nspacl->[$i]," ; } }
         print "</TD></TR>" ;
         $count_rows++ ;
         }
   $sth_namespaces->finish() ;
   $dbh_namespaces->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"4\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"4\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   }

print "</TABLE>" ;

print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
