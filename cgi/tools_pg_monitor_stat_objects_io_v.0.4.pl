#!/usr/bin/perl

# open source soft - (C) 2025 CAMActSoSt BESST - in last part of (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
require "/var/www/camactsost/cgi/common_parameter.camactsost" ;
require "$camactsost_dir_lib/lib_common_func.pl" ;
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
print_pg_monitor_main_page_title("Статистики подсистем, объектов и I/O: ", "[]") ;

print_js_block_pg_monitor() ;

# этот блок нужен для сохранения данных в полях конкретных объектов модулей TOP Activity при вызове JS функций
print_hidden_variable_top_activity() ;

print_tools_pg_main_navigation(5) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>" ;
if ( $pv{tab_detail} eq "" ) { $pv{tab_detail} = 1 ; }
print_tools_pg_monitor_stat_obj_io_detail($pv{tab_detail}) ;

print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;

#print_stat_snap_filters() ;
if ($pv{child_tab_detail} eq "") { $pv{child_tab_detail} = "1" ; }

$ext_where_conditions = "" ;

if ($pv{tab_detail} == 1) {
   print_stat_snap_filters() ;
   if ($pv{stat_src_type} eq "range" && $pv{stat_is_graph_out} eq "true") { set_common_pg_mon_cgi_prefix() ;
      print "<BR><TABLE BORDER=\"1\" STYLE=\"text-align: left; width: 1100pt; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_left\">Последовательных сканирований<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=seq_scan&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     seq_scan</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=seq_scan\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=seq_scan\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Последовательные чтения отдельных записей<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=seq_tup_read&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     seq_tup_read</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=seq_tup_read\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=seq_tup_read\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Сканирований индексов<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=idx_scan&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     idx_scan</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=idx_scan\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=idx_scan\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Возвращено индексных записей<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=idx_tup_fetch&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     idx_tup_fetch</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=idx_tup_fetch\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=idx_tup_fetch\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Записей вставлен<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_ins&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     n_tup_ins</TD><TD CLASS=\"td_left\">
                 <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_ins\" TARGET=\"_blank\">
                    <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_ins\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Записей обновлено<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_upd&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     n_tup_upd</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_upd\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_upd\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Записей удалено<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_del&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     n_tup_del</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_del\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_del\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Записей обновлено HOT<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_hot_upd&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     n_tup_hot_upd</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_hot_upd\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_tup_hot_upd\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Записи живые<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_live_tup&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     n_live_tup</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_live_tup\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_live_tup\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Записи мёртвые<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_dead_tup&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     n_dead_tup</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_dead_tup\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_dead_tup\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Модифиицировано после ANALYZE<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_mod_since_analyze&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     n_mod_since_analyze</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_mod_since_analyze\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_mod_since_analyze\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Вставлено после VACUUM<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_ins_since_vacuum&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     n_ins_since_vacuum</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_ins_since_vacuum\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=n_ins_since_vacuum\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Операций VACUUM<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=vacuum_count&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     vacuum_count</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=vacuum_count\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=vacuum_count\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Автоматических операций VACUUM<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=autovacuum_count&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     autovacuum_count</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=autovacuum_count\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=autovacuum_count\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Операций ANALYZE<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=analyze_count&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     analyze_count</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=analyze_count\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=analyze_count\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Автоматических операций ANALYZE<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=autoanalyze_count&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     autoanalyze_count</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=autoanalyze_count\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_tables&data_field=\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             </TABLE><BR>" ;
         }
   if ($pv{stat_is_table_out} eq "true") {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">snap_ts</TD><TD CLASS=\"td_head\">snap_id</TD><TD CLASS=\"td_head\">relid</TD><TD CLASS=\"td_head\">schemaname</TD><TD CLASS=\"td_head\">relname</TD><TD CLASS=\"td_head\">owner</TD>
                 <TD CLASS=\"td_head\">seq_scan</TD><TD CLASS=\"td_head\">seq_tup_read</TD><TD CLASS=\"td_head\">idx_scan</TD><TD CLASS=\"td_head\">idx_tup_fetch</TD><TD CLASS=\"td_head\">n_tup_ins</TD>
                 <TD CLASS=\"td_head\">n_tup_upd</TD><TD CLASS=\"td_head\">n_tup_del</TD><TD CLASS=\"td_head\">n_tup_hot_upd</TD><TD CLASS=\"td_head\">n_live_tup</TD><TD CLASS=\"td_head\">n_dead_tup</TD>
                 <TD CLASS=\"td_head\">n_mod_since_analyze</TD><TD CLASS=\"td_head\">n_ins_since_vacuum</TD><TD CLASS=\"td_head\">last_vacuum</TD><TD CLASS=\"td_head\">last_autovacuum</TD><TD CLASS=\"td_head\">last_analyze</TD>
                 <TD CLASS=\"td_head\">last_autoanalyze</TD><TD CLASS=\"td_head\">vacuum_count</TD><TD CLASS=\"td_head\">autovacuum_count</TD><TD CLASS=\"td_head\">analyze_count</TD><TD CLASS=\"td_head\">autoanalyze_count</TD>
             </TR> " ;
      if ($pv{stat_obj} ne "undefined") { $ext_where_conditions .= " AND t.relid = $pv{stat_obj}" ; }
      if ($pv{stat_obj_id} ne "") { $ext_where_conditions .= " AND t.relid = $pv{stat_obj_id}" ; }
      if ($pv{stat_part_name} ne "") { $ext_where_conditions .= " AND t.relname like '%$pv{stat_part_name}%" ; }
      if ($pv{stat_owner} ne "undefined") { $ext_where_conditions .= " AND u.rolname = '$pv{stat_owner}'" ; }
      if ($pv{stat_schema} ne "undefined") { $ext_where_conditions .= " AND t.schemaname = '$pv{stat_schema}'" ; }

      if ($pv{stat_src_type} eq "curr") { $request_stat_all_tables = "select '-','текущее', t.relid, t.schemaname, t.relname, u.rolname, t.seq_scan, t.seq_tup_read, t.idx_scan, t.idx_tup_fetch, t.n_tup_ins, t.n_tup_upd, t.n_tup_del, t.n_tup_hot_upd, t.n_live_tup, t.n_dead_tup, t.n_mod_since_analyze, t.n_ins_since_vacuum, t.last_vacuum, t.last_autovacuum, t.last_analyze, t.last_autoanalyze, t.vacuum_count, t.autovacuum_count, t.analyze_count, t.autoanalyze_count from pg_catalog.pg_stat_all_tables t, pg_class c, pg_authid u where t.relid = c.oid and c.relowner = u.oid $ext_where_conditions" ; }
      if ($pv{stat_src_type} eq "snap") { $request_stat_all_tables = "select '-',snap_id, t.relid, t.schemaname, t.relname, u.rolname, t.seq_scan, t.seq_tup_read, t.idx_scan, t.idx_tup_fetch, t.n_tup_ins, t.n_tup_upd, t.n_tup_del, t.n_tup_hot_upd, t.n_live_tup, t.n_dead_tup, t.n_mod_since_analyze, t.n_ins_since_vacuum, t.last_vacuum, t.last_autovacuum, t.last_analyze, t.last_autoanalyze, t.vacuum_count, t.autovacuum_count, t.analyze_count, t.autoanalyze_count from bestat_all_tables_deltas_view t, pg_class c, pg_authid u where t.relid = c.oid and c.relowner = u.oid and t.snap_id = $pv{stat_src_snap_id} $ext_where_conditions" ; }
      if ($pv{stat_src_type} eq "range") {
         if ($pv{stat_obj} ne "undefined" || $pv{stat_obj_id} ne "") { $request_stat_all_tables = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.relid, t.schemaname, t.relname, u.rolname, t.seq_scan, t.seq_tup_read, t.idx_scan, t.idx_tup_fetch, t.n_tup_ins, t.n_tup_upd, t.n_tup_del, t.n_tup_hot_upd, t.n_live_tup, t.n_dead_tup, t.n_mod_since_analyze, t.n_ins_since_vacuum, t.last_vacuum, t.last_autovacuum, t.last_analyze, t.last_autoanalyze, t.vacuum_count, t.autovacuum_count, t.analyze_count, t.autoanalyze_count from bestat_all_tables_deltas_view t, pg_class c, pg_authid u, bestat_snapshots sn where t.relid = c.oid and c.relowner = u.oid and t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions order by t.snap_id asc" ; }
         else { $request_stat_all_tables = "select  to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, 'all', 'all', 'all', 'all', t.seq_scan, t.seq_tup_read, t.idx_scan, t.idx_tup_fetch, t.n_tup_ins, t.n_tup_upd, t.n_tup_del, t.n_tup_hot_upd, t.n_live_tup, t.n_dead_tup, t.n_mod_since_analyze, t.n_ins_since_vacuum, t.last_vacuum, t.last_autovacuum, t.last_analyze, t.last_autoanalyze, t.vacuum_count, t.autovacuum_count, t.analyze_count, t.autoanalyze_count from bestat_all_tables_sum_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
         }
#---debug---print "<BR>=== $request_stat_all_tables ===<BR>" ;
      my $dbh_stat_all_tables = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_all_tables = $dbh_stat_all_tables->prepare($request_stat_all_tables) ; $sth_stat_all_tables->execute() ; $count_rows = 0 ;
      while (my ($snap_ts, $snap_id, $relid, $schemaname, $relname, $owner, $seq_scan, $seq_tup_read, $idx_scan, $idx_tup_fetch, $n_tup_ins, $n_tup_upd, $n_tup_del, $n_tup_hot_upd, $n_live_tup, $n_dead_tup, $n_mod_since_analyze, $n_ins_since_vacuum, $last_vacuum, $last_autovacuum, $last_analyze, $last_autoanalyze, $vacuum_count, $autovacuum_count, $analyze_count, $autoanalyze_count) = $sth_stat_all_tables->fetchrow_array() ) {
            $snap_ts =~ s/\s/&nbsp;/g ;$last_vacuum =~ s/\s/&nbsp;/g ; $last_autovacuum =~ s/\s/&nbsp;/g ; $last_analyze =~ s/\s/&nbsp;/g ; $last_autoanalyze =~ s/\s/&nbsp;/g ;
            print "<TR><TD CLASS=\"td_left\">$snap_ts</TD><TD CLASS=\"td_right\">$snap_id</TD><TD CLASS=\"td_right\">$relid</TD><TD CLASS=\"td_left\">$schemaname</TD><TD CLASS=\"td_left\">$relname</TD><TD CLASS=\"td_left\">$owner</TD>
                       <TD CLASS=\"td_right\">$seq_scan</TD><TD CLASS=\"td_right\">$seq_tup_read</TD><TD CLASS=\"td_right\">$idx_scan</TD><TD CLASS=\"td_right\">$idx_tup_fetch</TD><TD CLASS=\"td_right\">$n_tup_ins</TD>
                       <TD CLASS=\"td_right\">$n_tup_upd</TD><TD CLASS=\"td_right\">$n_tup_del</TD><TD CLASS=\"td_right\">$n_tup_hot_upd</TD><TD CLASS=\"td_right\">$n_live_tup</TD><TD CLASS=\"td_right\">$n_dead_tup</TD>
                       <TD CLASS=\"td_right\">$n_mod_since_analyze</TD><TD CLASS=\"td_right\">$n_ins_since_vacuum</TD><TD CLASS=\"td_right\">$last_vacuum</TD><TD CLASS=\"td_right\">$last_autovacuum</TD>
                       <TD CLASS=\"td_right\">$last_analyze</TD><TD CLASS=\"td_right\">$last_autoanalyze</TD><TD CLASS=\"td_right\">$vacuum_count</TD><TD CLASS=\"td_right\">$autovacuum_count</TD>
                       <TD CLASS=\"td_right\">$analyze_count</TD><TD CLASS=\"td_right\">$autoanalyze_count</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_all_tables->finish() ;
      $dbh_stat_all_tables->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"25\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"25\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
      }
   }

if ($pv{tab_detail} == 2) {
   print_stat_snap_filters() ;
   if ($pv{stat_src_type} eq "range" && $pv{stat_is_graph_out} eq "true") { set_common_pg_mon_cgi_prefix() ;
      print "<BR><TABLE BORDER=\"1\" STYLE=\"text-align: left; width: 1100pt; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_left\">Чтения физические, блоков (heap)<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=heap_blks_read&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     heap_blks_read</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=heap_blks_read\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=heap_blks_read\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Чтения из кэша, блоков (heap)<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=heap_blks_hit&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     heap_blks_hit</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=heap_blks_hit\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=heap_blks_hit\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Чтения физические, блоков (индексы)<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=idx_blks_read&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     idx_blks_read</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=idx_blks_read\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=idx_blks_read\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Чтения из кэша, блоков (индексы)<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=idx_blks_hit&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     idx_blks_hit</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=idx_blks_hit\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=idx_blks_hit\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Чтения физические, блоков (toast)<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=toast_blks_read&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     toast_blks_read</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=toast_blks_read\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=toast_blks_read\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Чтения из кэша, блоков (toast)<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=toast_blks_hit&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     toast_blks_hit</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=toast_blks_hit\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=toast_blks_hit\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Чтения физические, блоков (toast index)<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=tidx_blks_read&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     tidx_blks_read</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=tidx_blks_read\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=tidx_blks_read\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Чтения из кэша, блоков (toast index)<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=tidx_blks_hit&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     tidx_blks_hit</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=tidx_blks_hit\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_tables&data_field=tidx_blks_hit\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             </TABLE><BR>" ;
         }
   if ($pv{stat_is_table_out} eq "true") {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">snap_ts</TD><TD CLASS=\"td_head\">snap_id</TD><TD CLASS=\"td_head\">relid</TD><TD CLASS=\"td_head\">schemaname</TD><TD CLASS=\"td_head\">relname</TD><TD CLASS=\"td_head\">owner</TD>
                 <TD CLASS=\"td_head\">heap_blks_read</TD><TD CLASS=\"td_head\">heap_blks_hit</TD><TD CLASS=\"td_head\">idx_blks_read</TD><TD CLASS=\"td_head\">idx_blks_hit</TD><TD CLASS=\"td_head\">toast_blks_read</TD>
                 <TD CLASS=\"td_head\">toast_blks_hit</TD><TD CLASS=\"td_head\">tidx_blks_read</TD><TD CLASS=\"td_head\">tidx_blks_hit</TD>
             </TR> " ;
      if ($pv{stat_obj} ne "undefined") { $ext_where_conditions .= " AND t.relid = $pv{stat_obj}" ; }
      if ($pv{stat_obj_id} ne "") { $ext_where_conditions .= " AND t.relid = $pv{stat_obj_id}" ; }
      if ($pv{stat_part_name} ne "") { $ext_where_conditions .= " AND t.relname like '%$pv{stat_part_name}%" ; }
      if ($pv{stat_owner} ne "undefined") { $ext_where_conditions .= " AND u.rolname = '$pv{stat_owner}'" ; }
      if ($pv{stat_schema} ne "undefined") { $ext_where_conditions .= " AND t.schemaname = '$pv{stat_schema}'" ; }
         
      if ($pv{stat_src_type} eq "curr") { $request_statio_all_tables = "select '-','текущее', t.relid, t.schemaname, t.relname, u.rolname,  t.heap_blks_read, t.heap_blks_hit, t.idx_blks_read, t.idx_blks_hit, t.toast_blks_read, t.toast_blks_hit, t.tidx_blks_read, t.tidx_blks_hit from pg_catalog.pg_statio_all_tables t, pg_class c, pg_authid u where t.relid = c.oid and c.relowner = u.oid $ext_where_conditions" ; }
      if ($pv{stat_src_type} eq "snap") { $request_statio_all_tables = "select '-',snap_id, t.relid, t.schemaname, t.relname, u.rolname, t.heap_blks_read, t.heap_blks_hit, t.idx_blks_read, t.idx_blks_hit, t.toast_blks_read, t.toast_blks_hit, t.tidx_blks_read, t.tidx_blks_hit from bestat_io_all_tables_deltas_view t, pg_class c, pg_authid u where t.relid = c.oid and c.relowner = u.oid and t.snap_id = $pv{stat_src_snap_id} $ext_where_conditions" ; }
      if ($pv{stat_src_type} eq "range") {
         if ($pv{stat_obj} ne "undefined" || $pv{stat_obj_id} ne "") { $request_statio_all_tables = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.relid, t.schemaname, t.relname, u.rolname, t.heap_blks_read, t.heap_blks_hit, t.idx_blks_read, t.idx_blks_hit, t.toast_blks_read, t.toast_blks_hit, t.tidx_blks_read, t.tidx_blks_hit from bestat_io_all_tables_deltas_view t, pg_class c, pg_authid u, bestat_snapshots sn where t.relid = c.oid and c.relowner = u.oid and t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions order by t.snap_id asc" ; }
         else { $request_statio_all_tables = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, 'all', 'all', 'all', 'all', t.heap_blks_read, t.heap_blks_hit, t.idx_blks_read, t.idx_blks_hit, t.toast_blks_read, t.toast_blks_hit, t.tidx_blks_read, t.tidx_blks_hit from bestat_io_all_tables_sum_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
         }
#---debug---print "<BR>=== $request_statio_all_tables ===<BR>" ;
      my $dbh_statio_all_tables = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_statio_all_tables = $dbh_statio_all_tables->prepare($request_statio_all_tables) ; $sth_statio_all_tables->execute() ; $count_rows = 0 ;
      while (my ($snap_ts, $snap_id, $relid, $schemaname, $relname, $rolname, $heap_blks_read, $heap_blks_hit, $idx_blks_read, $idx_blks_hit, $toast_blks_read, $toast_blks_hit, $tidx_blks_read, $tidx_blks_hit) = $sth_statio_all_tables->fetchrow_array() ) {
            print "<TR><TD CLASS=\"td_right\">$snap_ts</TD><TD CLASS=\"td_right\">$snap_id</TD><TD CLASS=\"td_right\">$relid</TD><TD CLASS=\"td_left\">$schemaname</TD><TD CLASS=\"td_left\">$relname</TD>
                       <TD CLASS=\"td_left\">$rolname</TD><TD CLASS=\"td_right\">$heap_blks_read</TD><TD CLASS=\"td_right\">$heap_blks_hit</TD><TD CLASS=\"td_right\">$idx_blks_read</TD><TD CLASS=\"td_right\">$idx_blks_hit</TD>
                       <TD CLASS=\"td_right\">$toast_blks_read</TD><TD CLASS=\"td_right\">$toast_blks_hit</TD><TD CLASS=\"td_right\">$tidx_blks_read</TD><TD CLASS=\"td_right\">$tidx_blks_hit</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_statio_all_tables->finish() ;
      $dbh_statio_all_tables->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"14\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"14\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
      }
   }

if ($pv{tab_detail} == 3) {
   print_stat_snap_filters() ;
   if ($pv{stat_src_type} eq "range" && $pv{stat_is_graph_out} eq "true") { set_common_pg_mon_cgi_prefix() ;
      print "<BR><TABLE BORDER=\"1\" STYLE=\"text-align: left; width: 1100pt; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_left\">Сканирований индексов<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_indexes&data_field=idx_scan&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     idx_scan</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_indexes&data_field=idx_scan\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_indexes&data_field=idx_scan\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Чтений индексных записей<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_indexes&data_field=idx_tup_read&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     idx_tup_read</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_indexes&data_field=idx_tup_read\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_indexes&data_field=idx_tup_read\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Возвратов индексных записей<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_indexes&data_field=idx_tup_fetch&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     idx_tup_fetch</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_indexes&data_field=idx_tup_fetch\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_stat_all_indexes&data_field=idx_tup_fetch\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             </TABLE><BR>" ;
         }
   if ($pv{stat_is_table_out} eq "true") {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">snap_ts</TD><TD CLASS=\"td_head\">snap_id</TD><TD CLASS=\"td_head\">relid</TD><TD CLASS=\"td_head\">indexrelid</TD><TD CLASS=\"td_head\">schemaname</TD><TD CLASS=\"td_head\">relname</TD>
                 <TD CLASS=\"td_head\">indexrelname</TD><TD CLASS=\"td_head\">owner</TD><TD CLASS=\"td_head\">idx_scan</TD><TD CLASS=\"td_head\">idx_tup_read</TD><TD CLASS=\"td_head\">idx_tup_fetch</TD>
             </TR> " ;
      if ($pv{stat_obj} ne "undefined") { $ext_where_conditions .= " AND t.indexrelid = $pv{stat_obj}" ; }
      if ($pv{stat_obj_id} ne "") { $ext_where_conditions .= " AND t.indexrelid = $pv{stat_obj_id}" ; }
      if ($pv{stat_part_name} ne "") { $ext_where_conditions .= " AND t.indexrelname like '%$pv{stat_part_name}%" ; }
      if ($pv{stat_owner} ne "undefined") { $ext_where_conditions .= " AND u.rolname = '$pv{stat_owner}'" ; }
      if ($pv{stat_schema} ne "undefined") { $ext_where_conditions .= " AND t.schemaname = '$pv{stat_schema}'" ; }

      if ($pv{stat_src_type} eq "curr") { $request_stat_all_indexes = "select '-', 'текущее', t.relid, t.indexrelid, t.schemaname, t.relname, t.indexrelname, u.rolname, t.idx_scan, t.idx_tup_read, t.idx_tup_fetch from pg_catalog.pg_stat_all_indexes t, pg_class c, pg_authid u where t.relid = c.oid and c.relowner = u.oid $ext_where_conditions" ; }
      if ($pv{stat_src_type} eq "snap") { $request_stat_all_indexes = "select '-', snap_id, t.relid, t.indexrelid, t.schemaname, t.relname, t.indexrelname, u.rolname, t.idx_scan, t.idx_tup_read, t.idx_tup_fetch  from bestat_all_indexes_deltas_view t, pg_class c, pg_authid u where t.relid = c.oid and c.relowner = u.oid and t.snap_id = $pv{stat_src_snap_id} $ext_where_conditions" ; }
      if ($pv{stat_src_type} eq "range") {
         if ($pv{stat_obj} ne "undefined" || $pv{stat_obj_id} ne "") { $request_stat_all_indexes = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.relid, t.indexrelid, t.schemaname, t.relname, t.indexrelname, u.rolname, t.idx_scan, t.idx_tup_read, t.idx_tup_fetch from bestat_all_indexes_deltas_view t, pg_class c, pg_authid u, bestat_snapshots sn where t.relid = c.oid and c.relowner = u.oid and t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions order by t.snap_id asc" ; }
         else { $request_stat_all_indexes = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, 'all', 'all', 'all', 'all', 'all', 'all', t.idx_scan, t.idx_tup_read, t.idx_tup_fetch from bestat_all_indexes_sum_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
         }
#---debug---print "<BR>=== $request_stat_all_indexes ===<BR>" ;
      $request_stat_archiver = "select relid, indexrelid, schemaname, relname, indexrelname, idx_scan, idx_tup_read, idx_tup_fetch from pg_catalog.pg_stat_all_indexes" ;
      my $dbh_stat_all_indexes = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_all_indexes = $dbh_stat_all_indexes->prepare($request_stat_all_indexes) ; $sth_stat_all_indexes->execute() ; $count_rows = 0 ;
      while (my ($snap_ts, $snap_id, $relid, $indexrelid, $schemaname, $relname, $indexrelname, $owner, $idx_scan, $idx_tup_read, $idx_tup_fetch) = $sth_stat_all_indexes->fetchrow_array() ) {
            print "<TR><TD CLASS=\"td_right\">$snap_ts</TD><TD CLASS=\"td_right\">$snap_id</TD><TD CLASS=\"td_right\">$relid</TD><TD CLASS=\"td_right\">$indexrelid</TD><TD CLASS=\"td_left\">$schemaname</TD>
                       <TD CLASS=\"td_left\">$relname</TD><TD CLASS=\"td_left\">$indexrelname</TD><TD CLASS=\"td_left\">$owner</TD><TD CLASS=\"td_right\">$idx_scan</TD><TD CLASS=\"td_right\">$idx_tup_read</TD>
                       <TD CLASS=\"td_right\">$idx_tup_fetch</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_all_indexes->finish() ;
      $dbh_stat_all_indexes->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"11\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"11\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
      }
   }

if ($pv{tab_detail} == 4) {
   print_stat_snap_filters() ;
   if ($pv{stat_src_type} eq "range" && $pv{stat_is_graph_out} eq "true") { set_common_pg_mon_cgi_prefix() ;
      print "<BR><TABLE BORDER=\"1\" STYLE=\"text-align: left; width: 1100pt; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_left\">Чтений индексов физических, блоков<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_indexes&data_field=idx_blks_read&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     idx_blks_read</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_indexes&data_field=idx_blks_read\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_indexes&data_field=idx_blks_read\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             <TR><TD CLASS=\"td_left\">Чтений индексов из кэша, блоков<BR><BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_indexes&data_field=idx_blks_hit&out_type=table\" TARGET=\"_blank\">[T]</A>&nbsp;
                     idx_blks_hit</TD><TD CLASS=\"td_left\">
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_indexes&data_field=idx_blks_hit\" TARGET=\"_blank\">
                        <IMG SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_snap_stat_field.cgi?$common_pg_mon_cgi_prefix&data_table=pg_statio_all_indexes&data_field=idx_blks_hit\" STYLE=\"width: 970pt; height: 120pt; \"></A></TD></TR>
             </TABLE><BR>" ;
         }
   if ($pv{stat_is_table_out} eq "true") {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_head\">snap_ts</TD><TD CLASS=\"td_head\">snap_id</TD><TD CLASS=\"td_head\">relid</TD><TD CLASS=\"td_head\">indexrelid</TD><TD CLASS=\"td_head\">schemaname</TD><TD CLASS=\"td_head\">relname</TD>
                 <TD CLASS=\"td_head\">indexrelname</TD><TD CLASS=\"td_head\">owner</TD><TD CLASS=\"td_head\">idx_blks_read</TD><TD CLASS=\"td_head\">idx_blks_hit</TD>
             </TR> " ;
      if ($pv{stat_obj} ne "undefined") { $ext_where_conditions .= " AND t.indexrelid = $pv{stat_obj}" ; }
      if ($pv{stat_obj_id} ne "") { $ext_where_conditions .= " AND t.indexrelid = $pv{stat_obj_id}" ; }
      if ($pv{stat_part_name} ne "") { $ext_where_conditions .= " AND t.indexrelname like '%$pv{stat_part_name}%" ; }
      if ($pv{stat_owner} ne "undefined") { $ext_where_conditions .= " AND u.rolname = '$pv{stat_owner}'" ; }
      if ($pv{stat_schema} ne "undefined") { $ext_where_conditions .= " AND t.schemaname = '$pv{stat_schema}'" ; }

      if ($pv{stat_src_type} eq "curr") { $request_statio_all_indexes = "select '-', 'текущее', t.relid, t.indexrelid, t.schemaname, t.relname, t.indexrelname, u.rolname, t.idx_blks_read, t.idx_blks_hit from pg_catalog.pg_statio_all_indexes t, pg_class c, pg_authid u where t.relid = c.oid and c.relowner = u.oid $ext_where_conditions" ; }
      if ($pv{stat_src_type} eq "snap") { $request_statio_all_indexes = "select '-', snap_id, t.relid, t.indexrelid, t.schemaname, t.relname, t.indexrelname, u.rolname, t.idx_blks_read, t.idx_blks_hit from bestat_io_all_indexes_deltas_view t, pg_class c, pg_authid u where t.relid = c.oid and c.relowner = u.oid and t.snap_id = $pv{stat_src_snap_id} $ext_where_conditions" ; }
      if ($pv{stat_src_type} eq "range") {
         if ($pv{stat_obj} ne "undefined" || $pv{stat_obj_id} ne "") { $request_statio_all_indexes = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, t.relid, t.indexrelid, t.schemaname, t.relname, t.indexrelname, u.rolname, t.idx_blks_read, t.idx_blks_hit from bestat_io_all_indexes_deltas_view t, pg_class c, pg_authid u, bestat_snapshots sn where t.relid = c.oid and c.relowner = u.oid and t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id} $ext_where_conditions order by t.snap_id asc" ; }
         else { $request_statio_all_indexes = "select to_char(sn.snap_ts, 'YYYY-MM-DD HH24:MI:SS'), t.snap_id, 'all', 'all', 'all', 'all', 'all', 'all', t.idx_blks_read, t.idx_blks_hit from bestat_io_all_indexes_sum_deltas_view t, bestat_snapshots sn where t.snap_id = sn.snap_id and t.snap_id >= $pv{stat_start_snap_id} and t.snap_id <= $pv{stat_stop_snap_id}" ; }
         }
#---debug---print "<BR>=== $request_stat_all_indexes ===<BR>" ;
#      $request_stat_archiver = "select relid, indexrelid, schemaname, relname, indexrelname, idx_blks_read, idx_blks_hit from pg_catalog.pg_statio_all_indexes" ;
      my $dbh_statio_all_indexes = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_statio_all_indexes = $dbh_statio_all_indexes->prepare($request_statio_all_indexes) ; $sth_statio_all_indexes->execute() ; $count_rows = 0 ;
      while (my ($snap_ts, $snap_id, $relid, $indexrelid, $schemaname, $relname, $indexrelname, $owner, $idx_blks_read, $idx_blks_hit) = $sth_statio_all_indexes->fetchrow_array() ) {
            print "<TR><TD CLASS=\"td_right\">$snap_ts</TD><TD CLASS=\"td_right\">$snap_id</TD><TD CLASS=\"td_right\">$relid</TD><TD CLASS=\"td_right\">$indexrelid</TD><TD CLASS=\"td_left\">$schemaname</TD>
                       <TD CLASS=\"td_left\">$relname</TD><TD CLASS=\"td_left\">$indexrelname</TD><TD CLASS=\"td_left\">$owner</TD><TD CLASS=\"td_right\">$idx_blks_read</TD><TD CLASS=\"td_right\">$idx_blks_hit</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_statio_all_indexes->finish() ;
      $dbh_statio_all_indexes->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"10\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"10\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
      }
   }

if ($pv{tab_detail} == 5) {
   if ($pv{child_tab_detail} == 1) {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"head\">funcid</TD>
                 <TD CLASS=\"head\">schemaname</TD>
                 <TD CLASS=\"head\">funcname</TD>
                 <TD CLASS=\"head\">calls</TD>
                 <TD CLASS=\"head\">total_time</TD>
                 <TD CLASS=\"head\">self_time</TD>
             </TR> " ;
      $request_stat_archiver = "select funcid, schemaname, funcname, calls, total_time, self_time from pg_catalog.pg_stat_user_functions" ;
      my $dbh_stat_archiver = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_archiver = $dbh_stat_archiver->prepare($request_stat_archiver) ; $sth_stat_archiver->execute() ; $count_rows = 0 ;
      while (my ($funcid, $schemaname, $funcname, $calls, $total_time, $self_time) = $sth_stat_archiver->fetchrow_array() ) {
            print "<TR><TD CLASS=\"td_right\">$funcid</TD>
                       <TD CLASS=\"td_left\">$schemaname</TD>
                       <TD CLASS=\"td_left\">$funcname</TD>
                       <TD CLASS=\"td_right\">$calls</TD>
                       <TD CLASS=\"td_right\">$total_time</TD>
                       <TD CLASS=\"td_right\">$self_time</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_archiver->finish() ;
      $dbh_stat_archiver->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"6\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"6\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
      }
   }

if ($pv{tab_detail} == 6) {
   if ($pv{child_tab_detail} == 1) {
      print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">" ;
      print "<TR><TD CLASS=\"td_right\">relid</TD>
                 <TD CLASS=\"td_left\">schemaname</TD>
                 <TD CLASS=\"td_left\">relname</TD>
                 <TD CLASS=\"td_right\">seq_scan</TD>
                 <TD CLASS=\"td_right\">seq_tup_read</TD>
                 <TD CLASS=\"td_right\">idx_scan</TD>
                 <TD CLASS=\"td_right\">idx_tup_fetch</TD>
                 <TD CLASS=\"td_right\">n_tup_ins</TD>
                 <TD CLASS=\"td_right\">n_tup_upd</TD>
                 <TD CLASS=\"td_right\">n_tup_del</TD>
                 <TD CLASS=\"td_right\">n_tup_hot_upd</TD>
             </TR> " ;
      $request_stat_archiver = "select relid, schemaname, relname, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd from pg_catalog.pg_stat_xact_all_tables" ;
      my $dbh_stat_archiver = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
      my $sth_stat_archiver = $dbh_stat_archiver->prepare($request_stat_archiver) ; $sth_stat_archiver->execute() ; $count_rows = 0 ;
      while (my ($relid, $schemaname, $relname, $seq_scan, $seq_tup_read, $idx_scan, $idx_tup_fetch, $n_tup_ins, $n_tup_upd, $n_tup_del, $n_tup_hot_upd) = $sth_stat_archiver->fetchrow_array() ) {
            print "<TR><TD CLASS=\"td_right\">$relid</TD>
                       <TD CLASS=\"td_left\">$schemaname</TD>
                       <TD CLASS=\"td_left\">$relname</TD>
                       <TD CLASS=\"td_right\">$seq_scan</TD>
                       <TD CLASS=\"td_right\">$seq_tup_read</TD>
                       <TD CLASS=\"td_right\">$idx_scan</TD>
                       <TD CLASS=\"td_right\">$idx_tup_fetch</TD>
                       <TD CLASS=\"td_right\">$n_tup_ins</TD>
                       <TD CLASS=\"td_right\">$n_tup_upd</TD>
                       <TD CLASS=\"td_right\">$n_tup_del</TD>
                       <TD CLASS=\"td_right\">$n_tup_hot_upd</TD>
                   </TR> " ;
            $count_rows++ ;
            }
      $sth_stat_archiver->finish() ;
      $dbh_stat_archiver->disconnect() ;
      if ($count_rows == 0) { print "<TR><TD COLSPAN=\"11\">&nbsp;...&nbsp;записей не обнаружено</TD></TR>" ; } else { print "<TR><TD COLSPAN=\"11\">&nbsp;Итого&nbsp;:&nbsp;$count_rows</TD></TR>" ; }
      print "</TABLE>" ;
      }
   }

#print "<!-- конец таблицы третьего уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
