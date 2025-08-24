# open source soft - (C) 2025 CAMActSoSt BESST - in last part of (C) 2023 camactsost BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

# этот блок нужен для сохранения данных в полях конкретных объектов модулей TOP Activity при вызове JS функций
sub print_hidden_variable_top_activity() {
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
    }

# этот блок нужен для сохранения данных в полях конкретных объектов модулей Snapshots history при вызове JS функций
sub print_hidden_variable_snapshots_history() {
    print "<SPAN STYLE=\"visibility: collapse;\">" ;
    print "<INPUT TYPE=\"hidden\" NAME=\"stat_src_type\" ID=\"id_stat_src_type\" VALUE=\"$pv{stat_src_type}\">
           <INPUT TYPE=\"hidden\" NAME=\"stat_src_snap_id\" ID=\"id_stat_src_snap_id\" VALUE=\"$pv{stat_src_snap_id}\">
           <INPUT TYPE=\"hidden\" NAME=\"stat_start_snap_id\" ID=\"id_stat_start_snap_id\" VALUE=\"$pv{stat_start_snap_id}\">
           <INPUT TYPE=\"hidden\" NAME=\"stat_is_graph_out\" ID=\"id_stat_is_graph_out\" VALUE=\"$pv{stat_is_graph_out}\">
           <INPUT TYPE=\"hidden\" NAME=\"stat_stop_snap_id\" ID=\"id_stat_stop_snap_id\" VALUE=\"$pv{stat_stop_snap_id}\">
           <INPUT TYPE=\"hidden\" NAME=\"stat_is_table_out\" ID=\"id_stat_is_table_out\" VALUE=\"$pv{stat_is_table_out}\">
           <INPUT TYPE=\"hidden\" NAME=\"stat_obj\" ID=\"id_stat_obj\" VALUE=\"$pv{stat_obj}\">
           <INPUT TYPE=\"hidden\" NAME=\"stat_obj_id\" ID=\"id_stat_obj_id\" VALUE=\"$pv{stat_obj_id}\">
           <INPUT TYPE=\"hidden\" NAME=\"stat_part_name\" ID=\"id_stat_part_name\" VALUE=\"$pv{stat_part_name}\">
           <INPUT TYPE=\"hidden\" NAME=\"stat_owner\" ID=\"id_stat_owner\" VALUE=\"$pv{stat_owner}\">
           <INPUT TYPE=\"hidden\" NAME=\"stat_schema\" ID=\"id_stat_schema\" VALUE=\"$pv{stat_schema}\">" ;
    print "</SPAN>" ;
    }

sub set_common_pg_mon_cgi_prefix() { $common_pg_mon_cgi_prefix = "period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&dbid=$pv{dbid}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&ds_type=$pv{ds_type}&curr_conn=$pv{curr_conn}&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}&stat_src_type=$pv{stat_src_type}&stat_src_snap_id=$pv{stat_src_snap_id}&stat_start_snap_id=$pv{stat_start_snap_id}&stat_is_graph_out=$pv{stat_is_graph_out}&stat_stop_snap_id=$pv{stat_stop_snap_id}&stat_is_table_out=$pv{stat_is_table_out}&stat_obj=$pv{stat_obj}&stat_owner=$pv{stat_owner}&stat_schema=$pv{stat_schema}&stat_obj_id=$pv{stat_obj_id}&stat_part_name=$pv{stat_part_name}" ; }

sub print_stat_snap_filters() {
    $is_src_curr = "" ; $is_src_snap = "" ; $is_src_block = "" ; if ($pv{stat_src_type} eq "") { $pv{stat_src_type} = "curr" ; }
    if ($pv{stat_src_type} eq "curr") { $is_src_curr = " CHECKED" ; } if ($pv{stat_src_type} eq "snap") { $is_src_snap = " CHECKED" ; }   if ($pv{stat_src_type} eq "range") { $is_src_block = " CHECKED" ; }
    print "\n<BR>&nbsp;Условия выборки:<BR>\n<TABLE STYLE=\"width: 700pt; border: 1pt; border-style: none;\" BORDER=\"1\">\n
 <TR><TD STYLE=\"width: 50pt%; text-align: left;\"><INPUT TYPE=\"radio\" NAME=\"stat_src_type\" ID=\"id_stat_src_type\" VALUE=\"curr\" $is_src_curr>&nbsp;текущее&nbsp;значение</TD>
     <TD STYLE=\"width: 240pt; text-align: left;\"><INPUT TYPE=\"radio\" NAME=\"stat_src_type\" ID=\"id_stat_src_type\" VALUE=\"snap\" $is_src_snap>&nbsp;значение&nbsp;среза</TD>
     <TD STYLE=\"width: 300pt; text-align: left;\"><INPUT TYPE=\"radio\" NAME=\"stat_src_type\" ID=\"id_stat_src_type\" VALUE=\"range\" $is_src_block>&nbsp;диапазон&nbsp;срезов</TD>
 </TR>\n<TR><TD>&nbsp;</TD>
      <TD>&nbsp;snap_id:&nbsp;<SELECT STYLE=\"text-align: left; width: 179pt;\" NAME=\"stat_src_snap_id\" ID=\"id_stat_src_snap_id\">&nbsp;значение&nbsp;среза
          <OPTION VALUE=\"undefined\">... не определено</OPTION>" ;
    $request_src_snap_id_list = "select snap_id, TO_CHAR(snap_ts,'YYYY-MM-DD HH24:MI:SS') from bestat_snapshots order by snap_id desc" ;
    my $dbh_src_snap_id_list = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_src_snap_id_list = $dbh_src_snap_id_list->prepare($request_src_snap_id_list) ; $sth_src_snap_id_list->execute() ;
    while (my ($snap_id, $snap_ts) = $sth_src_snap_id_list->fetchrow_array() ) { $is_selected = "" ; if ($pv{stat_src_snap_id} eq "$snap_id") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$snap_id\" $is_selected>$snap_ts [$snap_id]</OPTION>\n" ; }
    $sth_src_snap_id_list->finish() ; $dbh_src_snap_id_list->disconnect() ;
    print "</SELECT></TD>
      <TD>
      <TABLE><TR><TD>&nbsp;от:&nbsp;</TD><TD><SELECT STYLE=\"text-align: left; width: 179pt;\" NAME=\"stat_start_snap_id\" ID=\"id_stat_start_snap_id\">&nbsp;значение&nbsp;среза
             <OPTION VALUE=\"undefined\">... не определено</OPTION>" ;
    $request_src_snap_id_list = "select snap_id, TO_CHAR(snap_ts,'YYYY-MM-DD HH24:MI:SS') from bestat_snapshots order by snap_id desc" ;
    my $dbh_src_snap_id_list = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_src_snap_id_list = $dbh_src_snap_id_list->prepare($request_src_snap_id_list) ; $sth_src_snap_id_list->execute() ;
    while (my ($snap_id, $snap_ts) = $sth_src_snap_id_list->fetchrow_array() ) { $is_selected = "" ; if ($pv{stat_start_snap_id} eq "$snap_id") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$snap_id\" $is_selected>$snap_ts [$snap_id]</OPTION>\n" ; }
    $sth_src_snap_id_list->finish() ; $dbh_src_snap_id_list->disconnect() ;
    $checked_stat_is_graph_out = "" ; if ($pv{stat_is_graph_out} eq "") { $pv{stat_is_graph_out} = "true" ; } if ($pv{stat_is_graph_out} eq "true") { $checked_stat_is_graph_out = "CHECKED" ; }
    print "</SELECT>&nbsp;&nbsp;&nbsp;<INPUT TYPE=\"checkbox\" NAME=\"stat_is_graph_out\" ID=\"id_stat_is_graph_out\" $checked_stat_is_graph_out>&nbsp;графики</TD></TR>\n
 <TR><TD>&nbsp;до:&nbsp;</TD><TD><SELECT STYLE=\"text-align: left; width: 179pt;\" NAME=\"stat_stop_snap_id\" ID=\"id_stat_stop_snap_id\">&nbsp;значение&nbsp;среза
             <OPTION VALUE=\"undefined\">... не определено</OPTION>" ;
    $request_src_snap_id_list = "select snap_id, TO_CHAR(snap_ts,'YYYY-MM-DD HH24:MI:SS') from bestat_snapshots order by snap_id desc" ;
    my $dbh_src_snap_id_list = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_src_snap_id_list = $dbh_src_snap_id_list->prepare($request_src_snap_id_list) ; $sth_src_snap_id_list->execute() ;
    while (my ($snap_id, $snap_ts) = $sth_src_snap_id_list->fetchrow_array() ) { $is_selected = "" ; if ($pv{stat_stop_snap_id} eq "$snap_id") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$snap_id\" $is_selected>$snap_ts [$snap_id]</OPTION>\n" ; }
    $sth_src_snap_id_list->finish() ; $dbh_src_snap_id_list->disconnect() ;
    $checked_stat_is_table_out = "" ; if ($pv{stat_is_table_out} eq "") { $pv{stat_is_table_out}  = "false" ; } if ($pv{stat_is_table_out} eq "true") { $checked_stat_is_table_out = "CHECKED" ; }
    print "</SELECT>&nbsp;&nbsp;&nbsp;<INPUT TYPE=\"checkbox\" NAME=\"stat_is_table_out\" ID=\"id_stat_is_table_out\" $checked_stat_is_table_out>&nbsp;таблицы</TD></TR></TABLE></TD>
       </TR>\n<TR><TD COLSPAN=\"3\">
 <TABLE STYLE=\"width: 100%;\">\n
 <TR><TD>&nbsp;объект:</TD><TD>&nbsp;&nbsp;&nbsp;</TD>\n
 <TD><SELECT STYLE=\"text-align: left; width: 507pt;\" NAME=\"stat_obj\" ID=\"id_stat_obj\"
             TITLE=\"поле применимо для текущих значений, снапшота и диапазона\">
             <OPTION VALUE=\"undefined\">... не определено, для диапазона - суммирование статистик обьектов, если применимо</OPTION>\n" ;
    $request_src_obj_list = "select c.oid, c.relname,
                                    CASE WHEN c.relkind = 'r' THEN 'ordinary table' WHEN c.relkind = 'i' THEN 'index' WHEN c.relkind = 'S' THEN 'sequence' WHEN c.relkind = 't' THEN 'TOAST table' WHEN c.relkind = 'v' THEN 'view'
                                         WHEN c.relkind = 'm' THEN 'materialized view' WHEN c.relkind = 'c' THEN 'composite type' WHEN c.relkind = 'f' THEN 'foreign table' WHEN c.relkind = 'p' THEN 'partitioned tablepartitioned index'
                                         WHEN c.relkind = 'I' THEN 'partitioned index' END, u.rolname from pg_class c, pg_authid u where c.relowner = u.oid
                                    UNION ALL select datid, datname, 'database', '-' from pg_catalog.pg_stat_database order by 3 asc, 2 asc" ;
    my $dbh_src_obj_list = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_src_obj_list = $dbh_src_obj_list->prepare($request_src_obj_list) ; $sth_src_obj_list->execute() ;
    while (my ($oid, $relname, $reltype, $relowner) = $sth_src_obj_list->fetchrow_array() ) { $is_selected = "" ; if ($pv{stat_obj} eq "$oid") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$oid\" $is_selected>$reltype '$relname' [$oid], owner $relowner</OPTION>\n " ; }
    $sth_src_obj_list->finish() ; $dbh_src_obj_list->disconnect() ;
    print " </SELECT></TD>
           <TD ROWSPAN=\"5\" STYLE=\"text-align: center; vertical-align: middle; width: 70pt;\"><SPAN STYLE=\"font-size: 10pt; color: navy; cursor: pointer; pointer: arrow;\"
               onclick=\"renew_db_status_page_stat(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,id_sess_state_filter.value,id_db_filter.value,id_is_user_backends.checked,id_is_backgrounds.checked,id_is_extensions.checked,'$pv{tab_detail}',id_curr_conn.value,id_refresh_time.value,'$pv{sort_field}','',id_stat_src_snap_id.value,id_stat_start_snap_id.value,id_stat_is_graph_out.checked,id_stat_stop_snap_id.value,id_stat_is_table_out.checked,id_stat_obj.value,id_stat_owner.value,id_stat_schema.value,id_stat_obj_id.value,id_stat_part_name.value)\">
               Применить<BR>условия<BR>выборки</SPAN></TD>
           </TR>\n
 <TR><TD>&nbsp;ID объекта:</TD><TD>&nbsp;&nbsp;&nbsp;</TD><TD><INPUT STYLE=\"text-align: left; width: 500pt;\" TYPE=\"input\" NAME=\"stat_obj_id\" ID=\"id_stat_obj_id\" VALUE=\"$pv{stat_obj_id}\"
     TITLE=\"поле применимо для текущих значений, снапшота и диапазона\"></TD></TR>\n
 <TR><TD>&nbsp;имя содержит:</TD><TD>&nbsp;&nbsp;&nbsp;</TD><TD><INPUT STYLE=\"text-align: left; width: 500pt;\" TYPE=\"input\" NAME=\"stat_part_name\" ID=\"id_stat_part_name\" 
     TITLE=\"поле используется для текущего значения и среза, неприменимо - обработка явно отключена - для диапазона, т.к. возможна неоднозначная выборка нескольких обьектов\" VALUE=\"$pv{stat_part_name}\"></TD></TR>\n
 <TR><TD>&nbsp;владелец:</TD><TD>&nbsp;&nbsp;&nbsp;</TD>
     <TD><SELECT STYLE=\"text-align: left; width: 507pt;\" NAME=\"stat_owner\" ID=\"id_stat_owner\"
                 TITLE=\"поле применимо для текущих значений, снапшота, в настоящее время неприменимо - обработка явно отключена - для диапазона\">
                 <OPTION VALUE=\"undefined\">... не определено</OPTION>\n" ;
    $request_src_owners = "select oid, rolname from pg_authid order by rolname" ;
    my $dbh_src_owners = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_src_owners = $dbh_src_owners->prepare($request_src_owners) ; $sth_src_owners->execute() ; $count_rows = 0 ;
    while (my ($oid, $rolname) = $sth_src_owners->fetchrow_array() ) { $is_selected = "" ; if ($pv{stat_owner} eq "$rolname") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$rolname\" $is_selected>$rolname [$oid]</OPTION>\n" ; }
    $sth_src_owners->finish() ; $dbh_src_owners->disconnect() ;
    print "</SELECT></TR>\n
 <TR><TD>&nbsp;схема:</TD><TD>&nbsp;&nbsp;&nbsp;</TD>
     <TD><SELECT STYLE=\"text-align: left; width: 507pt;\"  NAME=\"stat_schema\" ID=\"id_stat_schema\"
                 TITLE=\"поле применимо для текущих значений, снапшота, в настоящее время неприменимо - обработка явно отключена - для диапазона\">
                 <OPTION VALUE=\"undefined\">... не определено</OPTION>\n" ;
    $request_src_namespaces = "select oid, nspname, nspowner from pg_catalog.pg_namespace" ;
    my $dbh_src_namespaces = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_src_namespaces = $dbh_src_namespaces->prepare($request_src_namespaces) ; $sth_src_namespaces->execute() ; $count_rows = 0 ;
    while (my ($oid, $nspname, $nspowner) = $sth_src_namespaces->fetchrow_array() ) { $is_selected = "" ; if ($pv{stat_schema} eq "$nspname") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$nspname\" $is_selected>$nspname [$oid]</OPTION>\n" ; }
    $sth_src_namespaces->finish() ; $dbh_src_namespaces->disconnect() ;
    print "</SELECT></TR>\n
       </TABLE></TD></TR>\n" ;
    print "</TABLE><BR>&nbsp;Результат выборки:\n" ;
    }

sub print_tools_pg_main_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $sz_current_date_short = `date "+%Y-%m-%d 00:00:00"` ; $sz_current_date = `date "+%Y-%m-%d 23:59:59"` ; $pv{period_from} = ( $pv{period_from} eq "" ) ? $sz_current_date_short : $pv{period_from} ; $pv{period_to} = ( $pv{period_to} eq "" ) ? $sz_current_date : $pv{period_to} ;
# при смене компоненты - принудительно включить виды отображения is_user_backends, is_backgrounds, is_extensions
    if ($num_active_tab != 3) { $pv{is_user_backends} = "true" ; $pv{is_backgrounds} = "true" ; $pv{is_extensions} = "true" ; }
    $common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_config.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\">Конфигурация<BR>Роли, привелегии</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\">Объекты<BR>БД</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
               TITLE=\"Запуск с установленным периодом и сброшенными остальными фильтрами\">Монитор<BR>активности</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\">Статистики<BR>подсистем</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_objects_io.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\">Статистики<BR>Объекты, I/O</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_progress.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\">Progress<BR>операций</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{7}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\">Аналитика<BR>Профили</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
# при смене компоненты - принудительно включить виды отображения is_user_backends, is_backgrounds, is_extensions
    if ($num_active_tab != 2) { $pv{is_user_backends} = "true" ; $pv{is_backgrounds} = "true" ; $pv{is_extensions} = "true" ; }
    $common_pg_mon_cgi_prefix = "" ;    set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_list.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"Распределение активности по кластерам и БД в них\">TOP&nbsp;Activity<BR>лента&nbsp;кластеров</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"Распределение из stats activity [1 секунда] - долгоживущие запросы\">TOP&nbsp;Activity<BR>[Stats Activity]</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"Распределение из wait sampling [10 миллисекунд] - короткоживущие запросы\">TOP&nbsp;Activity<BR>[Wait sampling]</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_current_locks.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"блокировки - текущее состояние и аналитика на основе срезов pg_stats_activity и pg_locks\">Блокировки<BR>текущие</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_current_sessions.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"текущие сессии из pg_stats_activity\">Сессии<BR>текущие</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_config_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; $active_tab{6} = "" ;  $active_tab{7} = "" ; $active_tab{8} = "" ; 
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ;    set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_config.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\" TITLE=\"\">Конфигурация<BR>короткая</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_config.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\" TITLE=\"\">Конфигурация<BR>полная</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_config.cgi?$common_pg_mon_cgi_prefix&tab_detail=3\"
                  TITLE=\"Базы кластера\">Базы</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_config.cgi?$common_pg_mon_cgi_prefix&tab_detail=4\"
                  TITLE=\"\">Пользователи<BR>Роли</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_config.cgi?$common_pg_mon_cgi_prefix&tab_detail=5\" TITLE=\"\">Члены<BR>ролей</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_config.cgi?$common_pg_mon_cgi_prefix&tab_detail=6\"
                  TITLE=\"\">Привелегии<BR>табличные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{7}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_config.cgi?$common_pg_mon_cgi_prefix&tab_detail=7\">Привелегии<BR>колоночные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{8}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_config.cgi?$common_pg_mon_cgi_prefix&tab_detail=8\">Привелегии<BR>процедурные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{9}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_config.cgi?$common_pg_mon_cgi_prefix&tab_detail=9\" TITLE=\"\">Пространства<BR>имён. Схемы</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_object_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; $active_tab{6} = "" ;  $active_tab{7} = "" ; $active_tab{8} = "" ; 
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ;    set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"Распределение из stats activity [1 секунда] - долгоживущие запросы\">Объекты</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\"
                  TITLE=\"Распределение из wait sampling [10 миллисекунд] - короткоживущие запросы\">Таблицы</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=3\">Индексы</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=4\">Представления</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=5\" TITLE=\"---\">Процедуры и функции</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=6\" TITLE=\"---\">Триггера</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{7}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_objects.cgi?$common_pg_mon_cgi_prefix&tab_detail=7\" TITLE=\"---\">Sequenses</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_top_activity_SA_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ;    set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"\">Запросы&nbsp;SA<BR>&nbsp;Сессии&nbsp;SA</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\"
                  TITLE=\"\">Запросы&nbsp;SA<BR>полные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?$common_pg_mon_cgi_prefix&tab_detail=3\"
                  TITLE=\"\">Сессии&nbsp;SA<BR>полные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?$common_pg_mon_cgi_prefix&tab_detail=4\"
                  TITLE=\"\">Запросы&nbsp;SA<BR>Запросы&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?$common_pg_mon_cgi_prefix&tab_detail=5\"
                  TITLE=\"\">Сессии&nbsp;SA<BR>Сессии&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?$common_pg_mon_cgi_prefix&tab_detail=6\"
                  TITLE=\"\">События&nbsp;ожидания<BR>SA&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_top_activity_WS_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ;    set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"\">Запросы&nbsp;WS<BR>&nbsp;Сессии&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\"
                  TITLE=\"\">Запросы&nbsp;WS<BR>полные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?$common_pg_mon_cgi_prefix&tab_detail=3\"
                  TITLE=\"\">Сессии&nbsp;WS<BR>полные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?$common_pg_mon_cgi_prefix&tab_detail=4\"
                  TITLE=\"\">Запросы&nbsp;SA<BR>Запросы&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?$common_pg_mon_cgi_prefixtab_detail=5\"
                  TITLE=\"\">Сессии&nbsp;SA<BR>Сессии&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?$common_pg_mon_cgi_prefixtab_detail=6\"
                  TITLE=\"\">События&nbsp;ожидания<BR>SA&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_query_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ;    set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"\">ЗАПРОС<BR>по&nbsp;сессиям&nbsp;SA</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\"
                  TITLE=\"т.к. иногда текст запроса в pg_stat_activity есть, а query_id нет - если нельзя достать текст по пустому query_id из pg_stat_statements, то делается попытка достать его из pg_stat_activity, т.к. в bestat_sa_history текст запроса не сохраняется для облегчения агрегатора\">Текст<BR>запроса</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix&tab_detail=3\"
                  TITLE=\"в настоящее время реализовано по текущим данным pg_stat_statements без сохранения и учёта периодов\">Статистики<BR>запроса</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix&tab_detail=4\"
                  TITLE=\"в настоящее время реализовано по текущим данным pg_stat_statements без сохранения и учёта периодов\">Планы<BR>выполнения</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix&tab_detail=5\"
                  TITLE=\"\">События<BR>ожидания&nbsp;SA/WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix&tab_detail=6\"
                  TITLE=\"\">График<BR>pg_wait_sampling</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_session_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ;    set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_session.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"\">СЕССИЯ<BR>по&nbsp;запросам&nbsp;SA</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_session.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\"
                  TITLE=\"\">События<BR>ожидания&nbsp;SA/WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_locks_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ;    set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_locks.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"\">Сырой&nbsp;pg_locks</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_locks.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\"
                  TITLE=\"\">C&nbsp;ожиданиями</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_TA_list_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ;    set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_list.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"\">Графики&nbsp;активности</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_list.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\"
                  TITLE=\"\">Таблицы&nbsp;кластеров</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_stat_subsys_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; $active_tab{6} = "" ; $active_tab{7} = "" ; $active_tab{8} = "" ; $active_tab{9} = "" ; $active_tab{10} = "" ; ; $active_tab{11} = "" ; $active_tab{12} = "" ; $active_tab{13} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"\">Databases</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\"
                  TITLE=\"\">SHMEM<BR>allocation</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=3\"
                  TITLE=\"\">SLRU</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=4\"
                  TITLE=\"\">Archiver</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=5\"
                  TITLE=\"\">BG<BR>Writer</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=6\"
                  TITLE=\"\">WAL</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{7}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=7\"
                  TITLE=\"\">WAL<BR>receiver</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{8}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=8\"
                  TITLE=\"\">Replication</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{9}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=9\"
                  TITLE=\"\">Replication<BR>slots</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{10}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=10\"
                  TITLE=\"\">Subscription</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{11}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=11\"
                  TITLE=\"\">Subscription<BR>stat</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_stat_obj_io_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; $active_tab{6} = "" ; $active_tab{7} = "" ; $active_tab{8} = "" ; $active_tab{9} = "" ; $active_tab{10} = "" ; ; $active_tab{11} = "" ; $active_tab{12} = "" ; $active_tab{13} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ;    set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_objects_io.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"\">OBJ<BR>Tables</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_objects_io.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\"
                  TITLE=\"\">OBJ I/O<BR>Tables</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>


           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_objects_io.cgi?$common_pg_mon_cgi_prefix&tab_detail=3\"
                  TITLE=\"\">OBJ<BR>Indexes</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_objects_io.cgi?$common_pg_mon_cgi_prefix&tab_detail=4\"
                  TITLE=\"\">OBJ I/O<BR>Indexes</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_objects_io.cgi?$common_pg_mon_cgi_prefix&tab_detail=5\"
                  TITLE=\"\">OBJ&nbsp;User<BR>Functions</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_objects_io.cgi?$common_pg_mon_cgi_prefix&tab_detail=6\"
                  TITLE=\"\">XACT<BR>Tables</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_stat_progress_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; $active_tab{6} = "" ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_progress.cgi?$common_pg_mon_cgi_prefix&tab_detail=1\"
                  TITLE=\"\">Base backup</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_progress.cgi?$common_pg_mon_cgi_prefix&tab_detail=2\"
                  TITLE=\"\">VACUUM</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_progress.cgi?$common_pg_mon_cgi_prefix&tab_detail=3\"
                  TITLE=\"\">ANALYZE</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_progress.cgi?$common_pg_mon_cgi_prefix&tab_detail=4\"
                  TITLE=\"\">Cluster</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_progress.cgi?$common_pg_mon_cgi_prefix&tab_detail=5\"
                  TITLE=\"\">Indexes</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_progress.cgi?$common_pg_mon_cgi_prefix&tab_detail=6\"
                  TITLE=\"\">COPY</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_stat_tab_child_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    $common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=$pv{tab_detail}&child_tab_detail=1\"
                  TITLE=\"\">Текущее&nbsp;состояние</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=$pv{tab_detail}&child_tab_detail=2\"
                  TITLE=\"\">Динамика&nbsp;в&nbsp;графической форме</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_stat_subsys.cgi?$common_pg_mon_cgi_prefix&tab_detail=$pv{tab_detail}&child_tab_detail=3\"
                  TITLE=\"\">Динамика&nbsp;в&nbsp;табличной форме</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

# функция отрисовывает заголовок с учетом коннектора и времени автообновления
sub print_pg_monitor_main_page_title($$) { $title_part_01 = $_[0] ; $title_part_02 = $_[1] ;
#-debug-print "$common_pg_mon_cgi_prefix" ;
#printf("=== $0 $script_name ===") ;
#   if ($script_name eq "tools_pg_monitor_stat_objects_io.cgi" ) {
#      $ext_cgi_params = "id_stat_src_type.value,id_stat_src_snap_id.value,id_stat_start_snap_id.value,id_stat_stop_snap_id.value,id_stat_obj.value,id_stat_schema.value,id_stat_obj_id.value" ;
#      }

    my $curr_timepoint = `date "+%Y-%m-%d %H:%M:%S"` ; $file_name = $0 ; $file_name =~ s/.*\/([^\/]+)/$1/g ;
    print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border-width: solid; border-color: navy;\">
           <TR><TD>
               <TABLE BORDER=\"0\" STYLE=\"width: 100%; border-width: solid; border-color: navy;\">
               <TR><TD>" ;
    print "        <TABLE BORDER=\"0\" STYLE=\"width: 270pt%; border-width: solid; border-color: navy;\">" ;
    print "        <TR><TD STYLE=\"color: navy;\">коннектор:&nbsp;</TD><TD>
                           <SELECT ID=\"id_curr_conn\" NAME=\"curr_conn\" STYLE=\"width: 170pt; color: navy;\" TITLE=\"выставляется параметром ссылки, чтобы смотреть данные разных коннекторов\">
                                   <OPTION VALUE=\"none\">не установлен</OPTION>" ;
    @dbconn_nosort_keys = keys %conn_def ; @dbconn_sort_keys = sort @dbconn_nosort_keys ;
    foreach $i (@dbconn_sort_keys) { $is_selected = "" ; if ( $pv{curr_conn} eq "$i" ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$i\" $is_selected>$i - $conn_desc{$i}</OPTION>" ; }
    print "                </SELECT>
                           </TD>
                           <TD ROWSPAN=\"2\" STYLE=\"vertical-align: middle; cursor: pointer;\" TITLE=\"обновить только основные параметры\""; 
   @fullname = split('/', $0) ; $script_name = @fullname[-1] ;
   if ($script_name eq "tools_pg_monitor_stat_objects_io.cgi" ) { print "\n onclick=\"renew_db_status_page_stat(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,id_sess_state_filter.value,id_db_filter.value,id_is_user_backends.checked,id_is_backgrounds.checked,id_is_extensions.checked,'$pv{tab_detail}',id_curr_conn.value,id_refresh_time.value,'$pv{sort_field}','',id_stat_src_snap_id.value,id_stat_start_snap_id.value,id_stat_is_graph_out.checked,id_stat_stop_snap_id.value,id_stat_is_table_out.checked,id_stat_obj.value,id_stat_owner.value,id_stat_schema.value,id_stat_obj_id.value,id_stat_part_name.value)\"> \n" ; } 
   else { print "\n onclick=\"renew_db_status_page(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,id_sess_state_filter.value,id_db_filter.value,id_is_user_backends.checked,id_is_backgrounds.checked,id_is_extensions.checked,'$pv{tab_detail}',id_curr_conn.value,id_refresh_time.value,'$pv{sort_field}','&x=x')\"> \n" ; }
   print "                           &nbsp;<IMG STYLE=\"width: 24pt; height: 24pt; vertical-align: middle;\" SRC=\"img/renew_navy.png\">
                           </TD>
                   </TR><TR><TD STYLE=\"color: navy;\">autorefresh:&nbsp;</TD><TD>
                            <SELECT ID=\"id_refresh_time\" NAME=\"refresh_time\" STYLE=\"width: 170pt; color: navy; text-align: right;\" TITLE=\"выставляется параметром ссылки\">
                                    <OPTION VALUE=\"none\">нет</OPTION>" ;
    $is_selected = "" ; if ($pv{refresh_time} eq "10" ) {  $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"10\"  $is_selected>10 секунд</OPTION>" ;
    $is_selected = "" ; if ($pv{refresh_time} eq "30" ) {  $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"30\"  $is_selected>30 секунд</OPTION>" ;
    $is_selected = "" ; if ($pv{refresh_time} eq "60" ) {  $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"60\"  $is_selected>1 минута</OPTION>" ;
    $is_selected = "" ; if ($pv{refresh_time} eq "300" ) {  $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"300\"  $is_selected>5 минут</OPTION>" ;
    $is_selected = "" ; if ($pv{refresh_time} eq "600" ) {  $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"600\"  $is_selected>10 минут</OPTION>" ;
    $is_selected = "" ; if ($pv{refresh_time} eq "300w" ) {  $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"300w\"  $is_selected>5 минут (окно)</OPTION>" ;
    $is_selected = "" ; if ($pv{refresh_time} eq "600w" ) {  $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"600w\"  $is_selected>10 минут (окно)</OPTION>" ;
    print "                 </SELECT></TD></TR>" ;
    print "        </TABLE>
                   </TD>
                   <TD>&nbsp;</TD>
                   <TD>
                   <P STYLE=\"text-align: right;\"><SPAN STYLE=\"text-align: right; font-family: sans-serif; color: navy; font-size: 17pt; font-weight: bold;\">$title_part_01</SPAN> 
                                                   <SPAN STYLE=\"text-align: right; font-family: sans-serif; color: green; font-size: 17pt; font-weight: bold;\"
                                                         TITLE=\"$title_part_02 [$conn_def{$pv{curr_conn}} - $conn_desc{$pv{curr_conn}}]\">[$title_part_02]</SPAN>&nbsp;
                   <BR><SPAN STYLE=\"text-align: right; font-family: sans-serif; color: navy; font-size: 10pt; font-weight: normal;\">$curr_timepoint</SPAN>&nbsp;</P>
                   </TD></TR>
               </TABLE>
           </TD></TR></TABLE><BR>" ;
    }

sub print_js_block_pg_monitor() {
    print "<SCRIPT LANGUAGE=\"JavaScript\">
function renew_db_status_page(v_period_from,v_period_to,v_query_id,v_plan_hash,v_pid,v_serial,v_sesttfltr,v_db_filter,v_isusrback,v_isbgr,v_isext,v_tab_detail,v_curr_conn,v_refresh_time,v_sort_field,v_ext_cgi_params) {
         var v_ds_type_value ;
         var v_url ;
//alert('OK') ;
         var id_radio_type = document.getElementsByName('ds_type') ;
         for (i=0; i < id_radio_type.length; i++) { if (id_radio_type[i].checked) { v_ds_type_value = id_radio_type[i].value ; } }
//         alert(v_ds_type_value) ;
         v_url = \"$COMM_PAR_DOMAIN_HREF\"+window.location.pathname+\"?period_from=\"+v_period_from+\"&period_to=\"+v_period_to+\"&query_id=\"+v_query_id+\"&plan_hash=\"+v_plan_hash+\"&pid=\"+v_pid+\"&serial=\"+v_serial+\"&ds_type=\"+v_ds_type_value+\"&sess_state_filter=\"+v_sesttfltr+\"&dbid=\"+v_db_filter+\"&is_user_backends=\"+v_isusrback+\"&is_backgrounds=\"+v_isbgr+\"&is_extensions=\"+v_isext+\"&tab_detail=\"+v_tab_detail+\"&curr_conn=\"+v_curr_conn+\"&refresh_time=\"+v_refresh_time+\"&sort_field=\"+v_sort_field+\"\"+v_ext_cgi_params ;
//alert(v_url) ;
         window.location.href = v_url ;
         }

function renew_db_status_page_stat(v_period_from,v_period_to,v_query_id,v_plan_hash,v_pid,v_serial,v_sesttfltr,v_db_filter,v_isusrback,v_isbgr,v_isext,v_tab_detail,v_curr_conn,v_refresh_time,v_sort_field,v_stat_src_type,v_stat_src_snap_id,v_stat_start_snap_id,v_stat_is_graph_out,v_stat_stop_snap_id,v_stat_is_table_out,v_stat_obj,v_stat_owner,v_stat_schema,v_stat_obj_id,v_stat_part_name) {
//alert('OK !!!') ;
         var v_ds_type_value ;
         var v_stat_src_type_value ;
         var v_url ;
         var id_radio_type = document.getElementsByName('ds_type') ;
         for (i=0; i < id_radio_type.length; i++) { if (id_radio_type[i].checked) { v_ds_type_value = id_radio_type[i].value ; } }
         var id_stat_src_type = document.getElementsByName('stat_src_type') ;
         for (i=0; i < id_stat_src_type.length; i++) { if (id_stat_src_type[i].checked) { v_stat_src_type_value = id_stat_src_type[i].value ; } }
//alert(v_stat_src_type_value) ;
//alert('OK2') ;
         v_url = \"$COMM_PAR_DOMAIN_HREF\"+window.location.pathname+\"?period_from=\"+v_period_from+\"&period_to=\"+v_period_to+\"&query_id=\"+v_query_id+\"&plan_hash=\"+v_plan_hash+\"&pid=\"+v_pid+\"&serial=\"+v_serial+\"&ds_type=\"+v_ds_type_value+\"&sess_state_filter=\"+v_sesttfltr+\"&dbid=\"+v_db_filter+\"&is_user_backends=\"+v_isusrback+\"&is_backgrounds=\"+v_isbgr+\"&is_extensions=\"+v_isext+\"&tab_detail=\"+v_tab_detail+\"&curr_conn=\"+v_curr_conn+\"&refresh_time=\"+v_refresh_time+\"&sort_field=\"+v_sort_field+\"&stat_src_type=\"+v_stat_src_type_value+\"&stat_src_snap_id=\"+v_stat_src_snap_id+\"&stat_start_snap_id=\"+v_stat_start_snap_id+\"&stat_is_graph_out=\"+v_stat_is_graph_out+\"&stat_stop_snap_id=\"+v_stat_stop_snap_id+\"&stat_is_table_out=\"+v_stat_is_table_out+\"&stat_obj=\"+v_stat_obj+\"&stat_owner=\"+v_stat_owner+\"&stat_schema=\"+v_stat_schema+\"&stat_obj_id=\"+v_stat_obj_id+\"&stat_part_name=\"+v_stat_part_name ;
//alert(v_url) ;
         window.location.href = v_url ;
         }

</SCRIPT>\n" ;
    }

# функция подготавливает переменные основного фильтра - начало и окончание периода, ID запроса и плана, PID сессии и старт бэкэнда, а также DBID, state, uer_backend, background, extensions
sub set_SAH_filter_period_sid_serial_dbid_state_ub_bg_ext() {
    if ( $pv{period_from} eq "" ||  $pv{period_to} eq "" ) { die ; }
    $where_timepoint .= " sampling_time >= TO_TIMESTAMP('$pv{period_from}','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND sampling_time <= TO_TIMESTAMP('$pv{period_to}','YYYY-MM-DD HH24:MI:SS')" ;
    if ( $pv{query_id} ne "" ) { $where_ext .= " AND query_id = $pv{query_id}" ; }
    if ( $pv{pid} ne "" ) { $where_ext .= " AND pid = $pv{pid}" ; }
    if ( $pv{serial} ne "" ) { $pv{serial} =~ s/(.+\s.+)\s03/$1+03/g ; $where_ext .= " AND backend_start = '$pv{serial}'" ; }
# кластерные процессы не имеют установленного dbid, в их записях NULL
    if ( $pv{dbid} ne "" && $pv{dbid} ne "all" && $pv{dbid} ne "all_db" ) { if ( $pv{dbid} ne "null" ) { $where_ext .= " AND datid = ($pv{dbid})::oid " ; } else { $where_ext .= " AND datid IS NULL " ; } }
    if ( $pv{sess_state_filter} ne "" && $pv{sess_state_filter} ne "all_states" ) {
       if ( $pv{sess_state_filter} eq "active" ) { $where_ext .= " AND state = 'active' " ; }
       if ( $pv{sess_state_filter} eq "all_idle" || $pv{sess_state_filter} eq "idle" ) { $where_ext .= " AND state LIKE '%idle%' " ; }
       if ( $pv{sess_state_filter} eq "idle_trns" ) { $where_ext .= " AND state = 'idle transaction' " ; }
       if ( $pv{sess_state_filter} eq "idle_tabrt" ) { $where_ext .= " AND state = 'idle transaction break' " ; }
       if ( $pv{sess_state_filter} eq "disabled" ) { $where_ext .= " AND state = 'disables' " ; }
       }
    if ( $pv{is_backgrounds} ne "true" ) { $where_ext .= " AND state IS NOT NULL AND query_id IS NOT NULL " ; }
    if ( $pv{is_user_backends} ne "true" ) { $where_ext .= " AND usename IS NULL " ; }
    if ( $pv{is_extensions} ne "true" ) { $where_ext .= " AND (wait_event_type IS NULL or NOT wait_event_type = 'Extension' ) " ; }
#-debug-print "<BR>=== where_timepoint: $where_timepoint, where_ext: $where_ext" ;
    }

# ----------------------------------------------------------------
# [на основе SA - pg_stats_activity] функция отображает горизонтальный столбец распределения запроса/сессии по классам активности
# ----------------------------------------------------------------
sub print_activity_graph($$$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_pid = $_[4] ; my $filter_session_serial = $_[5] ; my $percent = $_[6] ; $source_table_name = $_[7] ;
#-debug-$pv{period_from} = "2024-05-02 00:00:00" ; $pv{period_to} = "2025-06-03 00:00:00" ; $pv{ds_type} = "MEM" ; $pv{width} = 1500 ; $pv{height} = 700 ;
    $request_chart_per_class = " " ;
    $where_timepoint = "" ;
    $where_ext = "" ;
# - подготовить переменные основного фильтра
    set_SAH_filter_period_sid_serial_dbid_state_ub_bg_ext() ;
# ЗДЕСЬ - НЕТ (см. комментарий ниже), т.к. выбираем суммарные веса запроса/сессии за период
# - не забываем, что мы должны показать всю временную шкалу и активность по выбранным элементам
# - поэтому дополнительные WHERE выражения добавляем только во второй источник
   $request_chart_per_class = "
select sum(src2.wc_CPU_Active) wc_CPU_Active, sum(src2.wc_Activity) wc_Activity, sum(src2.wc_BufferPin) wc_BufferPin, sum(src2.wc_Client) wc_Client,
       sum(src2.wc_Extension) wc_Extension, sum(src2.wc_IO) wc_IO, sum(src2.wc_IPC) wc_IPC, sum(src2.wc_Lock) wc_Lock, sum(src2.wc_LWLock) wc_LWLock,
       sum(src2.wc_Timeout) wc_Timeout, sum(src2.wc_Other) wc_Other
       from (select src1.sampling_time,
            CASE WHEN src1.wait_event_type = 'CPU Active' THEN src1.value ELSE 0 END wc_CPU_Active,
            CASE WHEN src1.wait_event_type = 'Activity' THEN src1.value ELSE 0 END wc_Activity,
            CASE WHEN src1.wait_event_type = 'BufferPin' THEN src1.value ELSE 0 END wc_BufferPin,
            CASE WHEN src1.wait_event_type = 'Client' THEN src1.value ELSE 0 END wc_Client,
            CASE WHEN src1.wait_event_type = 'Extension' THEN src1.value ELSE 0 END wc_Extension,
            CASE WHEN src1.wait_event_type = 'IO' THEN src1.value ELSE 0 END wc_IO,
            CASE WHEN src1.wait_event_type = 'IPC' THEN src1.value ELSE 0 END wc_IPC,
            CASE WHEN src1.wait_event_type = 'Lock' THEN src1.value ELSE 0 END wc_Lock,
            CASE WHEN src1.wait_event_type = 'LWLock' THEN src1.value ELSE 0 END wc_LWLock,
            CASE WHEN src1.wait_event_type = 'Timeout' THEN src1.value ELSE 0 END wc_Timeout,
            CASE WHEN src1.wait_event_type NOT IN ('CPU Active','Activity','BufferPin','Client','Extension','IO','IPC','Lock','LWLock','Timeout')
                                      THEN src1.value ELSE 0 END wc_Other
            from (select ash.sampling_time sampling_time,
                         CASE WHEN ash.wait_event_type IS NULL THEN 'CPU Active' ELSE ash.wait_event_type END wait_event_type, round(sum(ash.value)/60,4) value
                         from (select date_trunc('minute', sampling_time) sampling_time, wait_event_type, count(*) value
                                      from $source_table_name
                                      where $where_timepoint $where_ext
                                      group by date_trunc('minute', sampling_time), wait_event_type) ash
                         group by ash.sampling_time, ash.wait_event_type) src1 ) src2 " ;

#debug-print "<BR>$request_chart_per_class<BR>" ;

    my $white_spaces = 100 - $percent ;
    my $count_class = 0 ;
#-debug-print "<BR>!!! pre sql ws = $white_spaces, prc = $percent<BR>" ;
    my $dbh_chart_per_class = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_chart_per_class = $dbh_chart_per_class->prepare($request_chart_per_class) ; $sth_chart_per_class->execute() ; $count_rows = 0 ;

#-debug-print "<BR>!!! execute sql<BR>" ;
    while (my ($wc_CPU_Active, $wc_Activity, $wc_BufferPin, $wc_Client, $wc_Extension, $wc_IO, $wc_IPC, $wc_Lock, $wc_LWLock, $wc_Timeout, $wc_Other) = $sth_chart_per_class->fetchrow_array() ) {
          $count_class++ ;
          my $tmp_sum =  $wc_CPU_Active + $wc_Activity + $wc_BufferPin + $wc_Client + $wc_Extension + $wc_IO + $wc_IPC + $wc_Lock + $wc_LWLock + $wc_Timeout + $wc_Other ;
#-debug-print "<BR>--$white_spaces -- $tmp_sum --" ;
#-debug-print "<BR>\n - class - tmp_sum $tmp_sum, query_id $query_id, time $begin_time, actSess $wc_ActiveSession, concurr $wc_Concurrency, userIO $wc_UserIO, systemIO $wc_SystemIO, other $wc_Other, config $wc_Configuration, sched $wc_Scheduler, cpu $wc_CPU, app $wc_nameApplication, commit $wc_Commit, net $wc_Network, admin $wc_Administrative, clust $wc_Cluster\n" ;
          $wc_CPU_Active = sprintf("%.1f", $wc_CPU_Active * $percent / $tmp_sum) ;
          $wc_Activity = sprintf("%.1f", $wc_Activity * $percent / $tmp_sum) ;
          $wc_BufferPin = sprintf("%.1f", $wc_BufferPin * $percent / $tmp_sum) ;
          $wc_Client = sprintf("%.1f", $wc_Client * $percent / $tmp_sum) ;
          $wc_Extension = sprintf("%.1f", $wc_Extension  * $percent / $tmp_sum) ;
          $wc_IO = sprintf("%.1f", $wc_IO * $percent / $tmp_sum) ;
          $wc_IPC = sprintf("%.1f", $wc_IPC * $percent / $tmp_sum) ;
          $wc_Lock = sprintf("%.1f", $wc_Lock * $percent / $tmp_sum) ;
          $wc_LWLock = sprintf("%.1f", $wc_LWLock * $percent / $tmp_sum) ;
          $wc_Timeout = sprintf("%d", $wc_Timeout * $percent / $tmp_sum) ;
          $wc_Other = sprintf("%d", $wc_Other * $percent / $tmp_sum) ;
#-debug-print "<BR>\n - class - tmp_sum $tmp_sum, query_id $query_id, time $begin_time, actSess $wc_ActiveSession, concurr $wc_Concurrency, userIO $wc_UserIO, systemIO $wc_SystemIO, other $wc_Other, config $wc_Configuration, sched $wc_Scheduler, cpu $wc_CPU, app $wc_Application, commit $wc_Commit, net $wc_Network, admin $wc_Administrative, clust $wc_Cluster\n" ;
          print "<TABLE WIDTH=\"200pt;\" HEIGHT=\"8pt;\" CELLPADDING=\"0\" CELLSPACING=\"0\"><TR>" ;
          if ( $wc_CPU_Active > 0 ) { print "<TD TITLE=\"CPU Active $wc_CPU_Active\%\" STYLE=\"width: $wc_CPU_Active\%; height: 15pt; background-color: darkgreen;\">&nbsp;</TD>" ; }
          if ( $wc_Activity > 0 ) { print "<TD TITLE=\"Activity $wc_Activity\%\" STYLE=\"width: $wc_Activity\%; height: 15pt; background-color: lime;\">&nbsp;</TD>" ; }
          if ( $wc_BufferPin > 0 ) { print "<TD TITLE=\"BufferPin $wc_BufferPin\%\" STYLE=\"width: $wc_BufferPin\%; height: 15pt; background-color: pink;\">&nbsp;</TD>" ; }
          if ( $wc_Client > 0 ) { print "<TD TITLE=\"Client $wc_Client\%\" STYLE=\"width: $wc_Client\%; height: 15pt; background-color: cyan;\">&nbsp;</TD>" ; }
          if ( $wc_Extension > 0 ) { print "<TD TITLE=\"Extension $wc_Extension\%\" STYLE=\"width: $wc_Extension\%; height: 15pt; background-color: slateblue;\">&nbsp;</TD>" ; }
          if ( $wc_IO > 0 ) { print "<TD TITLE=\"IO $wc_IO\%\" STYLE=\"width: $wc_IO\%; height: 15pt; background-color: navy;\">&nbsp;</TD>" ; }
          if ( $wc_IPC > 0 ) { print "<TD TITLE=\"IPC $wc_IPC\%\" STYLE=\"width: $wc_IPC\%; height: 15pt; background-color: orange;\">&nbsp;</TD>" ; }
          if ( $wc_Lock > 0 ) { print "<TD TITLE=\"Lock $wc_Lock\%\" STYLE=\"width: $wc_Lock\%; height: 15pt; background-color: darkred;\">&nbsp;</TD>" ; }
          if ( $wc_LWLock > 0 ) { print "<TD TITLE=\"LWLock $wc_LWLock\%\" STYLE=\"width: $wc_LWLock\%; height: 15pt; background-color: red;\">&nbsp;</TD>" ; }
          if ( $wc_Timeout > 0 ) { print "<TD TITLE=\"Timeout $wc_Timeout\%\" STYLE=\"width: $wc_Timeout\%; height: 15pt; background-color: lightgray;\">&nbsp;</TD>" ; }
          if ( $wc_Other > 0 ) { print "<TD TITLE=\"Other $wc_Other\%\" STYLE=\"width: $wc_Other\%; height: 15pt; background-color: black;\">&nbsp;</TD>" ; }
          print "<TD STYLE=\"width: $white_spaces\%; height: 15pt; background-color: white;\">&nbsp;</TD>" ;
          print "</TR></TABLE>" ; }
    $sth_chart_per_class->finish() ;
    $dbh_chart_per_class->disconnect() ;
#-debug- for ($i=0;$i<=$count_rows;$i++) { print "$avg_data_source[0][$i] $avg_data_source[1][$i] $avg_data_source[2][$i] $avg_data_source[3][$i] $avg_data_source[4][$i] $avg_data_source[5][$i]\n" ; } exit 0 ;
#-debug-print "<BR>\n$request_chart_per_class" ;
    }

# ----------------------------------------------------------------
# [на основе SA - pg_stats_activity] функция отображает головной график ASH для БД или кластера в целом, запроса или сессии, а также инструменты установки фильтров
# ----------------------------------------------------------------
sub print_head_ash_graph() {
    $sz_current_date_short = `date "+%Y-%m-%d 00:00:00"` ;
    $sz_current_date = `date "+%Y-%m-%d 23:59:59"` ;
    $pv{period_from} = ( $pv{period_from} eq "" ) ? $sz_current_date_short : $pv{period_from} ;
    $pv{period_to} = ( $pv{period_to} eq "" ) ? $sz_current_date : $pv{period_to} ;
    if ($pv{ds_type} eq "" || $pv{ds_type} eq "undefined") { $pv{ds_type} = "DB" ; } my $is_ds_type_db = " CHECKED" ; my $is_ds_type_mem = "" ; if ($pv{ds_type} eq "MEM") { $is_ds_type_db = "" ; $is_ds_type_mem = " CHECKED" ; }
    #$pv{serial} = "" ; 
    $pv{plan_hash} = "NO in PG vanilla" ;
    $pv{sess_state_filter} = ( $pv{sess_state_filter} eq "" ) ? "all_states" : $pv{sess_state_filter} ;

# изначально включаем всё
    if ( $pv{is_user_backends} eq "" ) { $pv{is_user_backends} = "true" ; }
    if ( $pv{is_backgrounds} eq "" ) { $pv{is_backgrounds} = "true" ; }
    if ( $pv{is_extensions} eq "" ) { $pv{is_extensions} = "true" ; }

    set_common_pg_mon_cgi_prefix() ;

    print "<TABLE STYLE=\"width: 100%\">
           <TR><TD STYLE=\"text-align: left; font-size: 8pt;\">Режимы&nbsp;отображения&nbsp;SA:\n</TD><TD STYLE=\"text-align: center; font-size: 8pt;\">state 
               <SELECT NAME=\"sess_state_filter\" ID=\"id_sess_state_filter\" STYLE=\"text-align: left; font-size: 8pt;\" TITLE=\"показывает выбранную активность в поле state\">\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "all_states" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"all_states\">Все [all states]</OPTION>\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "active" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"active\" $is_slctd_sess_stt_fltr>Активные [active]</OPTION>\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "all_idle" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"all_idle\" $is_slctd_sess_stt_fltr>Не активные [all idle]</OPTION>\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "idle_trns" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"idle_trns\" $is_slctd_sess_stt_fltr>idle transaction</OPTION>\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "idle_tabrt" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"idle_tabrt\" $is_slctd_sess_stt_fltr>idle transaction break</OPTION>\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "disabled" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"disabled\" $is_slctd_sess_stt_fltr>Выключено [disabled]</OPTION>\n" ;
    print "</SELECT>&nbsp;БД:&nbsp;<SELECT NAME=\db_filter\" ID=\"id_db_filter\" STYLE=\"text-align: left; font-size: 8pt; width: 300pt;\" TITLE=\"показывает активность выбранной БД кластера, или весь кластер, или background [datid = NULL]\">\n" ;
           $is_slctd_sess_stt_fltr = "" ; if ( $pv{dbid} eq "all_db" || $pv{dbid} eq "" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"all_db\">Вся активность кластера [БД и фоновые]</OPTION>\n" ;
           $is_slctd_sess_stt_fltr = "" ; if ( $pv{dbid} eq "null" ||  $pv{dbid} eq "NULL" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"null\" $is_slctd_sess_stt_fltr>Фоновые процессы кластера [datid = NULL]</OPTION>\n" ;

    $request_database = "select oid, datname from pg_catalog.pg_database order by oid asc" ;

if ( $pv{curr_conn} eq "" ) { $pv{curr_conn} = $default_connector ; }
    my $dbh_database = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ; my $sth_database = $dbh_database->prepare($request_database) ; $sth_database->execute() ;
    while (my ($oid, $datname) = $sth_database->fetchrow_array() ) { my $is_selected = "" ; if ( $pv{dbid} eq $oid ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$oid\" $is_selected>$datname [$oid]</OPTION>\n" ; } $sth_database->finish() ; $dbh_database->disconnect() ;
    print "</SELECT></TD><TD STYLE=\"text-align: right; font-size: 8pt;\">" ;
         $is_checked_user_backends = "" ; if ( $pv{is_user_backends} eq "true" ) { $is_checked_user_backends = "CHECKED" ; }
         $is_checked_backgrounds = "" ; if ( $pv{is_backgrounds} eq "true" ) { $is_checked_backgrounds = "CHECKED" ; }
         $is_checked_extensions = "" ; if ( $pv{is_extensions} eq "true" ) { $is_checked_extensions = "CHECKED" ; }
    print "</SELECT>
        &nbsp;
        <INPUT $is_checked_user_backends VALUE =\"$pv{is_user_backends}\" TYPE=\"checkbox\" NAME=\"is_user_backends\" ID=\"id_is_user_backends\" TITLE=\"включает строки [usename IS NOT NULL]\">user backends</INPUT>
        <INPUT $is_checked_backgrounds TYPE=\"checkbox\" NAME=\"is_backgrounds\" ID=\"id_is_backgrounds\" TITLE=\"включает строки [state IS NULL and query_id IS NULL]\">backgrounds</INPUT>
        <INPUT $is_checked_extensions TYPE=\"checkbox\" NAME=\"is_extensions\" ID=\"id_is_extensions\" TITLE=\"показывает класс событий EXTENSION\">extensions</INPUT>
    </TD></TR>
    <TR><TD STYLE=\"text-align: left; font-size: 8pt;\">Период&nbsp;с&nbsp;
            <INPUT VALUE=\"$pv{period_from}\" ID=\"id_period_date_start\" STYLE=\"width: 101pt; font-size: 8pt;\"
                   onsubmit=\"renew_db_status_page(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,id_sess_state_filter.value,id_db_filter.value,id_is_user_backends.checked,id_is_backgrounds.checked,id_is_extensions.checked,'$pv{tab_detail}',id_curr_conn.value,id_refresh_time.value,'$pv{sort_field}','&x=x')\"></TD>
        <TD STYLE=\"text-align: center; font-size: 8pt;\">
            PID&nbsp;<INPUT VALUE=\"$pv{pid}\" ID=\"id_pid\" STYLE=\"width: 48pt; font-size: 8pt;\">&nbsp;
            P_START&nbsp;<INPUT VALUE=\"$pv{serial}\" ID=\"id_serial\" STYLE=\"width: 87pt; font-size: 8pt;\">&nbsp;&nbsp;
            QUERY_ID&nbsp;<INPUT VALUE=\"$pv{query_id}\" ID=\"id_query_id\" STYLE=\"width: 101pt; font-size: 8pt;\">&nbsp;
            PLAN&nbsp;<INPUT VALUE=\"$pv{plan_hash}\" ID=\"id_plan_hash\" STYLE=\"width: 78pt; font-size: 8pt;\" DISABLED>&nbsp;
        </TD>
        <TD STYLE=\"text-align: right; font-size: 8pt;\">Период&nbsp;по&nbsp;
            <INPUT VALUE=\"$pv{period_to}\" ID=\"id_period_date_stop\" STYLE=\"width: 101pt; font-size: 8pt;\"
                   onsubmit=\"renew_db_status_page(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,id_sess_state_filter.value,id_db_filter.value,id_is_user_backends.checked,id_is_backgrounds.checked,id_is_extensions.checked,'$pv{tab_detail}',id_curr_conn.value,id_refresh_time.value,'$pv{sort_field}','&x=x')\">
            &nbsp;<INPUT TITLE=\"SA - таблица агрегации, WS - таблица агрегации\" TYPE=\"radio\" NAME=\"ds_type\" ID=\"id_ds_type\" VALUE=\"DB\" $is_ds_type_db>DB</INPUT>
            &nbsp;<INPUT TITLE=\"SA - таблица агрегации, WS - сырые данные без агрегации, в зависимости от настроек периодичности срезов возможно резкое замедление\" TYPE=\"radio\" NAME=\"ds_type\" ID=\"id_ds_type\" VALUE=\"MEM\" $is_ds_type_mem>Mem</INPUT>
            &nbsp; <SPAN STYLE=\"font-size: 10pt; color: navy; cursor: pointer; pointer: arrow;\"
                   onclick=\"renew_db_status_page(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,id_sess_state_filter.value,id_db_filter.value,id_is_user_backends.checked,id_is_backgrounds.checked,id_is_extensions.checked,'$pv{tab_detail}',id_curr_conn.value,id_refresh_time.value,'$pv{sort_field}','&x=x')\">&nbsp;&nbsp;обновить</SPAN>
        </TD></TR>
    <TR><TD COLSPAN=\"3\">
    <A TARGET=\"_blank\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_SAH_top_activity.cgi?$common_pg_mon_cgi_prefix&width=1450&height=500\">
           <IMG style=\"width:100%; height: 240pt;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_SAH_top_activity.cgi?$common_pg_mon_cgi_prefix&width=2800&height=600\"></A>
    </TD></TR>
    </TABLE>" ;

    print "<STYLE>
          TD { font-size: 10pt; ; }
          </STYLE>" ;
    }

# ------------------------------------------------------
# [на основе SA - pg_stats_activity] функция отображает таблицу ТОП запросов
# ------------------------------------------------------
sub print_sql_table_activity($$$$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ; $output_format = $_[7] ; $record_limit = $_[8] ;
    $query_text_substr_size = 30 ;
    $where_timepoint = "" ;
    $where_ext = "" ;
# - подготовить переменные основного фильтра
    set_SAH_filter_period_sid_serial_dbid_state_ub_bg_ext() ;

    print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid; font-size: 10pt;\">";

# тут печатаем заголовок таблицы для короткого или длинного формата
    if ( $output_format eq "" or $output_format eq "short" ) {
       print "<TR><TD STYLE=\"text-align: center;\">SA Activity Query</TD><TD STYLE=\"text-align: center;\">%</TD><TD STYLE=\"text-align: center;\">Query ID [plan count]</TD><TD STYLE=\"text-align: center;\">Query</TD></TR>\n" ; }
    if ( $output_format eq "long" ) {
       print "<TR><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">#</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">SA Activity Query</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">%</TD>
                  <TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">userid</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">dbid</TD>
<TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">query</TD>
<TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">top level</TD>
                  <TD CLASS=\"td_query_stats_head\">plans</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">calls</TD><TD CLASS=\"td_query_stats_head\">exec</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">rows</TD>
                  <TD CLASS=\"td_query_stats_head\">shared_blks</TD><TD CLASS=\"td_query_stats_head\">local_blks</TD>
                  <TD CLASS=\"td_query_stats_head\">temp_blks</TD><TD CLASS=\"td_query_stats_head\">blk_time</TD><TD CLASS=\"td_query_stats_head\">temp_blk_time</TD>
                  <TD CLASS=\"td_query_stats_head\">WALcalls</TD></TR>\n

              <TR><TD CLASS=\"td_query_stats_head\">count<BR>total<BR>mean</TD>
                  <TD CLASS=\"td_query_stats_head\">total ex<BR>mean ex</TD>
                  <TD CLASS=\"td_query_stats_head\">shrd hit<BR>read<BR>dirtied<BR>written</TD>
                  <TD CLASS=\"td_query_stats_head\">lcl hit<BR>read<BR>dirtied<BR>written</TD>
                  <TD CLASS=\"td_query_stats_head\">read<BR>written</TD>
                  <TD CLASS=\"td_query_stats_head\">read<BR>written</TD><TD CLASS=\"td_query_stats_head\">read<BR>written</TD>
                  <TD CLASS=\"td_query_stats_head\">records<BR>fpi<BR>bytes</TD></TR>\n" ;

#print "<TR><TD STYLE=\"text-align: center;\">SA Activity Query</TD><TD STYLE=\"text-align: center;\">%</TD><TD STYLE=\"text-align: center;\">Query ID [plan count]</TD>
#                  <TD STYLE=\"text-align: center;\">Exec</TD><TD STYLE=\"text-align: center;\">AVG Time<BR>per exec</TD><TD STYLE=\"text-align: center;\">Plans count</TD><TD STYLE=\"text-align: center;\">Query</TD></TR>\n" ;
       }

# ЗДЕСЬ - НЕТ (см. комментарий ниже), т.к. выбираем суммарные веса запросов за период
# не забываем, что мы должны показать всю временную шкалу и активность по выбранным элементам - поэтому дополнительные WHERE выражения добавляем только во второй источник
    my $source_table_name = "bestat_sa_history" ; if ($pv{ds_type} eq "DB") { $source_table_name = "bestat_sa_history" ; }
    $request_top_sql = "select ds_1.percent, ds_1.query_id
                               from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.query_id
                                             from (select 'ok' ok1, count(*) count_point, query_id
                                                  from $source_table_name
                                                  where $where_timepoint $where_ext
                                                  group by query_id) a1,
                                    (select 'ok' ok1, count(*) sum_count_point
                                            from $source_table_name
                                            where $where_timepoint $where_ext) a2
                                    where a1.ok1 = a2.ok1
                               order by 1 desc) ds_1 LIMIT $record_limit" ;
# AND NOT query_id = 0
#open(DEBG,">/tmp/print_sql_table_activity.out") ; print DEBG $request_top_sql ;
#-debug-print "<PRE>request_top_sql = $request_top_sql</PRE>" ;
#    my $dbh_top_sql = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", $COMM_PAR_PGSQL_DB_NAME, $COMM_PAR_PGSQL_DB_PASSWORD);
    my $dbh_top_sql = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_top_sql  = $dbh_top_sql->prepare($request_top_sql ) ; $sth_top_sql->execute() ;
    my $rows_count = 0 ;
    while (my ( $percent, $query_id, $count_point ) = $sth_top_sql->fetchrow_array() ) { $rows_count++ ;
# введена локальная переменная, чтобы кастомизировать унифицированную переменную
          my $common_pg_mon_cgi_prefix = "period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$query_id&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&dbid=$pv{dbid}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&ds_type=$pv{ds_type}&curr_conn=$pv{curr_conn}&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}" ;
#-debug-print "<BR># = $rows_count<BR>" ;
# вытащить текст запроса
          my $curr_query_text_substr = "" ; my $curr_count_query_text_substr = 0 ;
          if ( $query_id eq "" ) { $curr_query_text_substr = "не определяется / фоновые" ;
             }
          else {
             if ( $output_format eq "" or $output_format eq "short" ) { $query_text_substr_size = 30 ; } if ( $output_format eq "long" ) { $query_text_substr_size = 200 ; }
             my $request_curr_query_text_substr = "select substr(query,1,$query_text_substr_size) from bestat_query_text where queryid = $query_id" ;
             my $dbh_curr_query_text_substr = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
             my $sth_curr_query_text_substr  = $dbh_curr_query_text_substr->prepare($request_curr_query_text_substr ) ; $sth_curr_query_text_substr->execute() ;
             while (my ($res_curr_query_text_substr) = $sth_curr_query_text_substr->fetchrow_array()) { $curr_count_query_text_substr++ ; $curr_query_text_substr = $res_curr_query_text_substr ; }
             if ( $curr_query_text_substr eq "" || $curr_count_query_text_substr == 0 ) {
                $sth_curr_query_text_substr->finish() ;
                $request_curr_query_text_substr = "select substr(query,1,$query_text_substr_size) from pg_stat_activity where query_id = $query_id" ;
                $sth_curr_query_text_substr  = $dbh_curr_query_text_substr->prepare($request_curr_query_text_substr ) ; $sth_curr_query_text_substr->execute() ; 
                while (($res_curr_query_text_substr) = $sth_curr_query_text_substr->fetchrow_array()) { $curr_query_text_substr = $res_curr_query_text_substr ; }
                }
             $sth_curr_query_text_substr->finish() ; $dbh_curr_query_text_substr->disconnect() ;
             $curr_query_text_substr =~ s/\n/&nbsp;/g ;
             }
# напечатать строку таблицы для короткого формата

#https://zrt.ourorbits.ru/crypta/cgi/tools_pg_monitor_TA_query.cgi?period_from=2025-03-13%2000:00:00&period_to=2025-03-13%2023:59:59&query_id=5383498160794443372&plan_hash=NO%20in%20PG%20vanilla
#&pid=&serial=&dbid=all_db&sess_state_filter=all_states&is_user_backends=true&is_backgrounds=true&is_extensions=true&ds_type=DB&curr_conn=A01_1_1_cypta1&refresh_time=none&sort_field=undefined&tab_detail=3
          if ( $output_format eq "" or $output_format eq "short" ) {
             print "\n<TR>\n<TD TITLE=\"#: $rows_count\">" ;
             print_activity_graph($pv{period_from}, $pv{period_to}, $query_id, '', '', '', $percent, $source_table_name) ;
             print "</TD>\n" ;
             print "<TD STYLE=\"text-align: right; font-size: 10pt;\">$percent</TD>\n" ;
             print "<TD><A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix&page_part=1&srcptr=&child_number=\">$query_id</A></TD>
                    <TD>$curr_query_text_substr ...</TD>\n" ; }
# напечатать строку таблицы для длинного формата
         if ( $output_format eq "long" ) {
# print_logs_sql_stats($query_id, $percent, $source_table_name,$curr_query_text_substr) ; }

            $request_query_id_stats = "
select userid,dbid,toplevel,sum(plans),round(sum(total_plan_time)::numeric,2),round(avg(mean_plan_time)::numeric,2),sum(calls),round(sum(total_exec_time)::numeric,2),round(avg(mean_exec_time)::numeric,2),
       sum(rows),round((sum(shared_blks_hit*calls)/sum(calls))::numeric,2),round(sum(shared_blks_read)::numeric,2),round(sum(shared_blks_dirtied)::numeric,2),round(sum(shared_blks_written)::numeric,2),
       round((sum(local_blks_hit*calls)/sum(calls))::numeric,2),round(sum(local_blks_read)::numeric,2),round(sum(local_blks_dirtied)::numeric,2),round(sum(local_blks_written)::numeric,2),
       round(sum(temp_blks_read)::numeric,2),round(sum(temp_blks_written)::numeric,2),round(sum(blk_read_time)::numeric,2),round(sum(blk_write_time)::numeric,2),round(sum(temp_blk_read_time)::numeric,2),
       round(sum(temp_blk_write_time)::numeric,2),round(sum(wal_records)::numeric,2),round(sum(wal_fpi)::numeric,2),round(sum(wal_bytes)::numeric,2)
       from pg_stat_statements where queryid = $query_id group by userid,dbid,toplevel " ;
#-debug-print "<PRE>$request_query_id_stats</PRE>" ;
            my $dbh_query_id_stats = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
            my $sth_query_id_stats  = $dbh_query_id_stats->prepare($request_query_id_stats) ; $sth_query_id_stats->execute() ;
#-debug-print "<BR>qi = $query_id<BR>" ;
            my $query_stats_count_rows = 0 ;
           while (my($userid,$dbid,$toplevel,$plans,$total_plan_time,$mean_plan_time,$calls,$total_exec_time,$mean_exec_time,$rows,$shared_blks_hit,$shared_blks_read,$shared_blks_dirtied,$shared_blks_written,$local_blks_hit,$local_blks_read,$local_blks_dirtied,$local_blks_written,$temp_blks_read,$temp_blks_written,$blk_read_time,$blk_write_time,$temp_blk_read_time,$temp_blk_write_time,$wal_records,$wal_fpi,$wal_bytes) = $sth_query_id_stats->fetchrow_array()) {
                    $query_stats_count_rows++ ;
                  print "\n<TR>\n<TD>$rows_count</TD><TD STYLE=\"text-align: left; font-size: 8pt;\">SQL ID: 
                        <A STYLE=\"text-align: left; font-size: 8pt;\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix\">$query_id</A><BR><BR>" ;
                  print_activity_graph($pv{period_from}, $pv{period_to}, $query_id, '', '', '', $percent, $source_table_name) ;
                  print "</TD>\n" ;
                  print "<TD STYLE=\"text-align: right; font-size: 8pt;\">$percent</TD><TD STYLE=\"text-align: right; font-size: 8pt;\">$userid</TD><TD STYLE=\"text-align: right; font-size: 8pt;\">$dbid</TD>" ;
                  print "<TD STYLE=\"text-align: left; font-size: 8pt; width: 400pt;\"><A STYLE=\"text-align: left; font-size: 8pt;\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix\">$curr_query_text_substr ...</A></TD>\n" ;
                  print "<TD STYLE=\"text-align: right; font-size: 8pt;\">$toplevel</TD>
                         <TD STYLE=\"text-align: right; font-size: 8pt;\">$plans<BR>$total_plan_time<BR>$mean_plan_time</TD>
                         <TD STYLE=\"text-align: right; font-size: 8pt;\">$calls</TD>
                         <TD STYLE=\"text-align: right; font-size: 8pt;\">$total_exec_time<BR>$mean_exec_time</TD>
                         <TD STYLE=\"text-align: right; font-size: 8pt;\">$rows</TD>
                         <TD STYLE=\"text-align: right; font-size: 8pt;\">$shared_blks_hit<BR>$shared_blks_read<BR>$shared_blks_dirtied<BR>$shared_blks_written</TD>
                         <TD STYLE=\"text-align: right; font-size: 8pt;\">$local_blks_hit<BR>$local_blks_read<BR>$local_blks_dirtied<BR>$local_blks_written</TD>
                         <TD STYLE=\"text-align: right; font-size: 8pt;\">$temp_blks_read<BR>$temp_blks_written</TD>
                         <TD STYLE=\"text-align: right; font-size: 8pt;\">$blk_read_time<BR>$blk_write_time</TD>
                         <TD STYLE=\"text-align: right; font-size: 8pt;\">$temp_blk_read_time<BR>$temp_blk_write_time</TD>
                         <TD STYLE=\"text-align: right; font-size: 8pt;\">$wal_records<BR>$wal_fpi<BR>$wal_bytes</TD>\n" ; }
            $sth_query_id_stats->finish() ;
            $dbh_query_id_stats->disconnect() ;
            if ($query_stats_count_rows == 0) {
               print "\n<TR>\n<TD STYLE=\"text-align: right; font-size: 8pt;\">$rows_count</TD><TD STYLE=\"text-align: right; font-size: 8pt;\">" ;
               print_activity_graph($pv{period_from}, $pv{period_to}, $query_id, '', '', '', $percent, $source_table_name) ;
               print "<TD STYLE=\"text-align: right; font-size: 8pt;\">$percent</TD>\n" ;
               print "</TD><TD STYLE=\"text-align: right; font-size: 8pt;\" COLSPAN=\"2\"></TD>\n" ;
               print "<TD><A STYLE=\"text-align: left; font-size: 8pt;\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix$common_pg_mon_cgi_prefix\">$curr_query_text_substr ...</A></TD>\n" ;
               print "<TD STYLE=\"text-align: left; font-size: 8pt;\" COLSPAN=\"11\">статистики для запроса не найдены ...</TD>\n" ;
               }
            }
         print "</TR>\n" ;
         }
    $sth_top_sql->finish() ;
    $dbh_top_sql->disconnect() ;
    print "</TABLE>" ;
    }

# ------------------------------------------------------
# [на основе SA - pg_stats_activity] функция отображает таблицу ТОП сессий
# ------------------------------------------------------
sub print_session_table_activity($$$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ; $output_format = $_[7] ; $record_limit = $_[8] ;
    $where_timepoint = "" ;
    $where_ext = "" ;
# - подготовить переменные основного фильтра
    set_SAH_filter_period_sid_serial_dbid_state_ub_bg_ext() ;

    print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">
            <TR><TD STYLE=\"text-align: center;\">SA Activity Session</TD><TD STYLE=\"text-align: center;\">%</TD><TD STYLE=\"text-align: center;\">Process ID</TD>" ;
    if ( $output_format eq "" or $output_format eq "short" ) {
       print "<TD STYLE=\"text-align: center;\">Username</TD><TD STYLE=\"text-align: center;\">Application</TD></TR>"; }
    if ( $output_format eq "long" ) {
       print "<TD STYLE=\"text-align: center;\">backend_start</TD><TD STYLE=\"text-align: center;\">client_hostname</TD><TD STYLE=\"text-align: center;\">client_addr</TD><TD STYLE=\"text-align: center;\">client_port</TD><TD STYLE=\"text-align: center;\">usesysid</TD>
              <TD STYLE=\"text-align: center;\">Username</TD><TD STYLE=\"text-align: center;\">Application</TD><TD STYLE=\"text-align: center;\">Backend type</TD></TR>"; }
    $request_top_sess = "select ds_1.percent, ds_1.pid, ds_1.backend_start, ds_1.datname, ds_1.usesysid, ds_1.usename, ds_1.application_name, ds_1.client_addr, ds_1.client_hostname, ds_1.client_port, ds_1.backend_type
                                from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.pid, a1.backend_start, a1.datname, a1.usesysid, a1.usename,
                                              a1.application_name, a1.client_addr, a1.client_hostname, a1.client_port, a1.backend_type
                                              from (select 'ok' ok1, count(*) count_point, pid, backend_start, datname, usesysid, usename, application_name, client_addr, client_hostname, client_port, backend_type
                                                           from $source_table_name
                                                           where $where_timepoint $where_ext
                                                           group by pid, backend_start, datname, usesysid, usename, application_name, client_addr, client_hostname, client_port, backend_type) a1,
                                                   (select 'ok' ok1, count(*) sum_count_point
                                                           from $source_table_name
                                                           where $where_timepoint $where_ext) a2
                                              where a1.ok1 = a2.ok1
                                              order by 1 desc) ds_1 LIMIT $record_limit" ;
#open(DEBG,">/tmp/print_pid_table_activity.out") ; print DEBG $request_top_sess ;
#print "=== $request_top_sess ===" ;
    my $dbh_top_sess = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_top_sess  = $dbh_top_sess ->prepare($request_top_sess ) ; $sth_top_sess->execute() ;
    while (my ( $percent, $pid, $backend_start, $datname, $usesysid, $username, $application_name, $client_addr, $client_hostname, $client_port, $backend_type ) = $sth_top_sess->fetchrow_array() ) {
# введена локальная переменная, чтобы кастомизировать унифицированную переменную
          my $common_pg_mon_cgi_prefix = "period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pid&serial=$backend_start&dbid=$pv{dbid}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&ds_type=$pv{ds_type}&curr_conn=$pv{curr_conn}&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}" ;
          print "<TR><TD>" ;
          print_activity_graph($pv{period_from}, $pv{period_to}, '', '', $pid, $backend_start, $percent, $source_table_name) ;
          print "</TD><TD>$percent</TD>" ;
          if ( $output_format eq "" or $output_format eq "short" ) {
             print "<TD><A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_session.cgi?$common_pg_mon_cgi_prefix&page_part=1\" TITLE=\"backend started: $backend_start, from host [$client_hostname], IP [$client_addr], port [$client_port]\">$pid</A></TD>
                    <TD TITLE=\"User ID: $usesysid\">$username</TD><TD TITLE=\"$backend_type\">$application_name</TD></TR>" ; }
          if ( $output_format eq "long" ) {
             print "<TD><A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_session.cgi?$common_pg_mon_cgi_prefix&page_part=1\">$pid</A></TD>
<TD>$backend_start</TD><TD>$client_hostname</TD><TD>$client_addr</TD><TD>$client_port</TD><TD>$usesysid</TD><TD>$username</TD><TD>$application_name</TD><TD>$backend_type</TD></TR>" ; }
          }
    $sth_top_sess->finish() ;
    $dbh_top_sess->disconnect() ;
    print "</TABLE>" ;
    }

# ------------------------------------------------------
# [на основе SA - pg_stats_activity] функция отображает таблицу ТОП событий ожиданий
# ------------------------------------------------------
sub print_sah_events($$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ;
#    my $source_table_name = "bestat_SAH" ; if  ($pv{ds_type} eq "DB") { $source_table_name = "bestat_SAH" ; }
    $where_timepoint = "" ;
    $where_ext = "" ;
# - подготовить переменные основного фильтра
    set_SAH_filter_period_sid_serial_dbid_state_ub_bg_ext() ;

    print "<TABLE BORDER=\"1\" WIDTH=\"100%\">
                 <TR><TD CLASS=\"td_waits_head\">Activity [pg_stat_activity]</TD><TD CLASS=\"td_waits_head\">%</TD><TD CLASS=\"td_waits_head\">count</TD><TD CLASS=\"td_waits_head\">state</TD><TD CLASS=\"td_waits_head\">Wait Event Type</TD><TD CLASS=\"td_waits_head\">Wait Event</TD></TR>\n" ;
    $request_query_per_wait_stats = "select a1.state, a1.wait_event_type, a1.wait_event, a1.ev_count, round((a1.ev_count::numeric  * 100 / a2.all_count),2) event_percent
                                            from ( select state, wait_event_type, wait_event, count(*) ev_count
                                                          from bestat_sa_history
                                                          where $where_timepoint $where_ext
                                                          group by state, wait_event_type, wait_event) a1,
                                                 ( select count(*) all_count
                                                          from bestat_sa_history
                                                          where $where_timepoint $where_ext) a2
                                            order by a1.ev_count desc " ;
#-debug-print "<BR>$request_query_per_wait_stats<BR>" ;
# !!! обработчики IS NULL ввести
   $count_rows_query_per_wait_stats = 0 ;
   my $dbh_query_per_wait_stats = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
   my $sth_query_per_wait_stats = $dbh_query_per_wait_stats->prepare($request_query_per_wait_stats) ; $sth_query_per_wait_stats->execute() ;
   while ( ($state,$wait_event_type,$wait_event,$wait_event_count, $event_percent) = $sth_query_per_wait_stats->fetchrow_array() ) {
         $count_rows_query_per_wait_stats++ ;
         $white_spaces = 100 - $event_percent ;
         print "<TR><TD CLASS=\"td_waits_right\" TITLE=\"#: $count_rows_query_per_wait_stats, count: $wait_event_count\">" ;
         print "<TABLE WIDTH=\"200pt;\" HEIGHT=\"8pt;\" CELLPADDING=\"0\" CELLSPACING=\"0\"><TR>" ;
         if ( $wait_event_type eq "" && $wait_event eq "" ) { print "<TD TITLE=\"CPU Active $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: darkgreen;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Activity" ) { print "<TD TITLE=\"Activity::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: lime;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "BufferPin" ) { print "<TD TITLE=\"BufferPin::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: pink;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Client" ) { print "<TD TITLE=\"Client::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: cyan;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Extension" ) { print "<TD TITLE=\"Extension::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: slateblue;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "IO" ) { print "<TD TITLE=\"IO::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: navy;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "IPC" ) { print "<TD TITLE=\"IPC::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: orange;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Lock" ) { print "<TD TITLE=\"Lock::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: darkred;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "LWLock" ) { print "<TD TITLE=\"LWLock::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: red;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Timeout" ) { print "<TD TITLE=\"Timeout::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: lightgray;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Other" ) { print "<TD TITLE=\"Other::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: black;\">&nbsp;</TD>" ; }
         print "<TD STYLE=\"width: $white_spaces\%; height: 15pt; background-color: white;\">&nbsp;</TD>" ;
         print "</TR></TABLE>" ;
         print "</TD><TD CLASS=\"td_waits_right\">$event_percent</TD><TD CLASS=\"td_waits_right\">$wait_event_count</TD><TD CLASS=\"td_waits_left\">$state</TD><TD CLASS=\"td_waits_left\">$wait_event_type</TD><TD CLASS=\"td_waits_left\">$wait_event</TD></TR>\n" ;
         }
   $sth_query_per_wait_stats->finish() ;
   $dbh_query_per_wait_stats->disconnect() ;
   print "</TABLE>" ;

    }


# ------------------------------------------------------
# [на основе WS - wait sampling extension]
# ------------------------------------------------------
sub print_wait_sampling_activity_graph($$$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_pid = $_[4] ; my $filter_session_serial = $_[5] ; my $percent = $_[6] ; $source_table_name = $_[7] ;
#-debug-$pv{period_from} = "2024-05-02 00:00:00" ; $pv{period_to} = "2025-06-03 00:00:00" ; $pv{ds_type} = "MEM" ; $pv{width} = 1500 ; $pv{height} = 700 ;
    $request_chart_per_class = " " ;
#####
my $source_table_name = "pg_wait_sampling_history" ; if ($pv{ds_type} eq "DB") { $source_table_name = "bestat_ws_history" ; }
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $pv{period_from} eq "" ||  $pv{period_to} eq "" ) { die ; }
    $where_timepoint .= " ts >= TO_TIMESTAMP('$pv{period_from}','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND ts <= TO_TIMESTAMP('$pv{period_to}','YYYY-MM-DD HH24:MI:SS')" ;

    if ( $filter_query_id ne "" ) { $where_ext .= " AND queryid = $filter_query_id" ; }
#    if ( $filter_sql_plan_hash_value ne "" ) { $where_ext .= " AND SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_pid ne "" ) { $where_ext .= " AND pid = $filter_pid" ; }
#    if ( $filter_session_serial ne "" ) { $where_ext .= " AND SESSION_SERIAL# = '$filter_session_serial'" ; }

if ($pv{ds_type} eq "MEM") {
   $request_chart_per_class = "
select sum(src2.wc_Activity) wc_Activity, sum(src2.wc_BufferPin) wc_BufferPin,
       sum(src2.wc_Client) wc_Client, sum(src2.wc_Extension) wc_Extension, sum(src2.wc_IO) wc_IO,
       sum(src2.wc_IPC) wc_IPC, sum(src2.wc_Lock) wc_Lock, sum(src2.wc_LWLock) wc_LWLock,
       sum(src2.wc_Timeout) wc_Timeout, sum(src2.wc_Other) wc_Other
       from (select src1.ts,
            CASE WHEN src1.event_type = 'Activity' THEN src1.value ELSE 0 END wc_Activity,
            CASE WHEN src1.event_type = 'BufferPin' THEN src1.value ELSE 0 END wc_BufferPin,
            CASE WHEN src1.event_type = 'Client' THEN src1.value ELSE 0 END wc_Client,
            CASE WHEN src1.event_type = 'Extension' THEN src1.value ELSE 0 END wc_Extension,
            CASE WHEN src1.event_type = 'IO' THEN src1.value ELSE 0 END wc_IO,
            CASE WHEN src1.event_type = 'IPC' THEN src1.value ELSE 0 END wc_IPC,
            CASE WHEN src1.event_type = 'Lock' THEN src1.value ELSE 0 END wc_Lock,
            CASE WHEN src1.event_type = 'LWLock' THEN src1.value ELSE 0 END wc_LWLock,
            CASE WHEN src1.event_type = 'Timeout' THEN src1.value ELSE 0 END wc_Timeout,
            CASE WHEN src1.event_type NOT IN ('Activity','BufferPin','Client','Extension','IO','IPC','Lock','LWLock','Timeout')
                                      THEN src1.value ELSE 0 END wc_Other
            from (select ash.ts ts, ash.event_type event_type, round(sum(ash.value)/6000,4) value
                         from (select date_trunc('minute', ts) ts, event_type, count(*) value
                                      from $source_table_name
                                      where $where_timepoint $where_ext
                                      group by date_trunc('minute', ts), event_type) ash
                         group by ash.ts, ash.event_type) src1 ) src2 " ;
#                         where ash.EVENT_TYPE IS NOT NULL
   }
if ($pv{ds_type} eq "DB") {
   $request_chart_per_class = "
select sum(src2.wc_Activity) wc_Activity, sum(src2.wc_BufferPin) wc_BufferPin,
       sum(src2.wc_Client) wc_Client, sum(src2.wc_Extension) wc_Extension, sum(src2.wc_IO) wc_IO,
       sum(src2.wc_IPC) wc_IPC, sum(src2.wc_Lock) wc_Lock, sum(src2.wc_LWLock) wc_LWLock,
       sum(src2.wc_Timeout) wc_Timeout, sum(src2.wc_Other) wc_Other
       from (select src1.ts,
            CASE WHEN src1.event_type = 'Activity' THEN src1.value ELSE 0 END wc_Activity,
            CASE WHEN src1.event_type = 'BufferPin' THEN src1.value ELSE 0 END wc_BufferPin,
            CASE WHEN src1.event_type = 'Client' THEN src1.value ELSE 0 END wc_Client,
            CASE WHEN src1.event_type = 'Extension' THEN src1.value ELSE 0 END wc_Extension,
            CASE WHEN src1.event_type = 'IO' THEN src1.value ELSE 0 END wc_IO,
            CASE WHEN src1.event_type = 'IPC' THEN src1.value ELSE 0 END wc_IPC,
            CASE WHEN src1.event_type = 'Lock' THEN src1.value ELSE 0 END wc_Lock,
            CASE WHEN src1.event_type = 'LWLock' THEN src1.value ELSE 0 END wc_LWLock,
            CASE WHEN src1.event_type = 'Timeout' THEN src1.value ELSE 0 END wc_Timeout,
            CASE WHEN src1.event_type NOT IN ('Activity','BufferPin','Client','Extension','IO','IPC','Lock','LWLock','Timeout')
                                      THEN src1.value ELSE 0 END wc_Other
            from (select ash.ts ts, ash.event_type event_type, round(sum(ash.value)/6000,4) value
                         from (select date_trunc('minute', ts) ts, event_type, sum(events_count) value
                                      from $source_table_name
                                      where $where_timepoint $where_ext
                                      group by date_trunc('minute', ts), event_type) ash
                         group by ash.ts, ash.event_type) src1 ) src2 " ;
     }
#-debug-print "<BR>$request_chart_per_class<BR>" ;

    my $white_spaces = 100 - $percent ;
    my $count_class = 0 ;
#-debug-print "<BR>!!! pre sql ws = $white_spaces, prc = $percent<BR>" ;
    my $dbh_chart_per_class = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_chart_per_class = $dbh_chart_per_class->prepare($request_chart_per_class) ; $sth_chart_per_class->execute() ; $count_rows = 0 ;

#-debug-print "<BR>!!! execute sql<BR>" ;
    while (my ($wc_Activity, $wc_BufferPin, $wc_Client, $wc_Extension, $wc_IO, $wc_IPC, $wc_Lock, $wc_LWLock, $wc_Timeout, $wc_Other) = $sth_chart_per_class->fetchrow_array() ) {
          $count_class++ ;
          my $tmp_sum =  $wc_Activity + $wc_BufferPin + $wc_Client + $wc_Extension + $wc_IO + $wc_IPC + $wc_Lock + $wc_LWLock + $wc_Timeout + $wc_Other ;
#-debug-print "<BR>--$white_spaces -- $tmp_sum --" ;
#-debug-print "<BR>\n - class - tmp_sum $tmp_sum, queryid $query_id, time $begin_time, actSess $wc_ActiveSession, concurr $wc_Concurrency, userIO $wc_UserIO, systemIO $wc_SystemIO, other $wc_Other, config $wc_Configuration, sched $wc_Scheduler, cpu $wc_CPU, app $wc_Application, commit $wc_Commit, net $wc_Network, admin $wc_Administrative, clust $wc_Cluster\n" ;
          $wc_Activity = sprintf("%.1f", $wc_Activity * $percent / $tmp_sum) ;
          $wc_BufferPin = sprintf("%.1f", $wc_BufferPin * $percent / $tmp_sum) ;
          $wc_Client = sprintf("%.1f", $wc_Client * $percent / $tmp_sum) ;
          $wc_Extension = sprintf("%.1f", $wc_Extension  * $percent / $tmp_sum) ;
          $wc_IO = sprintf("%.1f", $wc_IO * $percent / $tmp_sum) ;
          $wc_IPC = sprintf("%.1f", $wc_IPC * $percent / $tmp_sum) ;
          $wc_Lock = sprintf("%.1f", $wc_Lock * $percent / $tmp_sum) ;
          $wc_LWLock = sprintf("%.1f", $wc_LWLock * $percent / $tmp_sum) ;
          $wc_Timeout = sprintf("%d", $wc_Timeout * $percent / $tmp_sum) ;
          $wc_Other = sprintf("%d", $wc_Other * $percent / $tmp_sum) ;
#-debug-print "<BR>\n - class - tmp_sum $tmp_sum, queryid $query_id, time $begin_time, actSess $wc_ActiveSession, concurr $wc_Concurrency, userIO $wc_UserIO, systemIO $wc_SystemIO, other $wc_Other, config $wc_Configuration, sched $wc_Scheduler, cpu $wc_CPU, app $wc_Application, commit $wc_Commit, net $wc_Network, admin $wc_Administrative, clust $wc_Cluster\n" ;
          print "<TABLE WIDTH=\"200pt;\" HEIGHT=\"15pt;\" CELLPADDING=\"0\" CELLSPACING=\"0\"><TR>" ;
          if ( $wc_Activity > 0 ) { print "<TD TITLE=\"Activity $wc_Activity\%\" STYLE=\"width: $wc_Activity\%; height: 15pt; background-color: lime;\">&nbsp;</TD>" ; }
          if ( $wc_BufferPin > 0 ) { print "<TD TITLE=\"BufferPin $wc_BufferPin\%\" STYLE=\"width: $wc_BufferPin\%; height: 15pt; background-color: pink;\">&nbsp;</TD>" ; }
          if ( $wc_Client > 0 ) { print "<TD TITLE=\"Client $wc_Client\%\" STYLE=\"width: $wc_Client\%; height: 15pt; background-color: cyan;\">&nbsp;</TD>" ; }
          if ( $wc_Extension > 0 ) { print "<TD TITLE=\"Extension $wc_Extension\%\" STYLE=\"width: $wc_Extension\%; height: 15pt; background-color: slateblue;\">&nbsp;</TD>" ; }
          if ( $wc_IO > 0 ) { print "<TD TITLE=\"IO $wc_IO\%\" STYLE=\"width: $wc_IO\%; height: 15pt; background-color: navy;\">&nbsp;</TD>" ; }
          if ( $wc_IPC > 0 ) { print "<TD TITLE=\"IPC $wc_IPC\%\" STYLE=\"width: $wc_IPC\%; height: 15pt; background-color: orange;\">&nbsp;</TD>" ; }
          if ( $wc_Lock > 0 ) { print "<TD TITLE=\"Lock $wc_Lock\%\" STYLE=\"width: $wc_Lock\%; height: 15pt; background-color: darkred;\">&nbsp;</TD>" ; }
          if ( $wc_LWLock > 0 ) { print "<TD TITLE=\"LWLock $wc_LWLock\%\" STYLE=\"width: $wc_LWLock\%; height: 15pt; background-color: red;\">&nbsp;</TD>" ; }
          if ( $wc_Timeout > 0 ) { print "<TD TITLE=\"Timeout $wc_Timeout\%\" STYLE=\"width: $wc_Timeout\%; height: 15pt; background-color: lightgray;\">&nbsp;</TD>" ; }
          if ( $wc_Other > 0 ) { print "<TD TITLE=\"Other $wc_Other\%\" STYLE=\"width: $wc_Other\%; height: 15pt; background-color: black;\">&nbsp;</TD>" ; }
          print "<TD STYLE=\"width: $white_spaces\%; height: 15pt; background-color: white;\">&nbsp;</TD>" ;
          print "</TR></TABLE>" ; }
    $sth_chart_per_class->finish() ;
    $dbh_chart_per_class->disconnect() ;
#-debug- for ($i=0;$i<=$count_rows;$i++) { print "$avg_data_source[0][$i] $avg_data_source[1][$i] $avg_data_source[2][$i] $avg_data_source[3][$i] $avg_data_source[4][$i] $avg_data_source[5][$i]\n" ; } exit 0 ;
#-debug-print "<BR>\n$request_chart_per_class" ;
    }

# ------------------------------------------------------
# [на основе WS - wait sampling extension]
# ------------------------------------------------------
sub print_wait_sampling_head_ash_graph() {
    $sz_current_date_short = `date "+%Y-%m-%d 00:00:00"` ;
    $sz_current_date = `date "+%Y-%m-%d 23:59:59"` ;
    $pv{period_from} = ( $pv{period_from} eq "" ) ? $sz_current_date_short : $pv{period_from} ;
    $pv{period_to} = ( $pv{period_to} eq "" ) ? $sz_current_date : $pv{period_to} ;
    if ($pv{ds_type} || $pv{ds_type} eq "undefined") { $pv{ds_type} = "DB" ; } my $is_ds_type_db = " CHECKED" ; my $is_ds_type_mem = "" ; if ($pv{ds_type} eq "MEM") { $is_ds_type_db = "" ; $is_ds_type_mem = " CHECKED" ; }
    $pv{serial} = "" ; $pv{plan_hash} = "NO in PG vanilla" ;
    $common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;

# onclick=\"renew_wait_sampling_db_status_page(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,$pv{page_part})\">&nbsp;&nbsp;обновить</SPAN>

    print "<TABLE STYLE=\"width: 100%\">
    <TR><TD STYLE=\"text-align: left;\">График&nbsp;с&nbsp;<INPUT VALUE=\"$pv{period_from}\" ID=\"id_period_date_start\" STYLE=\"width: 101pt;\"></TD>
        <TD STYLE=\"text-align: center;\">
            PID&nbsp;<INPUT VALUE=\"$pv{pid}\" ID=\"id_pid\" STYLE=\"width: 49pt;\">&nbsp;
            P_START&nbsp;<INPUT VALUE=\"$pv{serial}\" ID=\"id_serial\" STYLE=\"width: 79pt;\">&nbsp;&nbsp;
            QUERY_ID&nbsp;<INPUT VALUE=\"$pv{query_id}\" ID=\"id_query_id\" STYLE=\"width: 101pt;\">&nbsp;
            PLAN&nbsp;<INPUT VALUE=\"$pv{plan_hash}\" ID=\"id_plan_hash\" STYLE=\"width: 79pt;\" DISABLED>&nbsp;
        </TD>
        <TD STYLE=\"text-align: right;\">График&nbsp;по&nbsp;<INPUT VALUE=\"$pv{period_to}\" ID=\"id_period_date_stop\" STYLE=\"width: 101pt;\">
           &nbsp;<INPUT TITLE=\"Смотреть данные в таблице агрегации\" TYPE=\"radio\" NAME=\"ds_type\" ID=\"id_ds_type\" VALUE=\"DB\" $is_ds_type_db>DB</INPUT>
           &nbsp;<INPUT TITLE=\"Смотреть данные в структурах памяти\" TYPE=\"radio\" NAME=\"ds_type\" ID=\"id_ds_type\" VALUE=\"MEM\" $is_ds_type_mem>Mem</INPUT>
           &nbsp; <SPAN STYLE=\"font-size: 11pt; color: navy; pointer: arrow;\"
                  onclick=\"renew_db_status_page(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,id_sess_state_filter.value,id_db_filter.value,id_is_user_backends.checked,id_is_backgrounds.checked,id_is_extensions.checked,'$pv{tab_detail}',id_curr_conn.value,id_refresh_time.value,'$pv{sort_field}','&x=x')\">
                  &nbsp;&nbsp;обновить</SPAN>
        </TD></TR>
    <TR><TD COLSPAN=\"3\">
    <A TARGET=\"_blank\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_WS_top_activity.cgi?$common_pg_mon_cgi_prefix&width=1450&height=500\">
           <IMG style=\"width:100%; height: 240pt;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_pg_WS_top_activity.cgi?$common_pg_mon_cgi_prefix&width=2800&height=600\"></A>
    </TD></TR>
    </TABLE>" ;
    }

# ------------------------------------------------------
# [на основе WS - wait sampling extension]
# ------------------------------------------------------
sub print_wait_sampling_sql_table_activity($$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ;
    my $source_table_name = "pg_wait_sampling_history" ; if ($pv{ds_type} eq "DB") { $source_table_name = "bestat_ws_history" ; }
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $filter_period_from eq "" ||  $filter_period_to eq "" ) { die ; }
    $where_timepoint .= " ts >= TO_TIMESTAMP('$filter_period_from','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND ts <= TO_TIMESTAMP('$filter_period_to','YYYY-MM-DD HH24:MI:SS')" ;
    if ( $filter_query_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " QUERYID = '$filter_query_id'" ; }
    if ( $filter_sql_plan_hash_value ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_session_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_ID = '$filter_session_id'" ; }
    if ( $filter_session_serial ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_SERIAL# = '$filter_session_serial'" ; }
    if ( $where_ext ne "" ) { $where_ext = " AND $where_ext" ; }
    print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">
        <TR><TD>WS Activity Query</TD><TD>%</TD><TD>Query ID [plan count]</TD><TD>Query</TD></TR>" ;
    if ($pv{ds_type} eq "MEM") {
       $request_top_sql = "select * from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.queryid
              from (select 'ok' ok1, count(*) count_point, queryid
                           from $source_table_name
                           where $where_timepoint $where_ext
                           group by queryid) a1,
                   (select 'ok' ok1, count(*) sum_count_point
                           from $source_table_name
                           where $where_timepoint $where_ext) a2
               where a1.ok1 = a2.ok1
               order by 1 desc) ds_1 LIMIT 30" ;
       }
    if ($pv{ds_type} eq "DB") {
       $request_top_sql = "select * from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.queryid
              from (select 'ok' ok1, sum(events_count) count_point, queryid
                           from $source_table_name
                           where $where_timepoint $where_ext
                           group by queryid) a1,
                   (select 'ok' ok1, sum(events_count) sum_count_point
                           from $source_table_name
                           where $where_timepoint $where_ext) a2
               where a1.ok1 = a2.ok1
               order by 1 desc) ds_1 LIMIT 30" ;
       }
#open(DEBG,">/tmp/print_sess_table_activity.out") ; print DEBG $request_top_sql ;
#-debug-print "<BR>ds_type = $pv{ds_type} == $request_top_sql<BR>" ;
    my $dbh_top_sql = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_top_sql  = $dbh_top_sql->prepare($request_top_sql ) ; $sth_top_sql->execute() ;
    while (my ( $percent, $query_id, $count_point ) = $sth_top_sql->fetchrow_array() ) {
          print "<TR><TD>" ;
          print_wait_sampling_activity_graph($pv{period_from}, $pv{period_to}, $query_id, '', '', '', $percent, $source_table_name) ;

          if ( $query_id eq "" ) { $query_id = "NULL" ; }
          my $curr_query_text_substr = "" ; my $curr_count_query_text_substr = 0 ;
          my $request_curr_query_text_substr = "select substr(query,1,30) from bestat_qyery_text where queryid = $query_id" ;
          my $dbh_curr_query_text_substr = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
          my $sth_curr_query_text_substr  = $dbh_curr_query_text_substr->prepare($request_curr_query_text_substr ) ; $sth_curr_query_text_substr->execute() ;
          while (my ($res_curr_query_text_substr) = $sth_curr_query_text_substr->fetchrow_array()) { $curr_count_query_text_substr++ ; $curr_query_text_substr = $res_curr_query_text_substr ; }
          if ( $curr_query_text_substr eq "" || $curr_count_query_text_substr == 0 ) {
             $sth_curr_query_text_substr->finish() ;
             $request_curr_query_text_substr = "select substr(query,1,30) from pg_stat_activity where query_id = $query_id" ;
             $sth_curr_query_text_substr  = $dbh_curr_query_text_substr->prepare($request_curr_query_text_substr ) ; $sth_curr_query_text_substr->execute() ; ($curr_query_text_substr) = $sth_curr_query_text_substr->fetchrow_array() ;
             }
          $sth_curr_query_text_substr->finish() ; $dbh_curr_query_text_substr->disconnect() ;

          $common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;
          print "</TD><TD STYLE=\"text-align: right; font-size: 10pt;\">$percent</TD>
                 <TD><A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?$common_pg_mon_cgi_prefix&page_part=1&srcptr=&child_number=\">$query_id</A></TD><TD>$curr_query_text_substr ...</TD></TR>" ;
          }
    $sth_top_sql->finish() ;
    $dbh_top_sql->disconnect() ;
    print "</TABLE>" ;
    }

# ------------------------------------------------------
# [на основе WS - wait sampling extension]
# ------------------------------------------------------
sub print_wait_sampling_session_table_activity($$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ;
    my $source_table_name = "pg_wait_sampling_history" ; if ($pv{ds_type} eq "DB") { $source_table_name = "bestat_ws_history" ; }
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $filter_period_from eq "" ||  $filter_period_to eq "" ) { die ; }
    $where_timepoint .= " ts >= TO_TIMESTAMP('$filter_period_from','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND ts <= TO_TIMESTAMP('$filter_period_to','YYYY-MM-DD HH24:MI:SS')" ;
    if ( $filter_query_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " QUERYID = '$filter_query_id'" ; }
    if ( $filter_sql_plan_hash_value ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_session_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_ID = '$filter_session_id'" ; }
    if ( $filter_session_serial ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_SERIAL# = '$filter_session_serial'" ; }
    if ( $where_ext ne "" ) { $where_ext = " AND $where_ext" ; }
    print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">
            <TR><TD>WS Activity Session</TD><TD>%</TD><TD>Process ID</TD><TD>---</TD><TD>---</TD></TR>";
    if ($pv{ds_type} eq "MEM") {
       $request_top_sess = "select * from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.pid
              from (select 'ok' ok1, count(*) count_point, pid pid
                           from $source_table_name
                           where $where_timepoint $where_ext
                           group by pid) a1,
                   (select 'ok' ok1, count(*) sum_count_point
                           from $source_table_name
                           where $where_timepoint $where_ext) a2
               where a1.ok1 = a2.ok1
               order by 1 desc) ds_1 LIMIT 30" ;
       }
    if ($pv{ds_type} eq "DB") {
       $request_top_sess = "select * from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.pid
              from (select 'ok' ok1, sum(events_count) count_point, pid pid
                           from $source_table_name
                           where $where_timepoint $where_ext
                           group by pid) a1,
                   (select 'ok' ok1, sum(events_count) sum_count_point
                           from $source_table_name
                           where $where_timepoint $where_ext) a2
               where a1.ok1 = a2.ok1
               order by 1 desc) ds_1 LIMIT 30" ;
       }
#-debug-print "<BR>$request_top_sess <BR>" ;
#open(DEBG,">/tmp/print_pid_table_activity.out") ; print DEBG $request_top_sess ;
    my $dbh_top_sess = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
    my $sth_top_sess  = $dbh_top_sess ->prepare($request_top_sess ) ; $sth_top_sess->execute() ;
    while (my ( $percent, $pid, $serial, $user_id, $user_name ) = $sth_top_sess->fetchrow_array() ) {
          print "<TR><TD>" ;
          print_wait_sampling_activity_graph($pv{period_from}, $pv{period_to}, '', '', $pid, $serial, $percent, $source_table_name) ;
          $common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;
          print "</TD><TD>$percent</TD>
                     <TD><A HREF=\"$COMM_PAR_BASE_HREF/cgi/get_session_info.cgi?$common_pg_mon_cgi_prefix&page_part=1\">$pid</A></TD>
                     <TD TITLE=\"User ID: $user_id\">$user_name</TD><TD>&nbsp;</TD></TR>" ;
          }
    $sth_top_sess->finish() ;
    $dbh_top_sess->disconnect() ;
    print "</TABLE>" ;
    }


# ------------------------------------------------------
# [на основе WS - wait sampling extension]
# ------------------------------------------------------
sub print_wait_sampling_events($$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ;
    my $source_table_name = "pg_wait_sampling_history" ; if ($pv{ds_type} eq "DB") { $source_table_name = "bestat_ws_history" ; }
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $filter_period_from eq "" ||  $filter_period_to eq "" ) { die ; }
    $where_timepoint .= " ts >= TO_TIMESTAMP('$filter_period_from','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND ts <= TO_TIMESTAMP('$filter_period_to','YYYY-MM-DD HH24:MI:SS')" ;
    if ( $filter_query_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } if ( $filter_query_id ne "NULL" && $filter_query_id != 0 ) { $where_ext .= " QUERYID = $filter_query_id" ; } else { $where_ext .= " QUERYID IS NULL or QUERYID = 0 " ; } }
    if ( $filter_sql_plan_hash_value ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_session_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_ID = '$filter_session_id'" ; }
    if ( $filter_session_serial ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_SERIAL# = '$filter_session_serial'" ; }
    if ( $where_ext ne "" ) { $where_ext = " AND $where_ext" ; }

  print "<TABLE BORDER=\"1\" WIDTH=\"100%\">
                 <TR><TD CLASS=\"td_waits_head\">Activity [pg_wait_sampling]</TD><TD CLASS=\"td_waits_head\">%</TD><TD CLASS=\"td_waits_head\">count</TD><TD CLASS=\"td_waits_head\">Wait Event Type</TD><TD CLASS=\"td_waits_head\">Wait Event</TD></TR>\n" ;
  $request_query_per_wait_stats = "" ;
  if ($source_table_name eq "pg_wait_sampling_history") {
     $request_query_per_wait_stats = "select a1.event_type, a1.event, a1.ev_count, round((a1.ev_count::numeric  * 100 / a2.all_count),2) event_percent
                                             from ( select event_type, event, count(*) ev_count
                                                           from $source_table_name
                                                           where  $where_timepoint $where_ext
                                                           group by event_type, event) a1,
                                                  ( select count(*) all_count
                                                           from $source_table_name
                                                           where $where_timepoint $where_ext) a2
                                             order by a1.ev_count desc " ;
     }
  if ($source_table_name eq "bestat_ws_history") {
     $request_query_per_wait_stats = "select a1.event_type, a1.event, a1.ev_count, round((a1.ev_count::numeric  * 100 / a2.all_count),2) event_percent
                                             from ( select event_type, event, sum(events_count) ev_count
                                                           from $source_table_name
                                                           where $where_timepoint $where_ext
                                                           group by event_type, event) a1,
                                                  ( select sum(events_count) all_count
                                                           from $source_table_name
                                                           where $where_timepoint $where_ext) a2
                                             order by a1.ev_count desc " ;
     }
#-debug-print "<PRE>$request_query_per_wait_stats</PRE>" ;
     $count_rows_query_per_wait_stats = 0 ;
     my $dbh_query_per_wait_stats = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
     my $sth_query_per_wait_stats = $dbh_query_per_wait_stats->prepare($request_query_per_wait_stats) ; $sth_query_per_wait_stats->execute() ;
     while ( ($wait_event_type,$wait_event,$wait_event_count, $event_percent) = $sth_query_per_wait_stats->fetchrow_array() ) {
           $count_rows_query_per_wait_stats++ ;
           $white_spaces = 100 - $event_percent ;
           print "<TR><TD CLASS=\"td_waits_right\" TITLE=\"#: $count_rows_query_per_wait_stats, count: $wait_event_count\">" ;
           print "<TABLE WIDTH=\"200pt;\" HEIGHT=\"8pt;\" CELLPADDING=\"0\" CELLSPACING=\"0\"><TR>" ;
           if ( $wait_event_type eq "" && $wait_event eq "" ) { print "<TD TITLE=\"CPU Active $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: darkgreen;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Activity" ) { print "<TD TITLE=\"Activity::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: lime;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "BufferPin" ) { print "<TD TITLE=\"BufferPin::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: pink;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Client" ) { print "<TD TITLE=\"Client::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: cyan;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Extension" ) { print "<TD TITLE=\"Extension::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: slateblue;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "IO" ) { print "<TD TITLE=\"IO::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: navy;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "IPC" ) { print "<TD TITLE=\"IPC::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: orange;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Lock" ) { print "<TD TITLE=\"Lock::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: darkred;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "LWLock" ) { print "<TD TITLE=\"LWLock::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: red;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Timeout" ) { print "<TD TITLE=\"Timeout::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: lightgray;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Other" ) { print "<TD TITLE=\"Other::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: black;\">&nbsp;</TD>" ; }
           print "<TD STYLE=\"width: $white_spaces\%; height: 15pt; background-color: white;\">&nbsp;</TD>" ;
           print "</TR></TABLE>" ;
           print "</TD><TD CLASS=\"td_waits_right\">$event_percent</TD><TD CLASS=\"td_waits_right\">$wait_event_count</TD><TD CLASS=\"td_waits_left\">$wait_event_type</TD><TD CLASS=\"td_waits_left\">$wait_event</TD></TR>\n" ;
           }
     $sth_query_per_wait_stats->finish() ;
     $dbh_query_per_wait_stats->disconnect() ;
     print "</TABLE>" ;
    }

sub print_foother1() {
    print "<BR><HR><P STYLE=\"text-align: center; font-size: 8pt;\">
<A CLASS=\"small_size\" TARGET=\"_blank\" HREF=\"http://www.ourorbits.org/cosiculs/index.shtml\">CoSiCULS BeSSt v.1.6.,(С) Belonin S.S., 2006</A> -
<A CLASS=\"small_size\" TARGET=\"_blank\" HREF=\"http://www.ourorbits.org/orsimon/info/about.shtml\">OrSiMon BeSSt v.2.0, (C) Belonin S.S., 2010</A> - 
<A CLASS=\"small_size\" TARGET=\"_blank\" HREF=\"http://www.ourorbits.org/crypta/articles/our_ptk_kragran_besst.shtml\">CrAgrAn BeSSt v.1.3, (C) Belonin S.S., 2023</A> - 
<A CLASS=\"small_size\" TARGET=\"_blank\" HREF=\"http://www.ourorbits.org/kamactsost/index.shtml\">CAMActSoSt BeSSt v.1.0, (С) Belonin S.S., 2025</A></P>
           </BODY>
           </HTML>" ;
    }

sub print_header_1_1_cgi() {
    print "<!doctype html>
<HTML>
<HEAD>
<TITLE>" ;
    }

sub print_header_1_2_cgi() {
    print "</TITLE>
<META HTTP-EQUIV=Content-Type content=\"text.html; charset=utf-8\">
<META HTTP-EQUIV=Content-Script-Type content=\"text/javascript\">
<META HTTP-EQUIV=\"Style-Type\" content=\"text/css\">
<BASE HREF=\"$COMM_PAR_BASE_HREF/\">
<LINK REL=STYLESHEET HREF=\"$COMM_PAR_BASE_HREF/css/common.css\">
<LINK REL=\"shortcut icon\" HREF=\"img/shortcut_icon_girudo_01.jpg\" TYPE=\"image/jpeg\">
<META HTTP-EQUIV=\"Cache-Control\" content=\"no-cache, no-store, max-age=0, must-revalidate\">
<META HTTP-EQUIV=\"Pragma\" content=\"no-cache\">
<META HTTP-EQUIV=\"Expires\" content=\"Fri, 01 Jan 1990 00:00:00 GMT\">
<META HTTP_EQUIV=\"CONTENT-TYPE\" CONTENT=\"text/html; charset=utf-8\">" ;

    my $script_name = $0 ; $script_name =~ s/.*\/([^\/]+)/$1/g ;
#    my $common_pg_mon_cgi_prefix = "period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&dbid=$pv{dbid}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&ds_type=$pv{ds_type}&curr_conn=$pv{curr_conn}&refresh_time=$pv{refresh_time}&sort_field=$pv{sort_field}" ;
#    my $common_pg_mon_cgi_prefix = "" ;
$common_pg_mon_cgi_prefix = "" ; set_common_pg_mon_cgi_prefix() ;
#    if ( $pv{refresh_time} ne "" ) { print "\n<meta http-equiv=\"refresh\" content=\"$pv{refresh_time};url=$base_url/cgi/$script_name?$common_pg_mon_cgi_prefix&tab_detail=$pv{tab_detail}\">" ; }
    if ( $pv{refresh_time} ne "" ) { print "\n<meta http-equiv=\"refresh\" content=\"$pv{refresh_time};url=$COMM_PAR_BASE_HREF/cgi/$script_name?$common_pg_mon_cgi_prefix&tab_detail=$pv{tab_detail}\">" ; }
    print "</HEAD>

<BODY>
<TABLE border=\"0\" cellspacing=\"0\" cellpadding=\"10\" width=\"100%\">
<TR>
<TD width=\"10%\" STYLE=\"vertical-align: top; align: left;\">" ;
    }

sub print_header_2_1_cgi() {
    print "</TD>
<TD width=\"3%\" align=\"left\">&nbsp;&nbsp;&nbsp;</TD>
<TD width=\"77%\" valign=\"top\" align=\"left\">" ;
    }

sub print_main_page_title($$) { $title_part_01 = $_[0] ; $title_part_02 = $_[1] ;
    my $curr_timepoint = `date "+%Y-%m-%d %H:%M:%S"` ; $file_name = $0 ; $file_name =~ s/.*\/([^\/]+)/$1/g ;
    print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border-width: solid; border-color: navy;\">
           <TR><TD>
               <TABLE BORDER=\"0\" STYLE=\"width: 100%; border-width: solid; border-color: navy;\">
               <TR><TD>" ;
    print "        <TABLE BORDER=\"0\" STYLE=\"width: 270pt%; border-width: solid; border-color: navy;\">" ;

    if ( $file_name =~ /tools_coin_.+/ ) {
       print "        <TR><TD STYLE=\"color: navy;\">трэйдер:&nbsp;</TD><TD>
                      <SELECT ID=\"id_user_name\" NAME=\"user_name\" STYLE=\"width: 170pt; color: navy;\" TITLE=\"выставляется через Cookie\">
                              <OPTION VALUE=\"none\">учитывать всех</OPTION>
                              <OPTION VALUE=\"Nadya\">Nadya</OPTION>
                              <OPTION VALUE=\"Serjie\">Serjie</OPTION>
                      </SELECT>
                      </TD></TR>" ; }

    print "                   </TABLE>
                   </TD>
                   <TD>&nbsp;</TD>
                   <TD>
                   <P STYLE=\"text-align: right;\"><SPAN STYLE=\"text-align: right; font-family: sans-serif; color: navy; font-size: 17pt; font-weight: bold;\">$title_part_01</SPAN> 
                                                   <SPAN STYLE=\"text-align: right; font-family: sans-serif; color: green; font-size: 17pt; font-weight: bold;\">$title_part_02</SPAN>&nbsp;
                   <BR><SPAN STYLE=\"text-align: right; font-family: sans-serif; color: navy; font-size: 10pt; font-weight: normal;\">$curr_timepoint</SPAN>&nbsp;</P>
                   </TD></TR>
               </TABLE>
           </TD></TR></TABLE><BR>" ;
    }  

1

