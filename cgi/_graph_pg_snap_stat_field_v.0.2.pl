#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
require "/var/www/camactsost/cgi/common_parameter.camactsost" ;
require "$camactsost_dir_lib/lib_common_func.pl" ;
require "$camactsost_dir_lib/lib_camactsost_pg_monitor.pl" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;
#$COMM_PAR_PGSQL_DB_NAME = $pv{db_name} ;

#-debug-$pv{period_from} = "2024-05-02 00:00:00" ; $pv{period_to} = "2025-06-03 00:00:00" ; $pv{ds_type} = "MEM" ; $pv{width} = 1500 ; $pv{height} = 700 ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
my $count_rows = 0 ;
$debug_request = "" ;
$ext_where_conditions = "" ;

# -- вытащить данные из связанных с pg_stat_all_tables
if ($pv{data_table} eq "pg_stat_all_tables") {
   if ($pv{stat_obj} ne "undefined") { $ext_where_conditions .= " AND t.relid = $pv{stat_obj}" ; }
   if ($pv{stat_obj_id} ne "") { $ext_where_conditions .= " AND t.relid = $pv{stat_obj_id}" ; }
   if ($pv{stat_part_name} ne "") { $ext_where_conditions .= " AND t.relname like '%$pv{stat_part_name}%" ; }
   if ($pv{stat_owner} ne "undefined") { $ext_where_conditions .= " AND u.rolname = '$pv{stat_owner}'" ; }
   if ($pv{stat_schema} ne "undefined") { $ext_where_conditions .= " AND t.schemaname = '$pv{stat_schema}'" ; }

   if ($pv{stat_src_type} eq "range") {
      if ($pv{stat_obj} ne "undefined" || $pv{stat_obj_id} ne "") { $request_stat_all_tables = "select t.snap_id, t.relid, t.schemaname, t.relname, u.rolname, t.seq_scan, t.seq_tup_read, t.idx_scan, t.idx_tup_fetch, t.n_tup_ins, t.n_tup_upd, t.n_tup_del, t.n_tup_hot_upd, t.n_live_tup, t.n_dead_tup, t.n_mod_since_analyze, t.n_ins_since_vacuum, t.last_vacuum, t.last_autovacuum, t.last_analyze, t.last_autoanalyze, t.vacuum_count, t.autovacuum_count, t.analyze_count, t.autoanalyze_count from bestat_all_tables_deltas_view t, pg_class c, pg_authid u where t.relid = c.oid and c.relowner = u.oid and snap_id >= $pv{stat_start_snap_id} and snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions order by t.snap_id asc" ; }
      else { $request_stat_all_tables = "select snap_id, 'all', 'all', 'all', 'all', seq_scan, seq_tup_read, idx_scan, idx_tup_fetch, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd, n_live_tup, n_dead_tup, n_mod_since_analyze, n_ins_since_vacuum, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze, vacuum_count, autovacuum_count, analyze_count, autoanalyze_count from bestat_all_tables_sum_deltas_view where snap_id >= $pv{stat_start_snap_id} and snap_id <= $pv{stat_stop_snap_id}" ; }
      }
#---debug---print "<BR>=== $request_stat_all_tables ===<BR>" ;
   my $dbh_stat_all_tables = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_stat_all_tables = $dbh_stat_all_tables->prepare($request_stat_all_tables) ; $sth_stat_all_tables->execute() ; $count_rows = 0 ;
   while (my ($snap_id, $relid, $schemaname, $relname, $owner, $seq_scan, $seq_tup_read, $idx_scan, $idx_tup_fetch, $n_tup_ins, $n_tup_upd, $n_tup_del, $n_tup_hot_upd, $n_live_tup, $n_dead_tup, $n_mod_since_analyze, $n_ins_since_vacuum, $last_vacuum, $last_autovacuum, $last_analyze, $last_autoanalyze, $vacuum_count, $autovacuum_count, $analyze_count, $autoanalyze_count) = $sth_stat_all_tables->fetchrow_array() ) {
        $avg_data_source[0][$count_rows] = $snap_id ;
        if ($pv{data_field} eq "seq_scan") { $avg_data_source[1][$count_rows] = $seq_scan ; }
        if ($pv{data_field} eq "seq_tup_read") { $avg_data_source[1][$count_rows] = $seq_tup_read ; }
        if ($pv{data_field} eq "idx_scan") { $avg_data_source[1][$count_rows] = $idx_scan ; }
        if ($pv{data_field} eq "idx_tup_fetch") { $avg_data_source[1][$count_rows] = $idx_tup_fetch ; }
        if ($pv{data_field} eq "n_tup_ins") { $avg_data_source[1][$count_rows] = $n_tup_ins ; }
        if ($pv{data_field} eq "n_tup_upd") { $avg_data_source[1][$count_rows] = $n_tup_upd ; }
        if ($pv{data_field} eq "n_tup_del") { $avg_data_source[1][$count_rows] = $n_tup_del ; }
        if ($pv{data_field} eq "n_tup_hot_upd") { $avg_data_source[1][$count_rows] = $n_tup_hot_upd ; }
        if ($pv{data_field} eq "n_live_tup") { $avg_data_source[1][$count_rows] = $n_live_tup ; }
        if ($pv{data_field} eq "n_dead_tup") { $avg_data_source[1][$count_rows] = $n_dead_tup ; }
        if ($pv{data_field} eq "n_mod_since_analyze") { $avg_data_source[1][$count_rows] = $n_mod_since_analyze ; }
        if ($pv{data_field} eq "n_ins_since_vacuum") { $avg_data_source[1][$count_rows] = $n_ins_since_vacuum ; }
        if ($pv{data_field} eq "vacuum_count") { $avg_data_source[1][$count_rows] = $vacuum_count ; }
        if ($pv{data_field} eq "autovacuum_count") { $avg_data_source[1][$count_rows] = $autovacuum_count ; }
        if ($pv{data_field} eq "analyze_count") { $avg_data_source[1][$count_rows] = $analyze_count ; }
        if ($pv{data_field} eq "autoanalyze_count") { $avg_data_source[1][$count_rows] = $autoanalyze_count ; }
        $avg_data_source[2][$count_rows] = 1 ;
        $count_rows++ ; }
   $sth_stat_all_tables->finish() ;
   $dbh_stat_all_tables->disconnect() ;
   }

# -- вытащить данные из связанных с pg_statio_all_tables
if ($pv{data_table} eq "pg_statio_all_tables") {
   if ($pv{stat_obj} ne "undefined") { $ext_where_conditions .= " AND t.relid = $pv{stat_obj}" ; }
   if ($pv{stat_obj_id} ne "") { $ext_where_conditions .= " AND t.relid = $pv{stat_obj_id}" ; }
   if ($pv{stat_part_name} ne "") { $ext_where_conditions .= " AND t.relname like '%$pv{stat_part_name}%" ; }
   if ($pv{stat_owner} ne "undefined") { $ext_where_conditions .= " AND u.rolname = '$pv{stat_owner}'" ; }
   if ($pv{stat_schema} ne "undefined") { $ext_where_conditions .= " AND t.schemaname = '$pv{stat_schema}'" ; }

   if ($pv{stat_src_type} eq "range") {
      if ($pv{stat_obj} ne "undefined" || $pv{stat_obj_id} ne "") { $request_statio_all_tables = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.relid, t.schemaname, t.relname, u.rolname, t.heap_blks_read, t.heap_blks_hit, t.idx_blks_read, t.idx_blks_hit, t.toast_blks_read, t.toast_blks_hit, t.tidx_blks_read, t.tidx_blks_hit from bestat_io_all_tables_deltas_view t, pg_class c, pg_authid u, bestat_snapshots sn where t.relid = c.oid and c.relowner = u.oid and t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions order by t.snap_id asc" ; }
      else { $request_statio_all_tables = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, 'all', 'all', 'all', 'all', t.heap_blks_read, t.heap_blks_hit, t.idx_blks_read, t.idx_blks_hit, t.toast_blks_read, t.toast_blks_hit, t.tidx_blks_read, t.tidx_blks_hit from bestat_io_all_tables_sum_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
      }
#---debug---print "<BR>=== $request_statio_all_tables ===<BR>" ;
   my $dbh_statio_all_tables = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_statio_all_tables = $dbh_statio_all_tables->prepare($request_statio_all_tables) ; $sth_statio_all_tables->execute() ; $count_rows = 0 ;
   while (my ($snap_ts, $snap_id, $relid, $schemaname, $relname, $rolname, $heap_blks_read, $heap_blks_hit, $idx_blks_read, $idx_blks_hit, $toast_blks_read, $toast_blks_hit, $tidx_blks_read, $tidx_blks_hit) = $sth_statio_all_tables->fetchrow_array() ) {
         $avg_data_source[0][$count_rows] = $snap_id ;
         if ($pv{data_field} eq "heap_blks_read") { $avg_data_source[1][$count_rows] = $heap_blks_read ; }
         if ($pv{data_field} eq "heap_blks_hit") { $avg_data_source[1][$count_rows] = $heap_blks_hit ; }
         if ($pv{data_field} eq "idx_blks_read") { $avg_data_source[1][$count_rows] = $idx_blks_read ; }
         if ($pv{data_field} eq "idx_blks_hit") { $avg_data_source[1][$count_rows] = $idx_blks_hit ; }
         if ($pv{data_field} eq "toast_blks_read") { $avg_data_source[1][$count_rows] = $toast_blks_read ; }
         if ($pv{data_field} eq "toast_blks_hit") { $avg_data_source[1][$count_rows] = $toast_blks_hit ; }
         if ($pv{data_field} eq "tidx_blks_read") { $avg_data_source[1][$count_rows] = $tidx_blks_read ; }
         if ($pv{data_field} eq "tidx_blks_hit") { $avg_data_source[1][$count_rows] = $tidx_blks_hit ; }
         $avg_data_source[2][$count_rows] = 1 ;
         $count_rows++ ;
         }
   $sth_statio_all_tables->finish() ;
   $dbh_statio_all_tables->disconnect() ;
   }

# -- вытащить данные из связанных с pg_stat_all_indexes
if ($pv{data_table} eq "pg_stat_all_indexes") {
   if ($pv{stat_obj} ne "undefined") { $ext_where_conditions .= " AND t.indexrelid = $pv{stat_obj}" ; }
   if ($pv{stat_obj_id} ne "") { $ext_where_conditions .= " AND t.indexrelid = $pv{stat_obj_id}" ; }
   if ($pv{stat_part_name} ne "") { $ext_where_conditions .= " AND t.indexrelname like '%$pv{stat_part_name}%" ; }
   if ($pv{stat_owner} ne "undefined") { $ext_where_conditions .= " AND u.rolname = '$pv{stat_owner}'" ; }
   if ($pv{stat_schema} ne "undefined") { $ext_where_conditions .= " AND t.schemaname = '$pv{stat_schema}'" ; }

   if ($pv{stat_src_type} eq "range") {
      if ($pv{stat_obj} ne "undefined" || $pv{stat_obj_id} ne "") { $request_stat_all_indexes = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.relid, t.indexrelid, t.schemaname, t.relname, t.indexrelname, u.rolname, t.idx_scan, t.idx_tup_read, t.idx_tup_fetch from bestat_all_indexes_deltas_view t, pg_class c, pg_authid u, bestat_snapshots sn where t.relid = c.oid and c.relowner = u.oid and t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions order by t.snap_id asc" ; }
      else { $request_stat_all_indexes = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, 'all', 'all', 'all', 'all', 'all', 'all', t.idx_scan, t.idx_tup_read, t.idx_tup_fetch from bestat_all_indexes_sum_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
      }
   $debug_request = $request_stat_all_indexes ;
#---debug---print "<BR>=== $request_stat_all_indexes ===<BR>" ;
   $request_stat_archiver = "select relid, indexrelid, schemaname, relname, indexrelname, idx_scan, idx_tup_read, idx_tup_fetch from pg_catalog.pg_stat_all_indexes" ;
   my $dbh_stat_all_indexes = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_stat_all_indexes = $dbh_stat_all_indexes->prepare($request_stat_all_indexes) ; $sth_stat_all_indexes->execute() ; $count_rows = 0 ;
   while (my ($snap_ts, $snap_id, $relid, $indexrelid, $schemaname, $relname, $indexrelname, $owner, $idx_scan, $idx_tup_read, $idx_tup_fetch) = $sth_stat_all_indexes->fetchrow_array() ) {
         $avg_data_source[0][$count_rows] = $snap_id ;
         if ($pv{data_field} eq "idx_scan") { $avg_data_source[1][$count_rows] = $idx_scan ; }
         if ($pv{data_field} eq "idx_tup_read") { $avg_data_source[1][$count_rows] = $idx_tup_read ; }
         if ($pv{data_field} eq "idx_tup_fetch") { $avg_data_source[1][$count_rows] = $idx_tup_fetch ; }
         $avg_data_source[2][$count_rows] = 1 ;
         $count_rows++ ;
         }
   $sth_stat_all_indexes->finish() ;
   $dbh_stat_all_indexes->disconnect() ;
   }

# -- вытащить данные из связанных с pg_statio_all_indexes
if ($pv{data_table} eq "pg_statio_all_indexes") {
   if ($pv{stat_obj} ne "undefined") { $ext_where_conditions .= " AND t.indexrelid = $pv{stat_obj}" ; }
   if ($pv{stat_obj_id} ne "") { $ext_where_conditions .= " AND t.indexrelid = $pv{stat_obj_id}" ; }
   if ($pv{stat_part_name} ne "") { $ext_where_conditions .= " AND t.indexrelname like '%$pv{stat_part_name}%" ; }
   if ($pv{stat_owner} ne "undefined") { $ext_where_conditions .= " AND u.rolname = '$pv{stat_owner}'" ; }
   if ($pv{stat_schema} ne "undefined") { $ext_where_conditions .= " AND t.schemaname = '$pv{stat_schema}'" ; }

   if ($pv{stat_src_type} eq "range") {
      if ($pv{stat_obj} ne "undefined" || $pv{stat_obj_id} ne "") { $request_statio_all_indexes = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.relid, t.indexrelid, t.schemaname, t.relname, t.indexrelname, u.rolname, t.idx_blks_read, t.idx_blks_hit from bestat_io_all_indexes_deltas_view t, pg_class c, pg_authid u, bestat_snapshots sn where t.relid = c.oid and c.relowner = u.oid and t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions order by t.snap_id asc" ; }
      else { $request_statio_all_indexes = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, 'all', 'all', 'all', 'all', 'all', 'all', t.idx_blks_read, t.idx_blks_hit from bestat_io_all_indexes_sum_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
      }
#---debug---print "<BR>=== $request_stat_all_indexes ===<BR>" ;
   my $dbh_statio_all_indexes = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_statio_all_indexes = $dbh_statio_all_indexes->prepare($request_statio_all_indexes) ; $sth_statio_all_indexes->execute() ; $count_rows = 0 ;
   while (my ($snap_ts, $snap_id, $relid, $indexrelid, $schemaname, $relname, $indexrelname, $owner, $idx_blks_read, $idx_blks_hit) = $sth_statio_all_indexes->fetchrow_array() ) {
         $avg_data_source[0][$count_rows] = $snap_id ;
         if ($pv{data_field} eq "idx_blks_read") { $avg_data_source[1][$count_rows] = $idx_blks_read ; }
         if ($pv{data_field} eq "idx_blks_hit") { $avg_data_source[1][$count_rows] = $idx_blks_hit ; }
         $avg_data_source[2][$count_rows] = 1 ;
         $count_rows++ ;
         }
   $sth_statio_all_indexes->finish() ;
   $dbh_statio_all_indexes->disconnect() ;
   }

# -- вытащить данные из связанных с pg_stat_database
if ($pv{data_table} eq "pg_stat_database") {
   if ($pv{stat_obj} ne "undefined") { $ext_where_conditions .= " AND t.datid = $pv{stat_obj}" ; }
   if ($pv{stat_obj_id} ne "") { $ext_where_conditions .= " AND t.datid = $pv{stat_obj_id}" ; }
   if ($pv{stat_part_name} ne "") { $ext_where_conditions .= " AND t.datname like '%$pv{stat_part_name}%" ; }
 
   if ($pv{stat_src_type} eq "range") {
      if ($pv{stat_obj} ne "undefined" || $pv{stat_obj_id} ne "") { $request_stat_databases = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.datid, t.datname, t.numbackends, t.xact_commit, t.xact_rollback, t.blks_read, t.blks_hit, t.tup_returned, t.tup_fetched, t.tup_inserted, t.tup_updated, t.tup_deleted, t.conflicts, t.temp_files, t.temp_bytes, t.deadlocks, t.checksum_failures, t.checksum_last_failure, t.blk_read_time, t.blk_write_time, t.session_time, t.active_time, t.idle_in_transaction_time, t.sessions, t.sessions_abandoned, t.sessions_fatal, t.sessions_killed, t.stats_reset from bestat_database_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions" ; }
      else { $request_stat_databases = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, 'all', 'all', t.numbackends, t.xact_commit, t.xact_rollback, t.blks_read, t.blks_hit, t.tup_returned, t.tup_fetched, t.tup_inserted, t.tup_updated, t.tup_deleted, t.conflicts, t.temp_files, t.temp_bytes, t.deadlocks, t.checksum_failures, t.checksum_last_failure, t.blk_read_time, t.blk_write_time, t.session_time, t.active_time, t.idle_in_transaction_time, t.sessions, t.sessions_abandoned, t.sessions_fatal, t.sessions_killed, t.stats_reset from bestat_database_sum_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions" ; }
      }
#---debug---print "<BR>=== $request_stat_databases ===<BR>" ;
   my $dbh_stat_databases = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_stat_databases = $dbh_stat_databases->prepare($request_stat_databases) ; $sth_stat_databases->execute() ; $count_rows = 0 ;
   while (my ($snap_ts, $snap_id, $datid, $datname, $numbackends, $xact_commit, $xact_rollback, $blks_read, $blks_hit, $tup_returned, $tup_fetched, $tup_inserted, $tup_updated, $tup_deleted, $conflicts, $temp_files, $temp_bytes, $deadlocks, $checksum_failures, $checksum_last_failure, $blk_read_time, $blk_write_time, $session_time, $active_time, $idle_in_transaction_time, $sessions, $sessions_abandoned, $sessions_fatal, $sessions_killed, $stats_reset) = $sth_stat_databases->fetchrow_array() ) {
         $snap_ts =~ s/\s/&nbsp;/g ; $avg_data_source[0][$count_rows] = $snap_id ;
         if ($pv{data_field} eq "numbackends") { $avg_data_source[1][$count_rows] = $numbackends ; }
         if ($pv{data_field} eq "xact_commit") { $avg_data_source[1][$count_rows] = $xact_commit ; }
         if ($pv{data_field} eq "xact_rollback") { $avg_data_source[1][$count_rows] = $xact_rollback ; }
         if ($pv{data_field} eq "blks_read") { $avg_data_source[1][$count_rows] = $blks_read ; }
         if ($pv{data_field} eq "blks_hit") { $avg_data_source[1][$count_rows] = $blks_hit ; }
         if ($pv{data_field} eq "tup_returned") { $avg_data_source[1][$count_rows] = $tup_returned ; }
         if ($pv{data_field} eq "tup_fetched") { $avg_data_source[1][$count_rows] = $tup_fetched ; }
         if ($pv{data_field} eq "tup_inserted") { $avg_data_source[1][$count_rows] = $tup_inserted ; }
         if ($pv{data_field} eq "tup_updated") { $avg_data_source[1][$count_rows] = $tup_updated ; }
         if ($pv{data_field} eq "tup_deleted") { $avg_data_source[1][$count_rows] = $tup_deleted ; }
         if ($pv{data_field} eq "conflicts") { $avg_data_source[1][$count_rows] = $conflicts ; }
         if ($pv{data_field} eq "temp_files") { $avg_data_source[1][$count_rows] = $temp_files ; }
         if ($pv{data_field} eq "temp_bytes") { $avg_data_source[1][$count_rows] = $temp_bytes ; }
         if ($pv{data_field} eq "deadlocks") { $avg_data_source[1][$count_rows] = $deadlocks ; }
         if ($pv{data_field} eq "checksum_failures") { $avg_data_source[1][$count_rows] = $checksum_failures ; }
         if ($pv{data_field} eq "checksum_last_failure") { $avg_data_source[1][$count_rows] = $checksum_last_failure ; }
         if ($pv{data_field} eq "blk_read_time") { $avg_data_source[1][$count_rows] = $blk_read_time ; }
         if ($pv{data_field} eq "blk_write_time") { $avg_data_source[1][$count_rows] = $blk_write_time ; }
         if ($pv{data_field} eq "session_time") { $avg_data_source[1][$count_rows] = $session_time ; }
         if ($pv{data_field} eq "active_time") { $avg_data_source[1][$count_rows] = $active_time ; }
         if ($pv{data_field} eq "idle_in_transaction_time") { $avg_data_source[1][$count_rows] = $idle_in_transaction_time ; }
         if ($pv{data_field} eq "sessions") { $avg_data_source[1][$count_rows] = $sessions ; }
         if ($pv{data_field} eq "sessions_abandoned") { $avg_data_source[1][$count_rows] = $sessions_abandoned ; }
         if ($pv{data_field} eq "sessions_fatal") { $avg_data_source[1][$count_rows] = $sessions_fatal ; }
         if ($pv{data_field} eq "sessions_killed") { $avg_data_source[1][$count_rows] = $sessions_killed ; }
         $avg_data_source[2][$count_rows] = 1 ;
         $count_rows++ ;
         }
   $sth_stat_databases->finish() ;
   $dbh_stat_databases->disconnect() ;
   }

# -- вытащить данные из связанных с pg_stat_bgwriter
if ($pv{data_table} eq "pg_stat_bgwriter") {
   if ($pv{stat_src_type} eq "range") { $request_stat_bgwriter = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.checkpoints_timed, t.checkpoints_req, t.checkpoint_write_time, t.checkpoint_sync_time, t.buffers_checkpoint, t.buffers_clean, t.maxwritten_clean, t.buffers_backend, t.buffers_backend_fsync, t.buffers_alloc, t.stats_reset from bestat_bgwriter_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
#---debug---print "<BR>=== $request_stat_bgwriter ===<BR>" ;
   my $dbh_stat_bgwriter = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_stat_bgwriter = $dbh_stat_bgwriter->prepare($request_stat_bgwriter) ; $sth_stat_bgwriter->execute() ; $count_rows = 0 ;
   while (my ($snap_ts, $snap_id, $checkpoints_timed, $checkpoints_req, $checkpoint_write_time, $checkpoint_sync_time, $buffers_checkpoint, $buffers_clean, $maxwritten_clean, $buffers_backend, $buffers_backend_fsync, $buffers_alloc, $stats_reset) = $sth_stat_bgwriter->fetchrow_array() ) {
         $snap_ts =~ s/\s/&nbsp;/g ; $avg_data_source[0][$count_rows] = $snap_id ;
         if ($pv{data_field} eq "checkpoints_timed") { $avg_data_source[1][$count_rows] = $checkpoints_timed ; }
         if ($pv{data_field} eq "checkpoints_req") { $avg_data_source[1][$count_rows] = $checkpoints_req ; }
         if ($pv{data_field} eq "checkpoint_write_time") { $avg_data_source[1][$count_rows] = $checkpoint_write_time ; }
         if ($pv{data_field} eq "checkpoint_sync_time") { $avg_data_source[1][$count_rows] = $checkpoint_sync_time ; }
         if ($pv{data_field} eq "buffers_checkpoint") { $avg_data_source[1][$count_rows] = $buffers_checkpoint ; }
         if ($pv{data_field} eq "buffers_clean") { $avg_data_source[1][$count_rows] = $buffers_clean ; }
         if ($pv{data_field} eq "maxwritten_clean") { $avg_data_source[1][$count_rows] = $maxwritten_clean ; }
         if ($pv{data_field} eq "buffers_backend") { $avg_data_source[1][$count_rows] = $buffers_backend ; }
         if ($pv{data_field} eq "buffers_backend_fsync") { $avg_data_source[1][$count_rows] = $buffers_backend_fsync ; }
         if ($pv{data_field} eq "buffers_alloc") { $avg_data_source[1][$count_rows] = $buffers_alloc ; }
         $avg_data_source[2][$count_rows] = 1 ;
         $count_rows++ ;
         }
   $sth_stat_bgwriter->finish() ;
   $dbh_stat_bgwriter->disconnect() ;
   }

# -- вытащить данные из связанных с pg_stat_wal
if ($pv{data_table} eq "pg_stat_wal") {
   if ($pv{stat_src_type} eq "range") { $request_stat_wal = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.wal_records, t.wal_fpi, t.wal_bytes, t.wal_buffers_full, t.wal_write, t.wal_sync, t.wal_write_time, t.wal_sync_time, t.stats_reset from bestat_wal_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
#---debug---print "<BR>=== $request_stat_wal ===<BR>" ;
   my $dbh_stat_wal = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_stat_wal = $dbh_stat_wal->prepare($request_stat_wal) ; $sth_stat_wal->execute() ; $count_rows = 0 ;
   while (my ($snap_ts, $snap_id, $wal_records, $wal_fpi, $wal_bytes, $wal_buffers_full, $wal_write, $wal_sync, $wal_write_time, $wal_sync_time, $stats_reset) = $sth_stat_wal->fetchrow_array() ) {
         $snap_ts =~ s/\s/&nbsp;/g ; $avg_data_source[0][$count_rows] = $snap_id ;
         if ($pv{data_field} eq "wal_records") { $avg_data_source[1][$count_rows] = $wal_records ; }
         if ($pv{data_field} eq "wal_fpi") { $avg_data_source[1][$count_rows] = $wal_fpi ; }
         if ($pv{data_field} eq "wal_bytes") { $avg_data_source[1][$count_rows] = $wal_bytes ; }
         if ($pv{data_field} eq "wal_buffers_full") { $avg_data_source[1][$count_rows] = $wal_buffers_full ; }
         if ($pv{data_field} eq "wal_write") { $avg_data_source[1][$count_rows] = $wal_write ; }
         if ($pv{data_field} eq "wal_sync") { $avg_data_source[1][$count_rows] = $wal_sync ; }
         if ($pv{data_field} eq "wal_write_time") { $avg_data_source[1][$count_rows] = $wal_write_time ; }
         if ($pv{data_field} eq "wal_sync_time") { $avg_data_source[1][$count_rows] = $wal_sync_time ; }
         $avg_data_source[2][$count_rows] = 1 ;
         $count_rows++ ;
         }
   $sth_stat_wal->finish() ;
   $dbh_stat_wal->disconnect() ;
   }

if ($pv{out_type} eq "") { $pv{out_type} = "graph" ; }
if ($pv{out_type} eq "graph") {
   print "Content-Type: image/png\n\n";
# --------- заполнить данные для построения графика
   $dbh = DBI->connect('dbi:Chart:') or die "Cannot connect: " . $DBI::errstr ;
   $dbh->do('CREATE TABLE mychart (sampling_time VARCHAR(30), FIELD_VALUE FLOAT, HIDDEN_VALUE FLOAT)') or die $dbh->errstr;
#, Other FLOAT
   for ($i=0;$i<$count_rows;$i++) {
       $sth = $dbh->prepare('INSERT INTO mychart VALUES (?, ?, ?)');
       $sth->bind_param(1, "$avg_data_source[0][$i]");
       $sth->bind_param(2, $avg_data_source[1][$i]);
       $sth->bind_param(3, $avg_data_source[2][$i]);
       $sth->execute or die 'Cannot execute: ' . $sth->errstr;
       }

   $pv{width} = 1600 ; $pv{height} = 360 ;

   $chart_select = "SELECT LINEGRAPH FROM mychart WHERE WIDTH=$pv{width} AND HEIGHT=$pv{height} AND X_AXIS='Snap' and Y_AXIS='Values' AND CUMULATIVE='0' AND X_ORIENT='VERTICAL' AND
                           TITLE = 'Snap history for $pv{data_field} from $pv{stat_start_snap_id} to $pv{stat_stop_snap_id}' AND SIGNATURE = '(C)1974 - $CURR_YEAR, Sergey S. Belonin' AND
                           COLOR IN ('dblue', 'red') AND TEXTCOLOR = 'blue' AND FORMAT='PNG'" ;

   $sth = $dbh->prepare($chart_select) ;
   $sth->execute or die 'Cannot execute: ' . $sth->errstr;
   @row = $sth->fetchrow_array; print $row[0];
   }

if ($pv{out_type} eq "table") { print "Content-Type: text/html\n\n"; 
   print_header_1_1_cgi() ; print "КАМАктСоСт БЕССТ" ; print_header_1_2_cgi() ; system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ; print_header_2_1_cgi() ;
   $common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ; print_pg_monitor_main_page_title("Монитор состояния PostgreSQL: ", "$COMM_PAR_PGSQL_DB_NAME") ;
   print "<BR>Query:<BR>$debug_request<BR><BR>" ;
   print "<TABLE BORDER=\"1\">
          <TR><TD CLASS=\"td_head\">snap_id</TD><TD CLASS=\"td_head\">Field $pv{data_field} value</TD></TR>" ;
   for ($i=0;$i<$count_rows;$i++) { print "<TR><TD>$avg_data_source[0][$i]</TD><TD CLASS=\"td_right\">$avg_data_source[1][$i]</TD></TR>" ; }
   print "</TABLE>" ; print_foother1() ; }
