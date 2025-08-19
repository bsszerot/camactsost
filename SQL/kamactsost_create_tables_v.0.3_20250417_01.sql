
-- --- содержимое текущей версии --- ---
-- 1.01 -- блок сбора ASH статистик
-- 1.02 -- блок AWR сбора статистики PGMonitor

insert into curr_pair_history (currency, reference_currency, day_date, price_open, price_max, price_min, price_close, volume_from, volume_to)
       values () ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.01 начало -- таблица агрегации данных OHLC от GECKO  обвязка -- curr_pair_history ;
-- ---------------------------------------------------------------------------------------------------------------------------

-- таблица для сохранения посекундной агрегации из wait sampling взамен устаревшей besst_stat_ash_history
CREATE TABLE IF NOT EXISTS public.bestat_ws_history (
       ts           timestamp with time zone,
       pid          integer,
       event_type   text,
       event        text,
       queryid      bigint,
       events_count bigint ) ;

CREATE INDEX IF NOT EXISTS bestat_ws_history_idx_on_ts_01 ON public.bestat_ws_history (ts) ;
CREATE INDEX IF NOT EXISTS bestat_ws_history_idx_on_ts_eventtype_01 ON public.bestat_ws_history (ts, event_type) ;

CREATE OR REPLACE PROCEDURE public.bestat_fill_ws_history()
       LANGUAGE 'plpgsql'
       AS $BODY$
begin
MERGE INTO public.bestat_ws_history bswsh
      USING (select date_trunc('second',ts) ts, pid, event_type, event, queryid, count(*) events_count
                    from public.pg_wait_sampling_history
                    group by date_trunc('second',ts), pid, event_type, event, queryid
                    order by date_trunc('second',ts), pid, event_type, event, queryid) pwsh
      ON bswsh.pid = pwsh.pid AND bswsh.ts = pwsh.ts AND bswsh.event_type = pwsh.event_type
         AND bswsh.event = pwsh.event AND bswsh.queryid = pwsh.queryid
      WHEN NOT MATCHED THEN
           INSERT (ts, pid, event_type, event, queryid, events_count)
                  VALUES (pwsh.ts, pwsh.pid, pwsh.event_type, pwsh.event, pwsh.queryid, pwsh.events_count) ;
end ;
$BODY$;

CALL bestat_fill_ws_history() ;
select * from bestat_ws_history ;
delete from bestat_ws_history ;
commit ;

-- DROP TABLE IF EXISTS public.bestat_sa_history;
CREATE TABLE IF NOT EXISTS public.bestat_sa_history(
       sampling_time timestamp with time zone,
       datid oid,
       datname name,
       pid integer,
       leader_pid integer,
       usesysid oid,
       usename name,
       application_name text,
       client_addr inet,
       client_hostname text,
       client_port integer,
       backend_start timestamp with time zone,
       xact_start timestamp with time zone,
       query_start timestamp with time zone,
       state_change timestamp with time zone,
       wait_event_type text,
       wait_event text,
       state text,
       backend_xid xid,
       backend_xmin xid,
       query_id bigint,
       backend_type text) TABLESPACE pg_default ;

-- DROP INDEX IF EXISTS public.bestat_sa_history_idx_on_st_01;
CREATE INDEX IF NOT EXISTS bestat_sa_history_idx_on_st_01 ON public.bestat_sa_history USING btree (sampling_time ASC NULLS LAST) TABLESPACE pg_default ;

-- DROP INDEX IF EXISTS public.bestat_sa_history_idx_on_st_wet_01;
CREATE INDEX IF NOT EXISTS bestat_sa_history_idx_on_st_wet_01 ON public.bestat_sa_history USING btree (sampling_time ASC NULLS LAST, wait_event_type COLLATE pg_catalog."default" ASC NULLS LAST) TABLESPACE pg_default ;

-- DROP TABLE IF EXISTS public.bestat_sa_history_parameters;
CREATE TABLE IF NOT EXISTS public.bestat_sa_history_parameters(
       sz_parameter character varying,
       sz_value character varying
       ) TABLESPACE pg_default ;

-- DROP PROCEDURE IF EXISTS public.bestat_fill_sa_history(integer);
CREATE OR REPLACE PROCEDURE public.bestat_fill_sa_history(
    IN v_iteration integer)
LANGUAGE 'plpgsql'
AS $BODY$
declare
v_Count INTEGER ;
sz_is_collect VARCHAR ;
v_insert_timestamp TIMESTAMP ;
begin
v_Count := 0 ;
while (v_Count < v_Iteration) LOOP
      if (v_Count = (v_Iteration - 1)) then
         commit ;
         select sz_value into sz_is_collect from bestat_sa_history_parameters where sz_parameter = 'is_collect' ;
         if sz_is_collect = 'yes' then v_Count := 0 ;
            else v_count := v_Iteration + 10 ;
            end if ;
         end if ;
      v_insert_timestamp := clock_timestamp() ;
      insert into bestat_sa_history
             (SELECT v_insert_timestamp, datid, datname, pid, leader_pid, usesysid, usename,
                     application_name, client_addr, client_hostname, client_port, backend_start, xact_start,
                     query_start, state_change, wait_event_type, wait_event, state, backend_xid, backend_xmin,
                     query_id, backend_type
                     from pg_stat_activity) ;
      v_Count = v_Count + 1 ;
      perform pg_sleep(1) ;
      end LOOP ;
end ;
$BODY$;
ALTER PROCEDURE public.bestat_fill_sa_history(integer)
    OWNER TO crypta;

-----------------
-- устаревшие ---
-----------------


-- таблицы моего SAH-агрегатора (stats activity history)
-- DROP TABLE IF EXISTS public.bestat_sah;
CREATE TABLE IF NOT EXISTS public.bestat_sah (
    sampling_time timestamp with time zone,
    datid oid,
    datname name COLLATE pg_catalog."C",
    pid integer,
    leader_pid integer,
    usesysid oid,
    usename name COLLATE pg_catalog."C",
    application_name text COLLATE pg_catalog."default",
    client_addr inet,
    client_hostname text COLLATE pg_catalog."default",
    client_port integer,
    backend_start timestamp with time zone,
    xact_start timestamp with time zone,
    query_start timestamp with time zone,
    state_change timestamp with time zone,
    wait_event_type text COLLATE pg_catalog."default",
    wait_event text COLLATE pg_catalog."default",
    state text COLLATE pg_catalog."default",
    backend_xid xid,
    backend_xmin xid,
    query_id bigint,
    backend_type text COLLATE pg_catalog."default"
    ) ;

-- DROP INDEX IF EXISTS public.bestat_sah_idx_on_st_01;
CREATE INDEX IF NOT EXISTS bestat_sah_idx_on_st_01 ON public.bestat_sah (sampling_time) ;
-- DROP INDEX IF EXISTS public.bestat_sah_idx_on_st_wet_01;
CREATE INDEX IF NOT EXISTS bestat_sah_idx_on_st_wet_01 ON public.bestat_sah (sampling_time, wait_event_type) ;

-- DROP PROCEDURE IF EXISTS public.bestat_fill_sah(integer);

CREATE OR REPLACE PROCEDURE public.bestat_fill_sah(IN v_iteration integer)
       LANGUAGE 'plpgsql'
AS $BODY$
declare
v_Count            INTEGER ;
sz_is_collect      VARCHAR ;
v_insert_timestamp TIMESTAMP ;
begin
v_Count := 0 ;
while (v_Count < v_Iteration) LOOP
      if (v_Count = (v_Iteration - 1)) then
         commit ;
         select sz_value into sz_is_collect from bestat_SAH_parameters where sz_parameter = 'is_collect' ;
         if sz_is_collect = 'yes' then v_Count := 0 ;
            else v_count := v_Iteration + 10 ; 
            end if ;
         end if ;
      v_insert_timestamp := clock_timestamp() ;
      insert into bestat_SAH
             (SELECT v_insert_timestamp, datid, datname, pid, leader_pid, usesysid, usename,
                     application_name, client_addr, client_hostname, client_port, backend_start, xact_start,
                     query_start, state_change, wait_event_type, wait_event, state, backend_xid, backend_xmin,
                     query_id, backend_type
                     from pg_stat_activity) ;
      v_Count = v_Count + 1 ;
      perform pg_sleep(1) ;
      end LOOP ;
end ;
$BODY$;

-- DROP TABLE IF EXISTS public.besst_stat_ash_history;
CREATE TABLE IF NOT EXISTS public.besst_stat_ash_history (
    pid integer,
    ts timestamp with time zone,
    event_type text COLLATE pg_catalog."default",
    event text COLLATE pg_catalog."default",
    queryid bigint ) TABLESPACE pg_default ;

ALTER TABLE IF EXISTS public.besst_stat_ash_history OWNER to crypta ;

-- DROP PROCEDURE IF EXISTS public.besst_stat_fill_ash_table();
CREATE OR REPLACE PROCEDURE public.besst_stat_fill_ash_table()
LANGUAGE 'plpgsql'
AS $BODY$
begin
MERGE INTO public.besst_stat_ash_history bsah
      USING public.pg_wait_sampling_history pwsh
      ON bsah.pid = pwsh.pid AND bsah.ts = pwsh.ts
      WHEN NOT MATCHED THEN
           INSERT (pid, ts, event_type, event, queryid)
                  VALUES (pwsh.pid, pwsh.ts, pwsh.event_type, pwsh.event, pwsh.queryid) ;
end ;
$BODY$ ;
ALTER PROCEDURE public.besst_stat_fill_ash_table() OWNER TO crypta;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.01 конец -- таблицы ASH статистик и функции заполнения
-- ---------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.02 начало -- блок AWR сбора статистики PGMonitor
-- ---------------------------------------------------------------------------------------------------------------------------

select * from pg_stat_database;

-- последовательность нумерации снапшотов
create sequence bestat_snapshots_seq ;
-- таблица снапшотов
create table bestat_snapshots (
       snap_id bigint,
       snap_ts timestamp ) ;
select * from bestat_snapshots ;

-- собираем статистику запросов и текст
select * from pg_stat_statements ;
-- create table bestat_stat_statements as select 1::bigint snap_id, * from pg_stat_statements ;
-- DROP TABLE bestat_statements ;

CREATE TABLE bestat_statements (
	snap_id bigint,
	userid oid NULL,
	dbid oid NULL,
	toplevel bool NULL,
	queryid int8 NULL,
	count_plans int8 NULL,
	total_plan_time float8 NULL,
	min_plan_time float8 NULL,
	max_plan_time float8 NULL,
	mean_plan_time float8 NULL,
	stddev_plan_time float8 NULL,
	calls int8 NULL,
	total_exec_time float8 NULL,
	min_exec_time float8 NULL,
	max_exec_time float8 NULL,
	mean_exec_time float8 NULL,
	stddev_exec_time float8 NULL,
	count_rows int8 NULL,
	shared_blks_hit int8 NULL,
	shared_blks_read int8 NULL,
	shared_blks_dirtied int8 NULL,
	shared_blks_written int8 NULL,
	local_blks_hit int8 NULL,
	local_blks_read int8 NULL,
	local_blks_dirtied int8 NULL,
	local_blks_written int8 NULL,
	temp_blks_read int8 NULL,
	temp_blks_written int8 NULL,
	blk_read_time float8 NULL,
	blk_write_time float8 NULL,
	temp_blk_read_time float8 NULL,
	temp_blk_write_time float8 NULL,
	wal_records int8 NULL,
	wal_fpi int8 NULL,
	wal_bytes numeric NULL,
	jit_functions int8 NULL,
	jit_generation_time float8 NULL,
	jit_inlining_count int8 NULL,
	jit_inlining_time float8 NULL,
	jit_optimization_count int8 NULL,
	jit_optimization_time float8 NULL,
	jit_emission_count int8 NULL,
	jit_emission_time float8 null ) ;

insert into bestat_statements select * from bestat_stat_statements ;

--DROP TABLE bestat_query_text ;
CREATE TABLE bestat_query_text (
	snap_id bigint,
	queryid int8 NULL,
	query text null ) ;

-- готовимся сохранять планы
select * from pg_store_plans order by queryid, planid ;
-- create table bestat_store_plans as select 1::bigint, * from pg_store_plans ;
-- DROP TABLE public.bestat_store_plans ;
CREATE TABLE bestat_store_plans (
	snap_id bigint NULL,
	userid oid NULL,
	dbid oid NULL,
	queryid int8 NULL,
	planid int8 NULL,
	plan text NULL,
	calls int8 NULL,
	total_time float8 NULL,
	min_time float8 NULL,
	max_time float8 NULL,
	mean_time float8 NULL,
	stddev_time float8 NULL,
	count_rows int8 NULL,
	shared_blks_hit int8 NULL,
	shared_blks_read int8 NULL,
	shared_blks_dirtied int8 NULL,
	shared_blks_written int8 NULL,
	local_blks_hit int8 NULL,
	local_blks_read int8 NULL,
	local_blks_dirtied int8 NULL,
	local_blks_written int8 NULL,
	temp_blks_read int8 NULL,
	temp_blks_written int8 NULL,
	blk_read_time float8 NULL,
	blk_write_time float8 NULL,
	temp_blk_read_time float8 NULL,
	temp_blk_write_time float8 NULL,
	first_call timestamptz NULL,
	last_call timestamptz null ) ;

drop table bestat_archiver ;
drop table bestat_bgwriter ;
drop table bestat_wal ;
drop table bestat_database ;
drop table bestat_database_conflicts ;
drop table bestat_slru ;
drop table bestat_replication ;
drop table bestat_replication_slots ;
drop table bestat_wal_receiver ;
drop table bestat_recovery_prefetch ;
drop table bestat_subscription ;
drop table bestat_subscription_stats ;
drop table bestat_ssl ;
drop table bestat_gssapi ;
drop table bestat_all_tables ;
drop table bestatio_all_tables ;
drop table bestat_all_indexes ;
drop table bestatio_all_indexes ;
drop table bestatio_all_sequences ;
drop table bestat_user_functions ;

create table bestat_archiver as select 1::bigint snap_id, * from pg_stat_archiver ;
create table bestat_bgwriter as select 1::bigint snap_id, * from pg_stat_bgwriter ;
create table bestat_wal as select 1::bigint snap_id, * from pg_stat_wal ;
create table bestat_database as select 1::bigint snap_id, * from pg_stat_database ;
create table bestat_database_conflicts as select 1::bigint snap_id, * from pg_stat_database_conflicts ;
create table bestat_slru as select 1::bigint snap_id, * from pg_stat_slru ;
create table bestat_replication as select 1::bigint snap_id, * from pg_stat_replication ;
create table bestat_replication_slots as select 1::bigint snap_id, * from pg_stat_replication_slots ;
create table bestat_wal_receiver as select 1::bigint snap_id, * from pg_stat_wal_receiver ;
create table bestat_recovery_prefetch as select 1::bigint snap_id, * from pg_stat_recovery_prefetch ;
create table bestat_subscription as select 1::bigint snap_id, * from pg_stat_subscription ;
create table bestat_subscription_stats as select 1::bigint snap_id, * from pg_stat_subscription_stats ;
create table bestat_ssl as select 1::bigint snap_id, * from pg_stat_ssl ;
create table bestat_gssapi as select 1::bigint snap_id, * from pg_stat_gssapi ;
create table bestat_all_tables as select 1::bigint snap_id, * from pg_stat_all_tables ;
create table bestatio_all_tables as select 1::bigint snap_id, * from pg_statio_all_tables ;
create table bestat_all_indexes as select 1::bigint snap_id, * from pg_stat_all_indexes ;
create table bestatio_all_indexes as select 1::bigint snap_id, * from pg_statio_all_indexes ;
create table bestatio_all_sequences as select 1::bigint snap_id, * from pg_statio_all_sequences ;
create table bestat_user_functions as select 1::bigint snap_id, * from pg_stat_user_functions ;

-- процедура собирает статистические врезы
create or replace procedure bestat_create_snapshot()
    LANGUAGE 'plpgsql'
    AS $BODY$
    DECLARE
    current_snap_id bigint ; 
    BEGIN
    SELECT nextval('bestat_snapshots_seq') INTO current_snap_id ;
    insert into bestat_snapshots VALUES (current_snap_id, now()) ;
-- текущая статистика запросов
-- так как статистика собирается в накопительном режиме, текст запроса сохраняется отдельно во избежание разрастания
    insert INTO bestat_statements 
           select current_snap_id::bigint, userid,	dbid, toplevel,	queryid, "plans", total_plan_time, min_plan_time, max_plan_time, mean_plan_time, stddev_plan_time, calls,
                  total_exec_time, min_exec_time, max_exec_time, mean_exec_time, stddev_exec_time, "rows", shared_blks_hit, shared_blks_read, shared_blks_dirtied,
                  shared_blks_written, local_blks_hit, local_blks_read, local_blks_dirtied, local_blks_written, temp_blks_read, temp_blks_written, blk_read_time, blk_write_time,
                  temp_blk_read_time, temp_blk_write_time, wal_records, wal_fpi, wal_bytes, jit_functions, jit_generation_time, jit_inlining_count, jit_inlining_time,
                  jit_optimization_count, jit_optimization_time, jit_emission_count, jit_emission_time     
                  from pg_stat_statements ;
-- текущие тексты запросов - в общее хранилище добавляются только новые
    MERGE INTO bestat_query_text b_qt
          USING (select queryid, query
                        from pg_stat_statements) pss_qt
          ON b_qt.queryid = pss_qt.queryid
          WHEN NOT MATCHED THEN
               INSERT (snap_id, queryid, query)
                      VALUES (current_snap_id::bigint, queryid, query) ;
-- текущие планы запросов
    insert INTO bestat_store_plans 
           select current_snap_id::bigint, userid, dbid, queryid, planid, plan, calls, total_time, min_time, max_time, mean_time, stddev_time, "rows", shared_blks_hit,
                  shared_blks_read, shared_blks_dirtied, shared_blks_written, local_blks_hit, local_blks_read, local_blks_dirtied, local_blks_written, temp_blks_read,
                  temp_blks_written, blk_read_time, blk_write_time, temp_blk_read_time, temp_blk_write_time, first_call, last_call
           from pg_store_plans ;
-- историю планов мы очищаем при каждой выгрузке - иначе очень большой объём выгружается
    PERFORM pg_store_plans_reset() ;
-- заполняем данные прочих статистических таблиц
    insert into bestat_archiver select current_snap_id::bigint, * from pg_stat_archiver ;
    insert into bestat_bgwriter select current_snap_id::bigint, * from pg_stat_bgwriter ;
    insert into bestat_wal select current_snap_id::bigint, * from pg_stat_wal ;
    insert into bestat_database select current_snap_id::bigint, * from pg_stat_database ;
    insert into bestat_database_conflicts select current_snap_id::bigint, * from pg_stat_database_conflicts ;
    insert into bestat_slru select current_snap_id::bigint, * from pg_stat_slru ;
    insert into bestat_replication select current_snap_id::bigint, * from pg_stat_replication ;
    insert into bestat_replication_slots select current_snap_id::bigint, * from pg_stat_replication_slots ;
    insert into bestat_wal_receiver select current_snap_id::bigint, * from pg_stat_wal_receiver ;
    insert into bestat_recovery_prefetch select current_snap_id::bigint, * from pg_stat_recovery_prefetch ;
    insert into bestat_subscription select current_snap_id::bigint, * from pg_stat_subscription ;
    insert into bestat_subscription_stats select current_snap_id::bigint, * from pg_stat_subscription_stats ;
    insert into bestat_ssl select current_snap_id::bigint, * from pg_stat_ssl ;
    insert into bestat_gssapi select current_snap_id::bigint, * from pg_stat_gssapi ;
    insert into bestat_all_tables select current_snap_id::bigint, * from pg_stat_all_tables ;
    insert into bestatio_all_tables select current_snap_id::bigint, * from pg_statio_all_tables ;
    insert into bestat_all_indexes select current_snap_id::bigint, * from pg_stat_all_indexes ;
    insert into bestatio_all_indexes select current_snap_id::bigint, * from pg_statio_all_indexes ;
    insert into bestatio_all_sequences select current_snap_id::bigint, * from pg_statio_all_sequences ;
    insert into bestat_user_functions select current_snap_id::bigint, * from pg_stat_user_functions ;

    END ;
$BODY$ ;

-- проверка
CALL public.bestat_create_snapshot() ;
-- конфигурируем автосбор - здесь в БД postgres
-- use postgres ;
SELECT cron.schedule_in_database('bestat_mk_snapshot', '*/15 * * * *', 'CALL public.bestat_create_snapshot()', 'crypta');

select count(*) from bestat_stat_statements ;
select count(*) from bestat_query_text ;
select count(*) from bestat_store_plans ;

select * from bestat_archiver ;
select * from bestat_bgwriter ;
select * from bestat_wal ;
select * from bestat_database ;
select * from bestat_database_conflicts ;
select * from bestat_slru ;
select * from bestat_replication ;
select * from bestat_replication_slots ;
select * from bestat_wal_receiver ;
select * from bestat_recovery_prefetch ;
select * from bestat_subscription ;
select * from bestat_subscription_stats ;
select * from bestat_ssl ;
select * from bestat_gssapi ;
select * from bestat_all_tables ;
select * from bestatio_all_tables ;
select * from bestat_all_indexes ;
select * from bestatio_all_indexes ;
select * from bestatio_all_sequences ;
select * from bestat_user_functions ;

-- выгрузка дельт приращений статистик запросов в целом - рабочий вариант от 2025-03-13 переведен во view
create or replace view bestat_statements_deltas_view as
       select bestat_statements_deltas.* from (
              select snap_id, userid, dbid, toplevel, queryid,
                     case when count_plans < lag(count_plans,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then count_plans else count_plans - lag(count_plans,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end count_plans,
                     case when total_plan_time < lag(total_plan_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then total_plan_time else total_plan_time - lag(total_plan_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end total_plan_time,
                     case when min_plan_time < lag(min_plan_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then min_plan_time else min_plan_time - lag(min_plan_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end min_plan_time,
                     case when max_plan_time < lag(max_plan_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then max_plan_time else max_plan_time - lag(max_plan_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end max_plan_time,
                     case when mean_plan_time < lag(mean_plan_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then mean_plan_time else mean_plan_time - lag(mean_plan_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end mean_plan_time,
                     case when stddev_plan_time < lag(stddev_plan_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then stddev_plan_time else stddev_plan_time - lag(stddev_plan_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end stddev_plan_time,
                     case when calls < lag(calls,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then calls else calls - lag(calls,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end calls,
                     case when total_exec_time < lag(total_exec_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then total_exec_time else total_exec_time - lag(total_exec_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end total_exec_time,
                     case when min_exec_time < lag(min_exec_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then min_exec_time else min_exec_time - lag(min_exec_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end min_exec_time,
                     case when max_exec_time < lag(max_exec_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then max_exec_time else max_exec_time - lag(max_exec_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end max_exec_time,
                     case when mean_exec_time < lag(mean_exec_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then mean_exec_time else mean_exec_time - lag(mean_exec_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end mean_exec_time,
                     case when stddev_exec_time < lag(stddev_exec_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then stddev_exec_time else stddev_exec_time - lag(stddev_exec_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end stddev_exec_time,
                     case when count_rows < lag(count_rows,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then count_rows else count_rows - lag(count_rows,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end count_rows,
                     case when shared_blks_hit < lag(shared_blks_hit,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then shared_blks_hit else shared_blks_hit - lag(shared_blks_hit,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end shared_blks_hit,
                     case when shared_blks_read < lag(shared_blks_read,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then shared_blks_read else shared_blks_read - lag(shared_blks_read,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end shared_blks_read,
                     case when shared_blks_dirtied < lag(shared_blks_dirtied,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then shared_blks_dirtied else shared_blks_dirtied - lag(shared_blks_dirtied,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end shared_blks_dirtied,
                     case when shared_blks_written < lag(shared_blks_written,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then shared_blks_written else shared_blks_written - lag(shared_blks_written,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end shared_blks_written,
                     case when local_blks_hit < lag(local_blks_hit,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then local_blks_hit else local_blks_hit - lag(local_blks_hit,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end local_blks_hit,
                     case when local_blks_read < lag(local_blks_read,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then local_blks_read else local_blks_read - lag(local_blks_read,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end local_blks_read,
                     case when local_blks_dirtied < lag(local_blks_dirtied,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then local_blks_dirtied else local_blks_dirtied - lag(local_blks_dirtied,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end local_blks_dirtied,
                     case when local_blks_written < lag(local_blks_written,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then local_blks_written else local_blks_written - lag(local_blks_written,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end local_blks_written,
                     case when temp_blks_read < lag(temp_blks_read,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then temp_blks_read else temp_blks_read - lag(temp_blks_read,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end temp_blks_read,
                     case when temp_blks_written < lag(temp_blks_written,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then temp_blks_written else temp_blks_written - lag(temp_blks_written,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end temp_blks_written,
                     case when blk_read_time < lag(blk_read_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then blk_read_time else blk_read_time - lag(blk_read_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end blk_read_time,
                     case when blk_write_time < lag(blk_write_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then blk_write_time else blk_write_time - lag(blk_write_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end blk_write_time,
                     case when temp_blk_read_time < lag(temp_blk_read_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then temp_blk_read_time else temp_blk_read_time - lag(temp_blk_read_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end temp_blk_read_time,
                     case when temp_blk_write_time < lag(temp_blk_write_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then temp_blk_write_time else temp_blk_write_time - lag(temp_blk_write_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end temp_blk_write_time,
                     case when wal_records < lag(wal_records,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then wal_records else wal_records - lag(wal_records,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end wal_records,
                     case when wal_fpi < lag(wal_fpi,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then wal_fpi else wal_fpi - lag(wal_fpi,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end wal_fpi,
                     case when wal_bytes < lag(wal_bytes,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then wal_bytes else wal_bytes - lag(wal_bytes,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end wal_bytes,
                     case when jit_functions < lag(jit_functions,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then jit_functions else jit_functions - lag(jit_functions,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end jit_functions,
                     case when jit_generation_time < lag(jit_generation_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then jit_generation_time else jit_generation_time - lag(jit_generation_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end jit_generation_time,
                     case when jit_inlining_count < lag(jit_inlining_count,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then jit_inlining_count else jit_inlining_count - lag(jit_inlining_count,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end jit_inlining_count,
                     case when jit_inlining_time < lag(jit_inlining_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then jit_inlining_time else jit_inlining_time - lag(jit_inlining_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end jit_inlining_time,
                     case when jit_optimization_count < lag(jit_optimization_count,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then jit_optimization_count else jit_optimization_count - lag(jit_optimization_count,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end jit_optimization_count,
                     case when jit_optimization_time < lag(jit_optimization_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then jit_optimization_time else jit_optimization_time - lag(jit_optimization_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end jit_optimization_time,
                     case when jit_emission_count < lag(jit_emission_count,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then jit_emission_count else jit_emission_count - lag(jit_emission_count,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end jit_emission_count,
                     case when jit_emission_time < lag(jit_emission_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc)
                          then jit_emission_time else jit_emission_time - lag(jit_emission_time,1) over (partition by userid, dbid, toplevel, queryid order by snap_id asc) end jit_emission_time
                     from bestat_statements
                     where calls > 0 and calls is not null ) as bestat_statements_deltas
              where calls > 0 and calls is not null
       order by snap_id, userid, dbid, toplevel, queryid ;

-- проверка вьюхи
select * from bestat_statements_deltas_view bsd, bestat_snapshots bs 
       where bs.snap_id = bsd.snap_id 
             and bs.snap_ts > TO_TIMESTAMP('2025-03-12 00:00:00', 'YYYY-MM-DD HH24:MI:SS') 
             and bs.snap_ts < TO_TIMESTAMP('2025-03-12 23:59:59', 'YYYY-MM-DD HH24:MI:SS') ;

-- агрегация статистик позапросно
select userid, dbid, toplevel, queryid,
       round(sum(count_plans)::NUMERIC,3) count_plans, round(sum(total_plan_time)::NUMERIC,3) total_plan_time, round(sum(min_plan_time)::NUMERIC,3) min_plan_time,
       round(sum(max_plan_time)::NUMERIC,3) max_plan_time, round(sum(mean_plan_time)::NUMERIC,3) mean_plan_time, round(sum(stddev_plan_time)::NUMERIC,3) stddev_plan_time,
       round(sum(calls)::NUMERIC,3) calls, round(sum(total_exec_time)::NUMERIC,3) total_exec_time, round(sum(min_exec_time)::NUMERIC,3) min_exec_time,
       round(sum(max_exec_time)::NUMERIC,3) max_exec_time, round(sum(mean_exec_time)::NUMERIC,3) mean_exec_time, round(sum(stddev_exec_time)::NUMERIC,3) stddev_exec_time,
       round(sum(count_rows)::NUMERIC,3) count_rows, round(sum(shared_blks_hit)::NUMERIC,3) shared_blks_hit, round(sum(shared_blks_read)::NUMERIC,3) shared_blks_read,
       round(sum(shared_blks_dirtied)::NUMERIC,3) shared_blks_dirtied, round(sum(shared_blks_written)::NUMERIC,3) shared_blks_written, 
       round(sum(local_blks_hit)::NUMERIC,3) local_blks_hit, round(sum(local_blks_read)::NUMERIC,3) local_blks_read, 
       round(sum(local_blks_dirtied)::NUMERIC,3) local_blks_dirtied, round(sum(local_blks_written)::NUMERIC,3) local_blks_written,
       round(sum(temp_blks_read)::NUMERIC,3) temp_blks_read, round(sum(temp_blks_written)::NUMERIC,3) temp_blks_written, round(sum(blk_read_time)::NUMERIC,3) blk_read_time,
       round(sum(blk_write_time)::NUMERIC,3) blk_write_time, round(sum(temp_blk_read_time)::NUMERIC,3) temp_blk_read_time, 
       round(sum(temp_blk_write_time)::NUMERIC,3) temp_blk_write_time, round(sum(wal_records)::NUMERIC,3) wal_records, round(sum(wal_fpi)::NUMERIC,3) wal_fpi,
       round(sum(wal_bytes)::NUMERIC,3) wal_bytes, round(sum(jit_functions)::NUMERIC,3) jit_functions, round(sum(jit_generation_time)::NUMERIC,3) jit_generation_time,
       round(sum(jit_inlining_count)::NUMERIC,3) jit_inlining_count, round(sum(jit_inlining_time)::NUMERIC,3) jit_inlining_time, 
       round(sum(jit_optimization_count)::NUMERIC,3) jit_optimization_count, round(sum(jit_optimization_time)::NUMERIC,3) jit_optimization_count, 
       round(sum(jit_emission_count)::NUMERIC,3) jit_emission_count, round(sum(jit_emission_time)::NUMERIC,3) jit_emission_time
       from bestat_statements_deltas_view bsd, bestat_snapshots bs 
       where bs.snap_id = bsd.snap_id 
             and bs.snap_ts > TO_TIMESTAMP('2025-03-12 00:00:00', 'YYYY-MM-DD HH24:MI:SS') 
             and bs.snap_ts < TO_TIMESTAMP('2025-03-12 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
             and bsd.queryid = -5629183501768033106
       group by userid, dbid, toplevel, queryid
       order by userid, dbid, toplevel, queryid ;

-- выгрузка дельт приращений планов - рабочий вариант от 2025-03-13 переведен во view
create or replace view bestat_plans_deltas_view as
       select bestat_plans_deltas.* from (
              select snap_id, userid, dbid, queryid, planid, plan,
                     case when calls < lag(calls,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then calls else calls - lag(calls,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end calls,
                     case when total_time < lag(total_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then total_time else total_time - lag(total_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end total_plan_time,
                     case when min_time < lag(min_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then min_time else min_time - lag(min_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end min_plan_time,
                     case when max_time < lag(max_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then max_time else max_time - lag(max_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end max_plan_time,
                     case when mean_time < lag(mean_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then mean_time else mean_time - lag(mean_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end mean_plan_time,
                     case when stddev_time < lag(stddev_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then stddev_time else stddev_time - lag(stddev_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end stddev_plan_time,
                     case when count_rows < lag(count_rows,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then count_rows else count_rows - lag(count_rows,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end count_rows,
                     case when shared_blks_hit < lag(shared_blks_hit,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then shared_blks_hit else shared_blks_hit - lag(shared_blks_hit,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end shared_blks_hit,
                     case when shared_blks_read < lag(shared_blks_read,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then shared_blks_read else shared_blks_read - lag(shared_blks_read,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end shared_blks_read,
                     case when shared_blks_dirtied < lag(shared_blks_dirtied,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then shared_blks_dirtied else shared_blks_dirtied - lag(shared_blks_dirtied,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end shared_blks_dirtied,
                     case when shared_blks_written < lag(shared_blks_written,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then shared_blks_written else shared_blks_written - lag(shared_blks_written,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end shared_blks_written,
                     case when local_blks_hit < lag(local_blks_hit,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then local_blks_hit else local_blks_hit - lag(local_blks_hit,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end local_blks_hit,
                     case when local_blks_read < lag(local_blks_read,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then local_blks_read else local_blks_read - lag(local_blks_read,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end local_blks_read,
                     case when local_blks_dirtied < lag(local_blks_dirtied,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then local_blks_dirtied else local_blks_dirtied - lag(local_blks_dirtied,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end local_blks_dirtied,
                     case when local_blks_written < lag(local_blks_written,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then local_blks_written else local_blks_written - lag(local_blks_written,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end local_blks_written,
                     case when temp_blks_read < lag(temp_blks_read,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then temp_blks_read else temp_blks_read - lag(temp_blks_read,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end temp_blks_read,
                     case when temp_blks_written < lag(temp_blks_written,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then temp_blks_written else temp_blks_written - lag(temp_blks_written,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end temp_blks_written,
                     case when blk_read_time < lag(blk_read_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then blk_read_time else blk_read_time - lag(blk_read_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end blk_read_time,
                     case when blk_write_time < lag(blk_write_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then blk_write_time else blk_write_time - lag(blk_write_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end blk_write_time,
                     case when temp_blk_read_time < lag(temp_blk_read_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then temp_blk_read_time else temp_blk_read_time - lag(temp_blk_read_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end temp_blk_read_time,
                     case when temp_blk_write_time < lag(temp_blk_write_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc)
                          then temp_blk_write_time else temp_blk_write_time - lag(temp_blk_write_time,1) over (partition by userid, dbid, queryid, planid, plan order by snap_id asc) end temp_blk_write_time
                     from bestat_store_plans
                     where calls > 0 and calls is not null ) as bestat_plans_deltas
              where calls > 0 and calls is not null
       order by snap_id, userid, dbid, queryid, planid, plan ;

select * from bestat_plans_deltas_view ;


-- добавлено в версию 0.2 (0.35) 09 апреля 2025 года
-- в текущей картине мира по этим таблицам не должны рассчитываться лаги - их информационный смысл иной
-- bestat_archiver
-- bestat_wal_receiver

-- всегда одна запись BGWRITER
--drop view bestat_bgwriter_deltas_view ;
create or replace view bestat_bgwriter_deltas_view as
       SELECT snap_id,
              case when checkpoints_timed < lag(checkpoints_timed,1) over (order by snap_id asc)
                   then checkpoints_timed else checkpoints_timed - lag(checkpoints_timed,1) over (order by snap_id asc) end checkpoints_timed,
              case when checkpoints_req < lag(checkpoints_req,1) over (order by snap_id asc)
                   then checkpoints_req else checkpoints_req - lag(checkpoints_req,1) over (order by snap_id asc) end checkpoints_req,
              case when checkpoint_write_time < lag(checkpoint_write_time,1) over (order by snap_id asc)
                   then checkpoint_write_time else checkpoint_write_time - lag(checkpoint_write_time,1) over (order by snap_id asc) end checkpoint_write_time,
              case when checkpoint_sync_time < lag(checkpoint_sync_time,1) over (order by snap_id asc)
                   then checkpoint_sync_time else checkpoint_sync_time - lag(checkpoint_sync_time,1) over (order by snap_id asc) end checkpoint_sync_time,
              case when buffers_checkpoint < lag(buffers_checkpoint,1) over (order by snap_id asc)
                   then buffers_checkpoint else buffers_checkpoint - lag(buffers_checkpoint,1) over (order by snap_id asc) end buffers_checkpoint,
              case when buffers_clean < lag(buffers_clean,1) over (order by snap_id asc)
                   then buffers_clean else buffers_clean - lag(buffers_clean,1) over (order by snap_id asc) end buffers_clean,
              case when maxwritten_clean < lag(maxwritten_clean,1) over (order by snap_id asc)
                   then maxwritten_clean else maxwritten_clean - lag(maxwritten_clean,1) over (order by snap_id asc) end maxwritten_clean,
              case when buffers_backend < lag(buffers_backend,1) over (order by snap_id asc)
                   then buffers_backend else buffers_backend - lag(buffers_backend,1) over (order by snap_id asc) end buffers_backend,
              case when buffers_backend_fsync < lag(buffers_backend_fsync,1) over (order by snap_id asc)
                   then buffers_backend_fsync else buffers_backend_fsync - lag(buffers_backend_fsync,1) over (order by snap_id asc) end buffers_backend_fsync,
              case when buffers_alloc < lag(buffers_alloc,1) over (order by snap_id asc)
                   then buffers_alloc else buffers_alloc - lag(buffers_alloc,1) over (order by snap_id asc) end buffers_alloc,
              stats_reset
              from bestat_bgwriter
              order by snap_id ;
select * from bestat_bgwriter_deltas_view order by snap_id ;

-- всегда одна запись WAL
--drop view bestat_wal_deltas_view ;
create or replace view bestat_wal_deltas_view as
       SELECT snap_id,
              case when wal_records < lag(wal_records,1) over (order by snap_id asc)
                   then wal_records else wal_records - lag(wal_records,1) over (order by snap_id asc) end wal_records,
              case when wal_fpi < lag(wal_fpi,1) over (order by snap_id asc)
                   then wal_fpi else wal_fpi - lag(wal_fpi,1) over (order by snap_id asc) end wal_fpi,
              case when wal_bytes < lag(wal_bytes,1) over (order by snap_id asc)
                   then wal_bytes else wal_bytes - lag(wal_bytes,1) over (order by snap_id asc) end wal_bytes,
              case when wal_buffers_full < lag(wal_buffers_full,1) over (order by snap_id asc)
                   then wal_buffers_full else wal_buffers_full - lag(wal_buffers_full,1) over (order by snap_id asc) end wal_buffers_full,
              case when wal_write < lag(wal_write,1) over (order by snap_id asc)
                   then wal_write else wal_write - lag(wal_write,1) over (order by snap_id asc) end wal_write,
              case when wal_sync < lag(wal_sync,1) over (order by snap_id asc)
                   then wal_sync else wal_sync- lag(wal_sync,1) over (order by snap_id asc) end wal_sync,
              case when wal_write_time < lag(wal_write_time,1) over (order by snap_id asc)
                   then wal_write_time else wal_write_time - lag(wal_write_time,1) over (order by snap_id asc) end wal_write_time,
              case when wal_sync_time < lag(wal_sync_time,1) over (order by snap_id asc)
                   then wal_sync_time else wal_sync_time - lag(wal_sync_time,1) over (order by snap_id asc) end wal_sync_time,
              stats_reset
              from bestat_wal
              order by snap_id ;
select * from bestat_wal_deltas_view order by snap_id ;

-- ------------------------------------
-- таблицы
-- ------------------------------------
-- данные статистики потабличные
-- в снапшоте записи на каждую таблицу
--drop view bestat_all_tables_deltas_view ;
create or replace view bestat_all_tables_deltas_view as
       SELECT snap_id, relid, schemaname, relname,
              case when seq_scan < lag(seq_scan,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then seq_scan else seq_scan - lag(seq_scan,1) over (partition by relid, schemaname, relname order by snap_id asc) end seq_scan,
              case when seq_tup_read < lag(seq_tup_read,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then seq_tup_read else seq_tup_read - lag(seq_tup_read,1) over (partition by relid, schemaname, relname order by snap_id asc) end seq_tup_read,
              case when idx_scan < lag(idx_scan,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then idx_scan else idx_scan - lag(idx_scan,1) over (partition by relid, schemaname, relname order by snap_id asc) end idx_scan,
              case when idx_tup_fetch < lag(idx_tup_fetch,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then idx_tup_fetch else idx_tup_fetch - lag(idx_tup_fetch,1) over (partition by relid, schemaname, relname order by snap_id asc) end idx_tup_fetch,
              case when n_tup_ins < lag(n_tup_ins,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then n_tup_ins else n_tup_ins - lag(n_tup_ins,1) over (partition by relid, schemaname, relname order by snap_id asc) end n_tup_ins,
              case when n_tup_upd < lag(n_tup_upd,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then n_tup_upd else n_tup_upd - lag(n_tup_upd,1) over (partition by relid, schemaname, relname order by snap_id asc) end n_tup_upd,
              case when n_tup_del < lag(n_tup_del,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then n_tup_del else n_tup_del - lag(n_tup_del,1) over (partition by relid, schemaname, relname order by snap_id asc) end n_tup_del,
              case when n_tup_hot_upd < lag(n_tup_hot_upd,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then n_tup_hot_upd else n_tup_hot_upd - lag(n_tup_hot_upd,1) over (partition by relid, schemaname, relname order by snap_id asc) end n_tup_hot_upd,
              case when n_live_tup < lag(n_live_tup,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then n_live_tup else n_live_tup - lag(n_live_tup,1) over (partition by relid, schemaname, relname order by snap_id asc) end n_live_tup,
              case when n_dead_tup < lag(n_dead_tup,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then n_dead_tup else n_dead_tup - lag(n_dead_tup,1) over (partition by relid, schemaname, relname order by snap_id asc) end n_dead_tup,
              case when n_mod_since_analyze < lag(n_mod_since_analyze,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then n_mod_since_analyze else n_mod_since_analyze - lag(n_mod_since_analyze,1) over (partition by relid, schemaname, relname order by snap_id asc) end n_mod_since_analyze,
              case when n_ins_since_vacuum < lag(n_ins_since_vacuum,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then n_ins_since_vacuum else n_ins_since_vacuum - lag(n_ins_since_vacuum,1) over (partition by relid, schemaname, relname order by snap_id asc) end n_ins_since_vacuum,
              last_vacuum, last_autovacuum, last_analyze, last_autoanalyze,
              case when vacuum_count < lag(vacuum_count,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then vacuum_count else vacuum_count - lag(vacuum_count,1) over (partition by relid, schemaname, relname order by snap_id asc) end vacuum_count,
              case when autovacuum_count < lag(autovacuum_count,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then autovacuum_count else autovacuum_count - lag(autovacuum_count,1) over (partition by relid, schemaname, relname order by snap_id asc) end autovacuum_count,
              case when analyze_count < lag(analyze_count,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then analyze_count else analyze_count - lag(analyze_count,1) over (partition by relid, schemaname, relname order by snap_id asc) end analyze_count,
              case when autoanalyze_count < lag(autoanalyze_count,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then autoanalyze_count else autoanalyze_count - lag(autoanalyze_count,1) over (partition by relid, schemaname, relname order by snap_id asc) end autoanalyze_count
              from bestat_all_tables
              order by relid, schemaname, relname, snap_id ;
select * from bestat_all_tables_deltas_view ;

-- суммарные данные по всем таблицам за срез
-- drop view bestat_all_tables_sum_deltas_view ;
create or replace view bestat_all_tables_sum_deltas_view as
       SELECT snap_id, 
              sum(seq_scan) as seq_scan, sum(seq_tup_read) as seq_tup_read, sum(idx_scan) as idx_scan, sum(idx_tup_fetch) as idx_tup_fetch,
			  sum(n_tup_ins) as n_tup_ins, sum(n_tup_upd) as n_tup_upd, sum(n_tup_del) as n_tup_del, sum(n_tup_hot_upd) as n_tup_hot_upd,
			  sum(n_live_tup) as n_live_tup, sum(n_dead_tup) as n_dead_tup, sum(n_mod_since_analyze) as n_mod_since_analyze,
			  sum(n_ins_since_vacuum) as n_ins_since_vacuum, max(last_vacuum) as last_vacuum, max(last_autovacuum) as last_autovacuum,
			  max(last_analyze) as last_analyze, max(last_autoanalyze) as last_autoanalyze, sum(vacuum_count) as vacuum_count,
              sum(autovacuum_count) as autovacuum_count, sum(analyze_count) as analyze_count, sum(autoanalyze_count) as autoanalyze_count
              from bestat_all_tables_deltas_view
			  group by snap_id order by snap_id ;
select * from bestat_all_tables_sum_deltas_view order by snap_id asc ;

-- данные статистики ввода - вывода потабличные
-- в снапшоте записи на каждую таблицу
--drop view bestat_io_all_tables_deltas_view ;
create or replace view bestat_io_all_tables_deltas_view as
       SELECT snap_id, relid, schemaname, relname,
              case when heap_blks_read < lag(heap_blks_read,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then heap_blks_read else heap_blks_read - lag(heap_blks_read,1) over (partition by relid, schemaname, relname order by snap_id asc) end heap_blks_read,
              case when heap_blks_hit < lag(heap_blks_hit,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then heap_blks_hit else heap_blks_hit - lag(heap_blks_hit,1) over (partition by relid, schemaname, relname order by snap_id asc) end heap_blks_hit,
              case when idx_blks_read < lag(idx_blks_read,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then idx_blks_read else idx_blks_read - lag(idx_blks_read,1) over (partition by relid, schemaname, relname order by snap_id asc) end idx_blks_read,
              case when idx_blks_hit < lag(idx_blks_hit,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then idx_blks_hit else idx_blks_hit - lag(idx_blks_hit,1) over (partition by relid, schemaname, relname order by snap_id asc) end idx_blks_hit,
              case when toast_blks_read < lag(toast_blks_read,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then toast_blks_read else toast_blks_read - lag(toast_blks_read,1) over (partition by relid, schemaname, relname order by snap_id asc) end toast_blks_read,
              case when toast_blks_hit < lag(toast_blks_hit,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then toast_blks_hit else toast_blks_hit - lag(toast_blks_hit,1) over (partition by relid, schemaname, relname order by snap_id asc) end toast_blks_hit,
              case when tidx_blks_read < lag(tidx_blks_read,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then tidx_blks_read else tidx_blks_read - lag(tidx_blks_read,1) over (partition by relid, schemaname, relname order by snap_id asc) end tidx_blks_read,
              case when tidx_blks_hit < lag(tidx_blks_hit,1) over (partition by relid, schemaname, relname order by snap_id asc)
                   then tidx_blks_hit else tidx_blks_hit - lag(tidx_blks_hit,1) over (partition by relid, schemaname, relname order by snap_id asc) end tidx_blks_hit
              from bestatio_all_tables
              order by relid, schemaname, relname, snap_id ;
select * from bestat_io_all_tables_deltas_view where heap_blks_read > 0;

-- суммарные данные ввода - вывода по всем таблицам за срез
--drop view bestat_io_all_tables_sum_deltas_view ;
create or replace view bestat_io_all_tables_sum_deltas_view as
       SELECT snap_id, sum(heap_blks_read) as heap_blks_read, sum(heap_blks_hit) as heap_blks_hit, sum(idx_blks_read) as idx_blks_read, sum(idx_blks_hit) as idx_blks_hit,
              sum(toast_blks_read) as toast_blks_read, sum(toast_blks_hit) as toast_blks_hit, sum(tidx_blks_read) as tidx_blks_read, sum(tidx_blks_hit) as tidx_blks_hit
              from bestat_io_all_tables_deltas_view
			  group by snap_id order by snap_id asc ;
select * from bestat_io_all_tables_sum_deltas_view ;

-- ------------------------------------
-- индексы
-- ------------------------------------
-- в снапшоте записи на каждую таблицу
--drop view bestat_all_indexes_deltas_view ;
create or replace view bestat_all_indexes_deltas_view as
       SELECT snap_id, relid, indexrelid, schemaname, relname, indexrelname, 
              case when idx_scan < lag(idx_scan,1) over (partition by relid, indexrelid, schemaname, relname, indexrelname order by snap_id asc)
                   then idx_scan else idx_scan - lag(idx_scan,1) over (partition by relid, indexrelid, schemaname, relname, indexrelname order by snap_id asc) end idx_scan,
              case when idx_tup_read < lag(idx_tup_read,1) over (partition by relid, indexrelid, schemaname, relname, indexrelname order by snap_id asc)
                   then idx_tup_read else idx_tup_read - lag(idx_tup_read,1) over (partition by relid, indexrelid, schemaname, relname, indexrelname order by snap_id asc) end idx_tup_read,
              case when idx_tup_fetch < lag(idx_tup_fetch,1) over (partition by relid, indexrelid, schemaname, relname, indexrelname order by snap_id asc)
                   then idx_tup_fetch else idx_tup_fetch - lag(idx_tup_fetch,1) over (partition by relid, indexrelid, schemaname, relname, indexrelname order by snap_id asc) end idx_tup_fetch
              from bestat_all_indexes
              order by relid, schemaname, relname, snap_id ;
select * from bestat_all_indexes_deltas_view ;

-- суммарные данные статистик по всем индексам за срез
--drop view bestat_all_indexes_sum_deltas_view ;
create or replace view bestat_all_indexes_sum_deltas_view as
       SELECT snap_id, sum(idx_scan) as idx_scan, sum(idx_tup_read) as idx_tup_read, sum(idx_tup_fetch) as idx_tup_fetch
              from bestat_all_indexes_deltas_view
			  group by snap_id order by snap_id asc ;
select * from bestat_all_indexes_sum_deltas_view ;

-- в снапшоте записи на каждую таблицу
--drop view bestat_io_all_indexes_deltas_view ;
create or replace view bestat_io_all_indexes_deltas_view as
       SELECT snap_id, relid, indexrelid, schemaname, relname, indexrelname, 
              case when idx_blks_read < lag(idx_blks_read,1) over (partition by relid, indexrelid, schemaname, relname, indexrelname order by snap_id asc)
                   then idx_blks_read else idx_blks_read - lag(idx_blks_read,1) over (partition by relid, indexrelid, schemaname, relname, indexrelname order by snap_id asc) end idx_blks_read,
              case when idx_blks_hit < lag(idx_blks_hit,1) over (partition by relid, indexrelid, schemaname, relname, indexrelname order by snap_id asc)
                   then idx_blks_hit else idx_blks_hit - lag(idx_blks_hit,1) over (partition by relid, indexrelid, schemaname, relname, indexrelname order by snap_id asc) end idx_blks_hit
              from bestatio_all_indexes
              order by relid, schemaname, relname, snap_id ;
select * from bestat_io_all_indexes_deltas_view ;

-- суммарные данные статистик ввода-вывода по всем индексам за срез
--drop view bestat_io_all_indexes_sum_deltas_view ;
create or replace view bestat_io_all_indexes_sum_deltas_view as
       SELECT snap_id, sum(idx_blks_read) as idx_blks_read, sum(idx_blks_hit) as idx_blks_hit
              from bestat_io_all_indexes_deltas_view
              group by snap_id order by snap_id ;
select * from bestat_io_all_indexes_sum_deltas_view ;

-- ------------------------------------
-- БД
-- ------------------------------------
-- в снапшоте записи на каждую БД и ещё одна для общих отношений
-- 0 для общих отношений datid, NULL для общих отношений datnameNULL для общих обьектов - numbackends, NULL если не считается для checksum_failures
--drop view bestat_database_deltas_view ;
create or replace view bestat_database_deltas_view as
       SELECT snap_id, datid, datname, numbackends,
              case when xact_commit < lag(xact_commit,1) over (partition by datid, datname order by snap_id asc)
                   then xact_commit else xact_commit - lag(xact_commit,1) over (partition by datid, datname order by snap_id asc) end xact_commit,
              case when xact_rollback < lag(xact_rollback,1) over (partition by datid, datname order by snap_id asc)
                   then xact_rollback else xact_rollback - lag(xact_rollback,1) over (partition by datid, datname order by snap_id asc) end xact_rollback,
              case when blks_read < lag(blks_read,1) over (partition by datid, datname order by snap_id asc)
                   then blks_read else blks_read - lag(blks_read,1) over (partition by datid, datname order by snap_id asc) end blks_read,
              case when blks_hit < lag(blks_hit,1) over (partition by datid, datname order by snap_id asc)
                   then blks_hit else blks_hit - lag(blks_hit,1) over (partition by datid, datname order by snap_id asc) end blks_hit,
              case when tup_returned < lag(tup_returned,1) over (partition by datid, datname order by snap_id asc)
                   then tup_returned else tup_returned - lag(tup_returned,1) over (partition by datid, datname order by snap_id asc) end tup_returned,
              case when tup_fetched < lag(tup_fetched,1) over (partition by datid, datname order by snap_id asc)
                   then tup_fetched else tup_fetched - lag(tup_fetched,1) over (partition by datid, datname order by snap_id asc) end tup_fetched,
              case when tup_inserted < lag(tup_inserted,1) over (partition by datid, datname order by snap_id asc)
                   then tup_inserted else tup_inserted - lag(tup_inserted,1) over (partition by datid, datname order by snap_id asc) end tup_inserted,
              case when tup_updated < lag(tup_updated,1) over (partition by datid, datname order by snap_id asc)
                   then tup_updated else tup_updated - lag(tup_updated,1) over (partition by datid, datname order by snap_id asc) end tup_updated,
              case when tup_deleted < lag(tup_deleted,1) over (partition by datid, datname order by snap_id asc)
                   then tup_deleted else tup_deleted - lag(tup_deleted,1) over (partition by datid, datname order by snap_id asc) end tup_deleted,
              case when conflicts < lag(conflicts,1) over (partition by datid, datname order by snap_id asc)
                   then conflicts else conflicts - lag(conflicts,1) over (partition by datid, datname order by snap_id asc) end conflicts,
              case when temp_files < lag(temp_files,1) over (partition by datid, datname order by snap_id asc)
                   then temp_files else temp_files - lag(temp_files,1) over (partition by datid, datname order by snap_id asc) end temp_files,
              case when temp_bytes < lag(temp_bytes,1) over (partition by datid, datname order by snap_id asc)
                   then temp_bytes else temp_bytes - lag(temp_bytes,1) over (partition by datid, datname order by snap_id asc) end temp_bytes,
              case when deadlocks < lag(deadlocks,1) over (partition by datid, datname order by snap_id asc)
                   then deadlocks else deadlocks - lag(deadlocks,1) over (partition by datid, datname order by snap_id asc) end deadlocks,
              case when checksum_failures < lag(checksum_failures,1) over (partition by datid, datname order by snap_id asc)
                   then checksum_failures else checksum_failures - lag(checksum_failures,1) over (partition by datid, datname order by snap_id asc) end checksum_failures,
              checksum_last_failure,
              case when blk_read_time < lag(blk_read_time,1) over (partition by datid, datname order by snap_id asc)
                   then blk_read_time else blk_read_time - lag(blk_read_time,1) over (partition by datid, datname order by snap_id asc) end blk_read_time,
              case when blk_write_time < lag(blk_write_time,1) over (partition by datid, datname order by snap_id asc)
                   then blk_write_time else blk_write_time - lag(blk_write_time,1) over (partition by datid, datname order by snap_id asc) end blk_write_time,
              case when session_time < lag(session_time,1) over (partition by datid, datname order by snap_id asc)
                   then session_time else session_time - lag(session_time,1) over (partition by datid, datname order by snap_id asc) end session_time,
              case when active_time < lag(active_time,1) over (partition by datid, datname order by snap_id asc)
                   then active_time else active_time - lag(active_time,1) over (partition by datid, datname order by snap_id asc) end active_time,
              case when idle_in_transaction_time < lag(idle_in_transaction_time,1) over (partition by datid, datname order by snap_id asc)
                   then idle_in_transaction_time else idle_in_transaction_time - lag(idle_in_transaction_time,1) over (partition by datid, datname order by snap_id asc) end idle_in_transaction_time,
              case when sessions < lag(sessions,1) over (partition by datid, datname order by snap_id asc)
                   then sessions else sessions - lag(sessions,1) over (partition by datid, datname order by snap_id asc) end sessions,
              case when sessions_abandoned < lag(sessions_abandoned,1) over (partition by datid, datname order by snap_id asc)
                   then sessions_abandoned else sessions_abandoned - lag(sessions_abandoned,1) over (partition by datid, datname order by snap_id asc) end sessions_abandoned,
              case when sessions_fatal < lag(sessions_fatal,1) over (partition by datid, datname order by snap_id asc)
                   then sessions_fatal else sessions_fatal - lag(sessions_fatal,1) over (partition by datid, datname order by snap_id asc) end sessions_fatal,
              case when sessions_killed < lag(sessions_killed,1) over (partition by datid, datname order by snap_id asc)
                   then sessions_killed else sessions_killed - lag(sessions_killed,1) over (partition by datid, datname order by snap_id asc) end sessions_killed,
              stats_reset
              from bestat_database
              order by datid, datname, snap_id ;

select * from bestat_database_deltas_view where datname = 'crypta' ;

-- статистики всех БД за срез суммарно - статистики кластера
--drop view bestat_database_sum_deltas_view ;
create or replace view bestat_database_sum_deltas_view as
       SELECT snap_id, sum(numbackends) as numbackends, sum(xact_commit) as xact_commit, sum(xact_rollback) as xact_rollback, sum(blks_read) as blks_read,
              sum(blks_hit) as blks_hit, sum(tup_returned) as tup_returned, sum(tup_fetched) as tup_fetched, sum(tup_inserted) as tup_inserted,
              sum(tup_updated) as tup_updated, sum(tup_deleted) as tup_deleted, sum(conflicts) as conflicts, sum(temp_files) as temp_files,
              sum(temp_bytes) as temp_bytes, sum(deadlocks) as deadlocks, sum(checksum_failures) as checksum_failures,
              max(checksum_last_failure) as checksum_last_failure, sum(blk_read_time) as blk_read_time, sum(blk_write_time) as blk_write_time,
              sum(session_time) as session_time, sum(active_time) as active_time, sum(idle_in_transaction_time) as idle_in_transaction_time,
              sum(sessions) as sessions, sum(sessions_abandoned) as sessions_abandoned, sum(sessions_fatal) as sessions_fatal,
              sum(sessions_killed) as sessions_killed, max(stats_reset) as stats_reset
			  from bestat_database_deltas_view
              group by snap_id order by snap_id asc ;
select * from bestat_database_sum_deltas_view ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.02 конец -- блок AWR сбора статистики PGMonitor
-- ---------------------------------------------------------------------------------------------------------------------------
