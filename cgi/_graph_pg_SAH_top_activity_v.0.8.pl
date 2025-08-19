#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
#use Chart::Lines ;
#use Chart::StackedBars ;
#use Chart::Composite ;
require "/var/www/camactsost/cgi/common_parameter.camactsost" ;
require "$camactsost_dir_lib/lib_common_func.pl" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;
#$COMM_PAR_PGSQL_DB_NAME = $pv{db_name} ;

#-debug-$pv{period_from} = "2024-05-02 00:00:00" ; $pv{period_to} = "2025-06-03 00:00:00" ; $pv{ds_type} = "MEM" ; $pv{width} = 1500 ; $pv{height} = 700 ;

print "Content-Type: image/png\n\n";
$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$request = " " ;
my $count_rows = 0 ;
my $count_rows_post = 0 ;

my $source_table_name = "bestat_sa_history" ;
my $where_timepoint = "" ;
my $where_ext = "" ;
if ( $pv{period_from} eq "" ||  $pv{period_to} eq "" ) { die ; }
$where_timepoint .= " sampling_time >= TO_TIMESTAMP('$pv{period_from}','YYYY-MM-DD HH24:MI:SS') " ;
$where_timepoint .= " AND sampling_time <= TO_TIMESTAMP('$pv{period_to}','YYYY-MM-DD HH24:MI:SS')" ;

#&sess_state_filter=all_states&is_user_backends=true&is_backgrounds=true&is_extensions=true

if ( $pv{query_id} ne "" ) { if ( $pv{query_id} ne "NULL" ) { $where_ext .= " AND query_id = '$pv{query_id}'" ; } else { $where_ext .= " AND query_id IS NULL" ; } }
if ( $pv{pid} ne "" ) { $where_ext .= " AND pid = '$pv{pid}'" ; }
# кластерные процессы не имеют установленного dbid, в их записях NULL
if ( $pv{dbid} ne "" && $pv{dbid} ne "all" && $pv{dbid} ne "all_db" ) { if ( $pv{dbid} ne "null" ) { $where_ext .= " AND datid = ($pv{dbid})::oid " ; } else { $where_ext .= " AND datid IS NULL " ; } }
if ( $pv{sess_state_filter} ne "" && $pv{sess_state_filter} ne "all_states" ) { 
   if ( $pv{sess_state_filter} eq "active" ) { $where_ext .= " AND state = 'active' " ; } 
   if ( $pv{sess_state_filter} eq "all_idle" || $pv{sess_state_filter} eq "idle" ) { $where_ext .= " AND state LIKE '%idle%' " ; } 
   if ( $pv{sess_state_filter} eq "idle_trns" ) { $where_ext .= " AND state = 'idle transaction' " ; } 
   if ( $pv{sess_state_filter} eq "idle_tabrt" ) { $where_ext .= " AND state = 'idle transaction break' " ; } 
   if ( $pv{sess_state_filter} eq "disabled" ) { $where_ext .= " AND state = 'disables' " ; } 
   }
if ( $pv{is_backgrounds} ne "true" ) { $where_ext .= " AND state IS NOT NULL " ; }
if ( $pv{is_user_backends} ne "true" ) { $where_ext .= " AND usename IS NULL " ; }
if ( $pv{is_extensions} ne "true" ) { $where_ext .= " AND (wait_event_type IS NULL or NOT wait_event_type = 'Extension' ) " ; }

# - не забываем, что мы должны показать всю временную шкалу и активность по выбранным элементам
# - поэтому дополнительные WHERE выражения добавляем только во второй источник
   $request = "
select TO_CHAR(src2.sampling_time,'  YYYY-MM-DD HH24:MI '), sum(src2.wc_CPU_Active) wc_CPU_Active, sum(src2.wc_Activity) wc_Activity, sum(src2.wc_BufferPin) wc_BufferPin,
       sum(src2.wc_Client) wc_Client, sum(src2.wc_Extension) wc_Extension, sum(src2.wc_IO) wc_IO, sum(src2.wc_IPC) wc_IPC, sum(src2.wc_Lock) wc_Lock, sum(src2.wc_LWLock) wc_LWLock,
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
            from (select ash_all_time.sampling_time sampling_time,
                         CASE WHEN ash.wait_event_type IS NULL THEN 'CPU Active' ELSE ash.wait_event_type END wait_event_type,
                         CASE WHEN round(sum(ash.value)/60,4) IS NULL THEN 0 ELSE round(sum(ash.value)/60,4) END value
                         from (select distinct date_trunc('minute', st::timestamp) sampling_time
                                      from generate_series('$pv{period_from}'::timestamp,
                                      (CASE WHEN NOW() < TO_TIMESTAMP('$pv{period_to}','YYYY-MM-DD HH24:MI:SS') 
                                            THEN TO_CHAR (NOW() + INTERVAL '3 minutes','YYYY-MM-DD HH24:MI:SS')
                                            ELSE '$pv{period_to}' END)::timestamp, interval '1 minute') as st ORDER BY sampling_time ASC) ash_all_time
                              left outer join
                              (select date_trunc('minute', sampling_time) sampling_time, wait_event_type, count(*) value
                                      from $source_table_name
                                      where $where_timepoint $where_ext
                                      group by date_trunc('minute', sampling_time), wait_event_type) ash
                              on ash_all_time.sampling_time = ash.sampling_time
                         group by ash_all_time.sampling_time, ash.wait_event_type) src1 ) src2
       group by src2.sampling_time
       order by src2.sampling_time asc" ;

#-debug-
open(DEBG, ">/tmp/_graph_pg_SAH_top_activity.out") ; print DEBG $request ;
# exit 0 ;
my $dbh_h = DBI->connect($conn_def{$pv{curr_conn}}, $conn_cred_name{$pv{curr_conn}}, $conn_cred_passwd{$pv{curr_conn}}) ;
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;
while (my ($sampling_time, $wc_CPU_Active, $wc_Activity, $wc_BufferPin, $wc_Client, $wc_Extension, $wc_IO, $wc_IPC, $wc_Lock, $wc_LWLock, $wc_Timeout, $wc_Other) = $sth_h->fetchrow_array() ) {
      if ( $wc_CPU_Active =~/^\..*/) { $wc_CPU_Active = "0" . $wc_CPU_Active ; }
      if ( $wc_Activity =~/^\..*/) { $wc_Activity = "0" . $wc_Activity ; }
      if ( $wc_wc_BufferPin =~/^\..*/) { $wc_BufferPin = "0" . $wc_BufferPin ; }
      if ( $wc_Client =~/^\..*/) { $wc_Client = "0" . $wc_Client ; }
      if ( $wc_Extension =~/^\..*/) { $wc_Extension = "0" . $wc_Extension ; }
      if ( $wc_IO =~/^\..*/) { $wc_IO = "0" . $wc_IO ; }
      if ( $wc_IPC =~/^\..*/) { $wc_IPC = "0" . $wc_IPC ; }
      if ( $wc_Lock =~/^\..*/) { $wc_Lock = "0" . $wc_Lock ; }
      if ( $wc_LWLock =~/^\..*/) { $wc_LWLock = "0" . $wc_LWLock ; }
      if ( $wc_Timeout =~/^\..*/) { $wc_Timeout = "0" . $wc_Timeout ; }
      if ( $wc_Other =~/^\..*/) { $wc_Other = "0" . $wc_Other ; }
# - меняем очерёдность на аналогичную вкладке CloudControl
      $avg_data_source[0][$count_rows] = $sampling_time ;
      $avg_data_source[1][$count_rows] = $wc_CPU_Active ;
      $avg_data_source[2][$count_rows] = $wc_Activity ;
      $avg_data_source[3][$count_rows] = $wc_BufferPin ;
      $avg_data_source[4][$count_rows] = $wc_Client ;
      $avg_data_source[5][$count_rows] = $wc_Extension ;
      $avg_data_source[6][$count_rows] = $wc_IO ;
      $avg_data_source[7][$count_rows] = $wc_IPC ;
      $avg_data_source[8][$count_rows] = $wc_Lock ;
      $avg_data_source[9][$count_rows] = $wc_LWLock ;
      $avg_data_source[10][$count_rows] = $wc_Timeout ;
      $avg_data_source[11][$count_rows] = $wc_Other ;
      $count_rows += 1 ; }
$sth_h->finish() ;
$dbh_h->disconnect() ;
#-debug- for ($i=0;$i<=$count_rows;$i++) { print "$avg_data_source[0][$i] $avg_data_source[1][$i] $avg_data_source[2][$i] $avg_data_source[3][$i] $avg_data_source[4][$i] $avg_data_source[5][$i]\n" ; } exit 0 ;

# --------- заполнить данные для построения графика
$dbh = DBI->connect('dbi:Chart:') or die "Cannot connect: " . $DBI::errstr ;
$dbh->do('CREATE TABLE mychart (sampling_time VARCHAR(30), CPU FLOAT, BGActive FLOAT, BuffPin FLOAT, Client FLOAT, Extension FLOAT, IO FLOAT, IPC FLOAT, Lock FLOAT, LWLock FLOAT, Timeout FLOAT)') or die $dbh->errstr;
#, Other FLOAT
for ($i=0;$i<$count_rows;$i++) {
    $sth = $dbh->prepare('INSERT INTO mychart VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
    $sth->bind_param(1, "$avg_data_source[0][$i]");
    $sth->bind_param(2, $avg_data_source[1][$i]);
    $sth->bind_param(3, $avg_data_source[2][$i]);
    $sth->bind_param(4, $avg_data_source[3][$i]);
    $sth->bind_param(5, $avg_data_source[4][$i]);
    $sth->bind_param(6, $avg_data_source[5][$i]);
    $sth->bind_param(7, $avg_data_source[6][$i]);
    $sth->bind_param(8, $avg_data_source[7][$i]);
    $sth->bind_param(9, $avg_data_source[8][$i]);
    $sth->bind_param(10, $avg_data_source[9][$i]);
    $sth->bind_param(11, $avg_data_source[10][$i]);
    $sth->execute or die 'Cannot execute: ' . $sth->errstr;
    }

$chart_select = "SELECT AREAGRAPH FROM mychart WHERE WIDTH=$pv{width} AND HEIGHT=$pv{height} AND X_AXIS='Time' and Y_AXIS='Active session' AND CUMULATIVE='1' AND
                        TITLE = 'Top activity for SAH on DB ''$COMM_PAR_PGSQL_DB_NAME'' from $pv{period_from} to $pv{period_to}'  AND X_ORIENT='VERTICAL' AND SIGNATURE = '(C)1974 - $CURR_YEAR, Sergey S. Belonin' AND
                        COLOR IN ('dgreen','lgreen','dpink','cyan','marine','dblue','orange','dred','lred','lgray') AND TEXTCOLOR = 'blue' AND FORMAT='PNG'" ;

$sth = $dbh->prepare($chart_select) ;
$sth->execute or die 'Cannot execute: ' . $sth->errstr;
@row = $sth->fetchrow_array; print $row[0];
