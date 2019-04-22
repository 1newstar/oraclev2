�ű�11-1  �жϹ�����SQL
select sql_id, count(*)
  from v$sqltext
 group by sql_id
having count(*) >= 100
 order by count(*) desc;


�ű�11-2  ʹ��Nest Loop Join����δ�õ������ģ��ȽϿ���
drop table t purge;
create table t as select * from v$sql_plan;  
     
select *
  from t
 where sql_id not in (select sql_id
                    from t
                   where sql_id in (select sql_id from t where operation = 'NESTED LOOPS' )
                     and (operation like '%INDEX%' or object_owner like '%SYS%'))
   and sql_id in
       (select sql_id from t where sql_id in (select sql_id from t where operation = 'NESTED LOOPS'));   


�ű�11-3  �ҳ���SYS�û���HINT������SQL������
select sql_text,
       sql_id,
       module,
       t.service,
       first_load_time,
       last_load_time,
       executions
  from v$sql t
 where sql_text like '%/*+%'
 and t.SERVICE not like 'SYS$%';


�ű�11-4  �ҳ������óɲ������Եı��������������
select t.owner, t.table_name, degree
  from dba_tables t
 where t.degree > '1';
 
select t.owner, t.table_name, index_name, degree, status
  from dba_indexes t
 where owner in ('LJB')
   and t.degree > '1';

--�������Ҫ�������������в��У��ʹ������£�
select 'alter index '|| t.owner||'.'||index_name || ' noparallel;'
      from dba_indexes t
     where owner in ('LJB')
       and t.degree >'1';


�ű�11-5  ����δ�貢�У�����HINT�貢�е�SQL
select sql_text,
        sql_id,
        module,
        .service,
        first_load_time,
        last_load_time,
        executions
  from v$sql t
 where sql_text like '%parall%'
   and t.SERVICE not like 'SYS$%';


�ű�11-6  ��ȡ���н��������SQL

select sql_text,
        sql_id,
         module,
        t.service,
        first_load_time,
        last_load_time,
        executions
  from v$sql t
 where (upper(sql_text) like '%TRUNC%' 
     or upper(sql_text) like '%TO_DATE%' 
     or upper(sql_text) like '%SUBSTR%')
   and t.SERVICE not like 'SYS$%';


�ű�11-7  ��ȡע�����ڴ���ʮ��֮һ�ĳ���

select * from (
  select name,
       t.type,
       sum(case when text like '%--%' then 1 else 0 end) / count(*) rate
     from user_source t
    where type in ('package body', 'procedure', 'function')---��ͷ������
     group by name, type
     having sum(case when text like '%--%' then 1 else 0 end) / count(*)<=1/10)
 order by  rate;



�ű�11-8  ��̬SQLδ��USING�п���δ�ð󶨱���
select *
  from user_source
 where name  in
       (select name from user_source where name in (select name from user_source where UPPER(text) like '%EXECUTE IMMEDIATE%'))
       and name in
       (select name from user_source where name in (select name from user_source where UPPER(text) like '%||%')) 
       and name not in 
       (select name from user_source where name in (select name from user_source where upper(text) not like '%USING%')) ;



�ű�11-9  ��ѯ�ύ���������SESSION
 select t1.sid, t1.value, t2.name
   from v$sesstat t1, v$statname t2
 --where t2.name like '%commit%'
  where t2.name like '%user commits%' --����ֻѡuser commits������ϵͳ�����Ȳ�����
    and t1.STATISTIC# = t2.STATISTIC#
    and value >= 10000
  order by value desc;



�ű�11-10  ��ѯδ�ð��ĳ����߼�
select distinct name, type
  from user_source
 where type in ('PROCEDURE', 'FUNCTION')
 order by type;



�ű�11-11  ��С����10GBδ�������ı�

--���С����10GBδ��������
select owner,
 segment_name,
 segment_type,
 sum(bytes) / 1024 / 1024 / 1024 object_size
 from dba_segments
 WHERE  segment_type = 'TABLE' ---�˴�˵������ͨ�����Ƿ���������Ƿ�����������TABLE PARTITION
 group by owner, segment_name, segment_type
having sum(bytes) / 1024 / 1024 / 1024 >= 10
 order by object_size desc;



�ű�11-12  ��ѯ������������100�ı�
--������������100���ı�
select table_owner, table_name, count(*) cnt
 from user_tab_partitions
 WHERE dba_owner in ('LJB')
 having count(*)>=100
 group by table_owner, table_name
 order by cnt desc;



�ű�11-13  ���С����10GB����ʱ���ֶΣ��ɿ����ڸ��н�����
---����10GB�Ĵ��û��ʱ���ֶ�

select T1.*, t2.column_name, t2.data_type
  from (select segment_name,
               segment_type,
               sum(bytes) / 1024 / 1024 / 1024 object_size
          from user_segments
         WHERE segment_type = 'TABLE' ---�˴�˵������ͨ�����Ƿ���������Ƿ�����������TABLE PARTITION
         group by segment_name, segment_type
        having sum(bytes) / 1024 / 1024 / 1024 >= 0.01
         order by object_size desc) t1,
       user_tab_columns t2
 where t1.segment_name = t2.table_name(+)
   and t2.DATA_TYPE = 'DATE' ;     --��˵����������ʱ����
 
---������������������й۲�Ƚ�
select segment_name,
               segment_type,
               sum(bytes) / 1024 / 1024 / 1024 object_size
          from user_segments
         WHERE segment_type = 'TABLE' ---�˴�˵������ͨ�����Ƿ���������Ƿ�����������TABLE PARTITION
         group by segment_name, segment_type
        having sum(bytes) / 1024 / 1024 / 1024 >= 0.01
         order by object_size desc;



�ű�11-14  �ҳ��н��������ı�ͬʱ�۲�ñ���
select trigger_name, table_name, tab_size
  from user_triggers t1,
       (select segment_name, sum(bytes / 1024 / 1024 / 1024)  tab_size
          from user_segments t
         where t.segment_type='TABLE'
         group by segment_name) t2
where t1.TABLE_NAME=t2.segment_name;




�ű�11-15  ��ѯ��Щ��δ��ע��
col COMMENTS for a40;
select TABLE_NAME,T.TABLE_TYPE
  from USER_TAB_COMMENTS T
 where table_name not like 'BIN$%'
   and comments is null
order by table_name;





�ű�11-16  ��ѯ��Щ��δ��ע�ͣ������ο���
select TABLE_NAME,COLUMN_NAME
  from USER_COL_COMMENTS
 where table_name not like'BIN$%'
   and comments isnull
order by table_name;




�ű�11-17  ��ѯ��Щ����LONG����
 SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
    FROM user_tab_columns
   WHERE DATA_TYPE = 'LONG'
ORDER BY 1, 2;




�ű�11-18  ��ѯ��Щ����CHAR����
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
    FROM user_tab_columns
   WHERE DATA_TYPE = 'CHAR'
ORDER BY 1, 2;




�ű�11-19  ��ѯ��Щ�����Ǻ�������
select
       t.index_name,
       t.index_type,
       t.status,
       t.blevel,
       t.leaf_blocks
  from user_indexes t
 where index_type in ('FUNCTION-BASED NORMAL');



�ű�11-20  ��ѯ��Щ������λͼ����
select
       t.index_name,
       t.index_type,
       t.status,
       t.blevel,
       t.leaf_blocks
  from user_indexes t
 where index_type in ('BITMAP');



�ű�11-21  ��ѯ���δ�������ı�����Щ
select table_name,
       constraint_name,
       cname1 || nvl2(cname2, ',' || cname2, null) ||
       nvl2(cname3, ',' || cname3, null) ||
       nvl2(cname4, ',' || cname4, null) ||
       nvl2(cname5, ',' || cname5, null) ||
       nvl2(cname6, ',' || cname6, null) ||
       nvl2(cname7, ',' || cname7, null) ||
       nvl2(cname8, ',' || cname8, null) columns
  from (select b.table_name,
               b.constraint_name,
               max(decode(position, 1, column_name, null)) cname1,
               max(decode(position, 2, column_name, null)) cname2,
               max(decode(position, 3, column_name, null)) cname3,
               max(decode(position, 4, column_name, null)) cname4,
               max(decode(position, 5, column_name, null)) cname5,
               max(decode(position, 6, column_name, null)) cname6,
               max(decode(position, 7, column_name, null)) cname7,
               max(decode(position, 8, column_name, null)) cname8,
               count(*) col_cnt
          from (select substr(table_name, 1, 30) table_name,
                       substr(constraint_name, 1, 30) constraint_name,
                       substr(column_name, 1, 30) column_name,
                       position
                  from user_cons_columns) a,
               user_constraints b
         where a.constraint_name = b.constraint_name
           and b.constraint_type = 'R'
         group by b.table_name, b.constraint_name) cons
 where col_cnt > ALL
 (select count(*)
          from user_ind_columns i
         where i.table_name = cons.table_name
           and i.column_name in (cname1, cname2, cname3, cname4, cname5,
                cname6, cname7, cname8)
           and i.column_position <= cons.col_cnt
         group by i.index_name);



�ű�11-22  ���в���ֵ��ѯ��SQL��ȡ��������
select sql_text,
       sql_id,
       service,
       module,
       t. first_load_time
       t. last_load_time
  from v$sql t
 where (sql_text like '%>%' or sql_text like '%<%' or sql_text like '%<>%')
   and sql_text not like '%=>%'
   and service not like 'SYS$%';
   
   
   
   
�ű�11-23  ��ȡ����4���ֶ���ϵ���������
select table_name, index_name, count(*)
  from user_ind_columns
 group by table_name, index_name
having count(*) >= 4
 order by count(*) desc;




�ű�11-24  �����������������5������ע��
select table_name, count(*)
  from user_indexes
 group by table_name
having count(*) >= 5
 order by count(*) desc;



�ű�11-25  ����������ʹ���������������������
select 'alter index '||index_name||' monitoring usage;'
from user_indexes;
Ȼ��۲죺
set linesize 166
col INDEX_NAME for a10
col TABLE_NAME for a10
col START_MONITORING for a25
col END_MONITORING for a25
select * from v$object_usage;
--ֹͣ�������ļ�أ��۲�v$object_usage״̬�仯����ĳ����IDX����OBJECT����IDΪ����
alter index IDX_OBJECT_ID nomonitoring usage;





�ű�11-26  ��ѯ���κ������ı�
select table_name
  from user_tables
 where table_name not in (select table_name from user_indexes);





�ű�11-27  ��ѯʧЧ����ͨ����
select index_name, table_name, tablespace_name, index_type
  from user_indexes
 where status = 'UNUSABLE';




�ű�11-28  ��ѯʧЧ�ķ����ֲ�����
select  t1.index_name,                         
       t1.partition_name,                     
       t1.global_stats,                       
       t2.table_name,                         
       t2.table_type                          
  from user_ind_partitions t1, user_indexes t2
 where t2.index_name = t1.index_name          
   and t1.status = 'UNUSABLE'; 

   

�ű�11-29  ��ѯ���ǰ׺�Ƿ���T��ͷ
select * from user_tables where substr(table_name,1,2)<>'T_' ;


�ű�11-30  ��ѯ��ͼ��ǰ׺�Ƿ���V��ͷ
select view_name from user_views where substr(view_name,1,2)<>'V_' ;


�ű�11-32  ��ѯ�ر��ǰ׺�Ƿ���c��ͷ
select t.cluster_name,t.cluster_type
  from user_clusters t
 where substr(cluster_name, 1, 2) <> 'C_';


�ű�11-33  ��ѯ���е�ǰ׺�Ƿ���seq��ͷ���β
select sequence_name,cache_size
  from user_sequences
 where sequence_name not like '%SEQ%';


�ű�11-34  ��ѯ�洢�����Ƿ���p��ͷ
select object_name,procedure_name
  from user_procedures
 where object_type = 'PROCEDURE'
   and substr(object_name, 1, 2) <> 'P_';


�ű�11-35  ��ѯ�����Ƿ���f��ͷ
select object_name,procedure_name
  from user_procedures
 where object_type = 'FUNCTION'
   and substr(object_name, 1, 2) <> 'F_';



�ű�11-36  ��ѯ���Ƿ���pkg��ͷ
select object_name,procedure_name
  from user_procedures
 where object_type = 'PACKAGE'
   and substr(object_name, 1, 4) <> 'PKG_';



�ű�11-37 ��ѯ���Ƿ���typ��ͷ
select object_name,procedure_name
  from user_procedures
 where object_type = 'TYPE'
   and substr(object_name, 1, 4) <> 'TYP_';


�ű�11-38  ��ѯ�����Ƿ���pk��ͷ
select constraint_name, table_name
  from user_constraints
 where constraint_type = 'P'
   and substr(constraint_name, 1, 3) <> 'PK_'
   and constraint_name not like 'BIN$%';


�ű�11-39  ��ѯ����Ƿ���fk��ͷ
select constraint_name,table_name
  from user_constraints
 where constraint_type = 'R'
   and substr(constraint_name, 1, 3) <> 'FK_'
   and constraint_name not like 'BIN$%';


�ű�11-40  ��ѯΨһ�����Ƿ���ux��ͷ
select constraint_name,table_name
  from user_constraints
 where constraint_type = 'U'
   and substr(constraint_name, 1, 3) <> 'UX_'
   and table_name not like 'BIN$%';


�ű�11-41  ��ѯ��ͨ�����Ƿ���idx��ͷ
select index_name,table_name
  from user_indexes 
 where index_type='NORMAL'
   and uniqueness='NONUNIQUE'
   and substr(index_name, 1, 4) <> 'IDX_'
   and table_name not like 'BIN$%';


�ű�11-42  ��ѯλͼ�����Ƿ���bx��ͷ
select index_name,table_name
  from user_indexes
 where index_type LIKE'%BIT%'
   and substr(index_name, 1, 3) <>'BX_'
   and table_name notlike'BIN$%';


�ű�11-43  ��ѯ���������Ƿ���fx��ͷ
select index_name,table_name
  from user_indexes
 where index_type='FUNCTION-BASED NORMAL'
   and substr(index_name, 1, 3) <>'FX_'
   and table_name notlike'BIN$%';
