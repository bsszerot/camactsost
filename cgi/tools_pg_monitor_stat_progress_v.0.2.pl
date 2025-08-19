#!/usr/bin/perl

# open source soft - (C) 2025 CAMActSoSt BESST - in last part of (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
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
$progress_operation = "" ;
if ($pv{tab_detail} == 1 ) { $progress_operation = "BASE BACKUP" ; } if ($pv{tab_detail} == 2) { $progress_operation = "VACUUM" ; } if ($pv{tab_detail} == 3) { $progress_operation = "ANALYZE" ; }
if ($pv{tab_detail} == 4) { $progress_operation = "CLUSTER" ; } if ($pv{tab_detail} == 5) { $progress_operation = "INDEXES" ; } if ($pv{tab_detail} == 6) { $progress_operation = "COPY" ; }
print_pg_monitor_main_page_title("Состояние операций: ", $progress_operation) ;
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

print_tools_pg_main_navigation(6) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>" ;
if ( $pv{tab_detail} eq "" ) { $pv{tab_detail} = 1 ; }
print_tools_pg_monitor_stat_progress_detail($pv{tab_detail}) ;

print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;

# - группа PROGRESS
if ($pv{tab_detail} == 1) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">pid</TD>
              <TD CLASS=\"head\">phase</TD>
              <TD CLASS=\"head\">backup_total</TD>
              <TD CLASS=\"head\">backup_streamed</TD>
              <TD CLASS=\"head\">tablespaces_total</TD>
              <TD CLASS=\"head\">tablespaces_streamed</TD>
          </TR>" ;
   $request_progress_backup = "select pid, phase, backup_total, backup_streamed, tablespaces_total, tablespaces_streamed from pg_catalog.pg_stat_progress_basebackup" ;
   my $dbh_progress_backup = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_progress_backup = $dbh_progress_backup->prepare($request_progress_backup) ; $sth_progress_backup->execute() ; $count_rows = 0 ;
   while (my ($pid, $phase, $backup_total, $backup_streamed, $tablespaces_total, $tablespaces_streamed) = $sth_progress_backup->fetchrow_array() ) {
         print "<TR><TD>$pid</TD>
                    <TD>$phase</TD>
                    <TD>$backup_total</TD>
                    <TD>$backup_streamed</TD>
                    <TD>$tablespaces_total</TD>
                    <TD>$tablespaces_streamed</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_progress_backup->finish() ;
   $dbh_progress_backup->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"6\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"6\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;
   }

if ($pv{tab_detail} == 2) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">pid</TD>
              <TD CLASS=\"head\">datid</TD>
              <TD CLASS=\"head\">datname</TD>
              <TD CLASS=\"head\">relid</TD>
              <TD CLASS=\"head\">phase</TD>
              <TD CLASS=\"head\">heap_blks_total</TD>
              <TD CLASS=\"head\">heap_blks_scanned</TD>
              <TD CLASS=\"head\">heap_blks_vacuumed</TD>
              <TD CLASS=\"head\">index_vacuum_count</TD>
              <TD CLASS=\"head\">max_dead_tuples</TD>
              <TD CLASS=\"head\">num_dead_tuples</TD>
          </TR>" ;
   $request_progress_vacuum = "select pid, datid, datname, relid, phase, heap_blks_total, heap_blks_scanned, heap_blks_vacuumed, index_vacuum_count, max_dead_tuples, num_dead_tuples from pg_catalog.pg_stat_progress_vacuum" ;
   my $dbh_progress_vacuum = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_progress_vacuum = $dbh_progress_vacuum->prepare($request_progress_vacuum) ; $sth_progress_vacuum->execute() ; $count_rows = 0 ;
   while (my ($pid, $datid, $datname, $relid, $phase, $heap_blks_total, $heap_blks_scanned, $heap_blks_vacuumed, $index_vacuum_count, $max_dead_tuples, $num_dead_tuples) = $sth_progress_vacuum->fetchrow_array() ) {
         print "<TR><TD>$pid</TD>
                    <TD>$datid</TD>
                    <TD>$datname</TD>
                    <TD>$relid</TD>
                    <TD>$phase</TD>
                    <TD>$heap_blks_total</TD>
                    <TD>$heap_blks_scanned</TD>
                    <TD>$heap_blks_vacuumed</TD>
                    <TD>$index_vacuum_count</TD>
                    <TD>$max_dead_tuples</TD>
                    <TD>$num_dead_tuples</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_progress_vacuum->finish() ;
   $dbh_progress_vacuum->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"11\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"11\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;
   }

if ($pv{tab_detail} == 3) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\" ROWSPAN=\"2\">pid</TD>
              <TD CLASS=\"head\" ROWSPAN=\"2\">datname [datid]</TD>
              <TD CLASS=\"head\" ROWSPAN=\"2\">relid</TD>
              <TD CLASS=\"head\" ROWSPAN=\"2\">phase</TD>
              <TD CLASS=\"head\" COLSPAN=\"2\">Sample</TD>
              <TD CLASS=\"head\" COLSPAN=\"2\">Ext stats</TD>
              <TD CLASS=\"head\" COLSPAN=\"3\">Child tables</TD>
          </TR>" ;
   print "<TR><TD CLASS=\"head\">blks_total</TD>
              <TD CLASS=\"head\">blks_scanned</TD>
              <TD CLASS=\"head\">total</TD>
              <TD CLASS=\"head\">computed</TD>
              <TD CLASS=\"head\">total</TD>
              <TD CLASS=\"head\">done</TD>
              <TD CLASS=\"head\">current_relid</TD>
          </TR>" ;
   $request_progress_analyze = "select pid, datid, datname, relid, phase, sample_blks_total, sample_blks_scanned, ext_stats_total, ext_stats_computed, child_tables_total, child_tables_done, current_child_table_relid from pg_catalog.pg_stat_progress_analyze" ;
   my $dbh_progress_analyze = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_progress_analyze = $dbh_progress_analyze->prepare($request_progress_analyze) ; $sth_progress_analyze->execute() ; $count_rows = 0 ;
   while (my ($pid, $datid, $datname, $relid, $phase, $sample_blks_total, $sample_blks_scanned, $ext_stats_total, $ext_stats_computed, $child_tables_total, $child_tables_done, $current_child_table_relid) = $sth_progress_analyze->fetchrow_array() ) {
         print "<TR><TD>$pid</TD>
                    <TD>$datname [$datid]</TD>
                    <TD>$relid</TD>
                    <TD>$phase</TD>
                    <TD>$sample_blks_total</TD>
                    <TD>$sample_blks_scanned</TD>
                    <TD>$ext_stats_total</TD>
                    <TD>$ext_stats_computed</TD>
                    <TD>$child_tables_total</TD>
                    <TD>$child_tables_done</TD>
                    <TD>$current_child_table_relid</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_progress_analyze->finish() ;
   $dbh_progress_analyze->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"11\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"11\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;
   }

if ($pv{tab_detail} == 4) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">pid</TD>
              <TD CLASS=\"head\">datid</TD>
              <TD CLASS=\"head\">datname</TD>
              <TD CLASS=\"head\">relid</TD>
              <TD CLASS=\"head\">command</TD>
              <TD CLASS=\"head\">phase</TD>
              <TD CLASS=\"head\"> cluster_index_relid</TD>
              <TD CLASS=\"head\">heap_tuples_scanned</TD>
              <TD CLASS=\"head\">heap_tuples_written</TD>
              <TD CLASS=\"head\">heap_blks_total</TD>
              <TD CLASS=\"head\">heap_blks_scanned</TD>
              <TD CLASS=\"head\">index_rebuild_count</TD>
          </TR>" ;
   $request_progress_cluster = "select pid, datid, datname, relid, command, phase, cluster_index_relid, heap_tuples_scanned, heap_tuples_written, heap_blks_total, heap_blks_scanned, index_rebuild_count from pg_catalog.pg_stat_progress_cluster" ;
   my $dbh_progress_cluster = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_progress_cluster = $dbh_progress_cluster->prepare($request_progress_cluster) ; $sth_progress_cluster->execute() ; $count_rows = 0 ;
   while (my ($pid, $datid, $datname, $relid, $command, $phase, $cluster_index_relid, $heap_tuples_scanned, $heap_tuples_written, $heap_blks_total, $heap_blks_scanned, $index_rebuild_count) = $sth_progress_cluster->fetchrow_array() ) {
         print "<TR><TD>$pid</TD>
                    <TD>$datid</TD>
                    <TD>$datname</TD>
                    <TD>$relid</TD>
                    <TD>$command</TD>
                    <TD>$phase</TD>
                    <TD>$cluster_index_relid</TD>
                    <TD>$heap_tuples_scanned</TD>
                    <TD>$heap_tuples_written</TD>
                    <TD>$heap_blks_total</TD>
                    <TD>$heap_blks_scanned</TD>
                    <TD>$index_rebuild_count</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_progress_cluster->finish() ;
   $dbh_progress_cluster->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"12\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"12\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;
   }

if ($pv{tab_detail} == 5) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">pid</TD>
              <TD CLASS=\"head\">datid</TD>
              <TD CLASS=\"head\">datname</TD>
              <TD CLASS=\"head\">relid</TD>
              <TD CLASS=\"head\">index_relid</TD>
              <TD CLASS=\"head\">command</TD>
              <TD CLASS=\"head\">phase</TD>
              <TD CLASS=\"head\">lockers_total</TD>
              <TD CLASS=\"head\">lockers_done</TD>
              <TD CLASS=\"head\">current_locker_pid</TD>
              <TD CLASS=\"head\">blocks_total</TD>
              <TD CLASS=\"head\">blocks_done</TD>
              <TD CLASS=\"head\">tuples_total</TD>
              <TD CLASS=\"head\">tuples_done</TD>
              <TD CLASS=\"head\">partitions_total</TD>
              <TD CLASS=\"head\">partitions_done</TD>
          </TR>" ;
   $request_progress_create_index = "select pid, datid, datname, relid, index_relid, command, phase, lockers_total, lockers_done, current_locker_pid, blocks_total, blocks_done, tuples_total, tuples_done, partitions_total, partitions_done from pg_catalog.pg_stat_progress_create_index" ;
   my $dbh_progress_create_index = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_progress_create_index = $dbh_progress_create_index->prepare($request_progress_create_index) ; $sth_progress_create_index->execute() ; $count_rows = 0 ;
   while (my ($pid, $datid, $datname, $relid, $index_relid, $command, $phase, $lockers_total, $lockers_done, $current_locker_pid, $blocks_total, $blocks_done, $tuples_total, $tuples_done, $partitions_total, $partitions_done) = $sth_progress_create_index->fetchrow_array() ) {
         print "<TR><TD>$pid</TD>
                    <TD>$datid</TD>
                    <TD>$datname</TD>
                    <TD>$relid</TD>
                    <TD>$index_relid</TD>
                    <TD>$command</TD>
                    <TD>$phase</TD>
                    <TD>$lockers_total</TD>
                    <TD>$lockers_done</TD>
                    <TD>$current_locker_pid</TD>
                    <TD>$blocks_total</TD>
                    <TD>$blocks_done</TD>
                    <TD>$tuples_total</TD>
                    <TD>$tuples_done</TD>
                    <TD>$partitions_total</TD>
                    <TD>$partitions_done</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_progress_create_index->finish() ;
   $dbh_progress_create_index->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"16\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"10\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;
   }

if ($pv{tab_detail} == 6) {
   print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
   print "<TR><TD CLASS=\"head\">pid</TD>
              <TD CLASS=\"head\">datid</TD>
              <TD CLASS=\"head\">datname</TD>
              <TD CLASS=\"head\">relid</TD>
              <TD CLASS=\"head\">command</TD>
              <TD CLASS=\"head\">type</TD>
              <TD CLASS=\"head\">bytes_processed</TD>
              <TD CLASS=\"head\">bytes_total</TD>
              <TD CLASS=\"head\">tuples_processed</TD>
              <TD CLASS=\"head\">tuples_excluded</TD>
          </TR>" ;
   $request_progress_copy = "select pid, datid, datname, relid, command, type, bytes_processed, bytes_total, tuples_processed, tuples_excluded from pg_catalog.pg_stat_progress_copy" ;
   my $dbh_progress_copy = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_progress_copy = $dbh_progress_copy->prepare($request_progress_copy) ; $sth_progress_copy->execute() ; $count_rows = 0 ;
   while (my ($pid, $datid, $datname, $relid, $command, $type, $bytes_processed, $bytes_total, $tuples_processed, $tuples_excluded) = $sth_progress_copy->fetchrow_array() ) {
         print "<TR><TD>$pid</TD>
                    <TD>$datid</TD>
                    <TD>$datname</TD>
                    <TD>$relid</TD>
                    <TD>$command</TD>
                    <TD>$type</TD>
                    <TD>$bytes_processed</TD>
                    <TD>$bytes_total</TD>
                    <TD>$tuples_processed</TD>
                    <TD>$tuples_excluded</TD>
                </TR>" ;
         $count_rows++ ;
         }
   $sth_progress_copy->finish() ;
   $dbh_progress_copy->disconnect() ;
   if ($count_rows == 0) { print "<TR><TD COLSPAN=\"10\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"10\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
   print "</TABLE>" ;
   }

print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
