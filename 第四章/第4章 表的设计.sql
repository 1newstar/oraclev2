�ű�4-1  �鿴����������־
select a.name,b.value
    from v$statname a,v$mystat b
    where a.statistic#=b.statistic#
    and a.name='redo size';


�ű�4-2  ����׼�����������۲�redo����ͼ
sqlplus "/ as sysdba"
grant all on v_$mystat to ljb;
grant all on v_$statname to ljb;
connect  ljb/ljb
drop table t purge;
create table t as select * from dba_objects ;
--���´�����ͼ���������ֱ����select * from v_redo_size���в�ѯ
create or replace view v_redo_size as
    select a.name,b.value
    from v$statname a,v$mystat b
    where a.statistic#=b.statistic#
    and a.name='redo size';


�ű�4-3  �۲�ɾ����¼��������redo
select * from v_redo_size;
delete from t ;
select * from v_redo_size;


�ű�4-4  �۲�����¼��������redo
insert into t select * from dba_objects;
select * from v_redo_size;


�ű�4-5  �۲���¼�¼��������redo
update t set object_id=rownum;
select * from v_redo_size;


�ű�4-6  �۲�δɾ����ʱ�������߼���
drop table t purge;
create table t as select * from dba_objects ;
set autotrace on
select count(*) from t;


�ű�4-7  �۲�deleteɾ��t�����м�¼�󣬾�Ȼ�߼�������
set autotrace off
delete from t ;
commit;
set autotrace on
select count(*) from t;


�ű�4-8  truncate��ձ���߼������ڴ�����½���
truncate table t;
select count(*) from t;

�ű�4-9  �۲�TABLE ACCESS BY INDEX ROWID �����Ŀ���
drop table t purge;
create table t as select * from dba_objects where rownum<=200;
create index idx_obj_id on t(object_id);
set linesize 1000
set autotrace traceonly
select * from t where object_id<=10;

�ű�4-10  �۲��������TABLE ACCESS BY INDEX ROWID�Ŀ������
select object_id from t where object_id<=10;

�ű�4-11  ���Ա��¼˳�����ȴ���Է�֤˳�����
drop table t purge;
create table t
  (a int,
   b varchar2(4000) default  rpad('*',4000,'*'),
   c varchar2(3000) default  rpad('*',3000,'*')
   );
insert into t (a) values (1); 
insert into t (a) values (2);
insert into t (a) values (3);
select A from t;
delete from t where a=2;
insert into t (a) values (4);
commit;
select A from t;

�ű�4-12  �Ƚ�����order by �����ִ�мƻ��������Ĳ���
set linesize 1000
set autotrace traceonly
select A from t;
select A from t order by A;

�ű�4-13  �����������SESSION��ȫ����ʱ��
drop table t_tmp_session purge;
drop table t_tmp_transaction purge ;
create global temporary table T_TMP_session on commit preserve rows as select  * from dba_objects where 1=2;
select table_name,temporary,duration from user_tables  where table_name='T_TMP_SESSION';
create global temporary table t_tmp_transaction on commit delete rows as select * from dba_objects where 1=2;
select table_name, temporary, DURATION from user_tables  where table_name='T_TMP_TRANSACTION';

�ű�4-14  �ֱ�۲�����ȫ����ʱ����Ը���DML��������REDO��
select * from v_redo_size;
insert  into  t_tmp_transaction select * from dba_objects;
select * from v_redo_size;
insert  into  t_tmp_session select * from dba_objects;
select * from v_redo_size;
update t_tmp_transaction set object_id=rownum;
select * from v_redo_size;
update t_tmp_session set object_id=rownum;
delete from t_tmp_session;
select * from v_redo_size;
delete from t_tmp_transaction;
select * from v_redo_size;


�ű�4-15  ȫ����ʱ�����ͨ�������־����ıȽ�
drop table t purge;
create  table t  as select * from dba_objects where 1=2;
select * from v_redo_size;
insert into  t  select * from dba_objects;
select * from v_redo_size;
update t set object_id=rownum ;
select * from v_redo_size;
delete from t;
select * from v_redo_size; 


�ű�4-16  ���������ȫ����ʱ��ĸ�Чɾ��
select count(*) from t_tmp_transaction;
select * from v_redo_size;
insert into t_tmp_transaction select * from dba_objects;
commit;
select * from v_redo_size;
select count(*) from t_tmp_transaction;

�ű�4-17  ����SESSION��ȫ����ʱ��COMMIT������ռ�¼
select * from v_redo_size;
insert into t_tmp_session select * from dba_objects;
select * from v_redo_size;
commit;
select count(*) from t_tmp_session;
select * from v_redo_size;


�ű�4-18  ����SESSION��ȫ����ʱ���˳����ٵ��룬�۲��¼���
exit
sqlplus ljb/ljb
select count(*) from  t_tmp_session;


�ű�4-19  ����ȫ����ʱ��ĻỰ������֮�۲��1��SESSION
sqlplus ljb/ljb
select * from v$mystat where rownum=1;
select * from t_tmp_session;
insert  into  t_tmp_session select * from dba_objects;
commit;
select count(*) from t_tmp_session;


�ű�4-20  ����ȫ����ʱ��ĻỰ������֮�۲��2��SESSION
sqlplus ljb/ljb
select * from v$mystat where rownum=1;
select count(*) from t_tmp_session;
insert into t_tmp_session select * from  dba_objects where rownum=1;
commit;
select count(*) from t_tmp_session;


�ű�4-21  ��Χ����ʾ��
drop table range_part_tab purge;
--ע�⣬�˷���Ϊ��Χ����
create table range_part_tab (id number,deal_date date,area_code number,contents varchar2(4000))
           partition by range (deal_date)
           (
           partition p1 values less than (TO_DATE('2012-02-01', 'YYYY-MM-DD')),
           partition p2 values less than (TO_DATE('2012-03-01', 'YYYY-MM-DD')),
           partition p3 values less than (TO_DATE('2012-04-01', 'YYYY-MM-DD')),
           partition p4 values less than (TO_DATE('2012-05-01', 'YYYY-MM-DD')),
           partition p5 values less than (TO_DATE('2012-06-01', 'YYYY-MM-DD')),
           partition p6 values less than (TO_DATE('2012-07-01', 'YYYY-MM-DD')),
           partition p7 values less than (TO_DATE('2012-08-01', 'YYYY-MM-DD')),
           partition p8 values less than (TO_DATE('2012-09-01', 'YYYY-MM-DD')),
           partition p9 values less than (TO_DATE('2012-10-01', 'YYYY-MM-DD')),
           partition p10 values less than (TO_DATE('2012-11-01', 'YYYY-MM-DD')),
           partition p11 values less than (TO_DATE('2012-12-01', 'YYYY-MM-DD')),
           partition p12 values less than (TO_DATE('2013-01-01', 'YYYY-MM-DD')),
           partition p_max values less than (maxvalue)
           )
           ;

--�����ǲ���2012��һ��������������ͱ�ʾ���������ź��壨591��599�����������¼������10���������£�
insert into range_part_tab (id,deal_date,area_code,contents)
      select rownum,
             to_date( to_char(sysdate-365,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
             ceil(dbms_random.value(590,599)),
             rpad('*',400,'*')
        from dual
      connect by rownum <= 100000;
commit;





�ű�4-22  �б����ʾ��
drop table list_part_tab purge;
--ע�⣬�˷���Ϊ�б����
create table list_part_tab (id number,deal_date date,area_code number,contents varchar2(4000))
           partition by list (area_code)
           (
           partition p_591 values  (591),
           partition p_592 values  (592),
           partition p_593 values  (593),
           partition p_594 values  (594),
           partition p_595 values  (595),
           partition p_596 values  (596),
           partition p_597 values  (597),
           partition p_598 values  (598),
           partition p_599 values  (599),
           partition p_other values  (DEFAULT)
           )
           ;

--�����ǲ���2012��һ��������������ͱ�ʾ���������ź��壨591��599�����������¼������10���������£�
insert into list_part_tab (id,deal_date,area_code,contents)
      select rownum,
             to_date( to_char(sysdate-365,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
             ceil(dbms_random.value(590,599)),
             rpad('*',400,'*')
        from dual
      connect by rownum <= 100000;
commit;



�ű�4-23  ɢ�з���ʾ��
drop table hash_part_tab purge;
--ע�⣬�˷���HASH����
create table hash_part_tab (id number,deal_date date,area_code number,contents varchar2(4000))
            partition by hash (deal_date)
            PARTITIONS 12
            ;
--�����ǲ���2012��һ��������������ͱ�ʾ���������ź��壨591��599�����������¼������10���������£�
insert into hash_part_tab(id,deal_date,area_code,contents)
      select rownum,
             to_date( to_char(sysdate-365,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
             ceil(dbms_random.value(590,599)),
             rpad('*',400,'*')
        from dual
      connect by rownum <= 100000;
commit;



�ű�4-24  ��Ϸ���ʾ��
drop table range_list_part_tab purge;
--ע�⣬�˷���Ϊ��Χ����
create table range_list_part_tab (id number,deal_date date,area_code number,contents varchar2(4000))
           partition by range (deal_date)
             subpartition by list (area_code)
             subpartition TEMPLATE
             (subpartition p_591 values  (591),
              subpartition p_592 values  (592),
              subpartition p_593 values  (593),
              subpartition p_594 values  (594),
              subpartition p_595 values  (595),
              subpartition p_596 values  (596),
              subpartition p_597 values  (597),
              subpartition p_598 values  (598),
              subpartition p_599 values  (599),
              subpartition p_other values (DEFAULT))
           (
            partition p1 values less than (TO_DATE('2012-02-01', 'YYYY-MM-DD')),
            partition p2 values less than (TO_DATE('2012-03-01', 'YYYY-MM-DD')),
            partition p3 values less than (TO_DATE('2012-04-01', 'YYYY-MM-DD')),
            partition p4 values less than (TO_DATE('2012-05-01', 'YYYY-MM-DD')),
            partition p5 values less than (TO_DATE('2012-06-01', 'YYYY-MM-DD')),
            partition p6 values less than (TO_DATE('2012-07-01', 'YYYY-MM-DD')),
            partition p7 values less than (TO_DATE('2012-08-01', 'YYYY-MM-DD')),
            partition p8 values less than (TO_DATE('2012-09-01', 'YYYY-MM-DD')),
            partition p9 values less than (TO_DATE('2012-10-01', 'YYYY-MM-DD')),
            partition p10 values less than (TO_DATE('2012-11-01', 'YYYY-MM-DD')),
            partition p11 values less than (TO_DATE('2012-12-01', 'YYYY-MM-DD')),
            partition p12 values less than (TO_DATE('2013-01-01', 'YYYY-MM-DD')),
            partition p_max values less than (maxvalue)
           )
           ;

--�����ǲ���2012��һ��������������ͱ�ʾ���������ź��壨591��599�����������¼������10���������£�
insert into range_list_part_tab(id,deal_date,area_code,contents)
      select rownum,
             to_date( to_char(sysdate-365,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
             ceil(dbms_random.value(590,599)),
             rpad('*',400,'*')
        from dual
      connect by rownum <= 100000;
commit;



�ű�4-25  ����ԭ�����֮��ͨ�����
drop table norm_tab purge;
create table norm_tab (id number,deal_date date,area_code number,contents varchar2(4000));
insert into norm_tab(id,deal_date,area_code,contents)
      select rownum,
             to_date( to_char(sysdate-365,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
             ceil(dbms_random.value(590,599)),
             rpad('*',400,'*')
        from dual
      connect by rownum <= 100000;
commit;




�ű�4-26  ����ԭ�����֮��ͨ����������ڶη����ϵĲ���
SET LINESIZE 666
set pagesize 5000
column segment_name format a20
column partition_name format a20
column segment_type format a20
select segment_name,
       partition_name,
       segment_type,
       bytes / 1024 / 1024 "�ֽ���(M)",
       tablespace_name
  from user_segments
 where segment_name IN('RANGE_PART_TAB','NORM_TAB');



�ű�4-27  �۲�HASH�����Ķη������
SET LINESIZE 666
set pagesize 5000
column segment_name format a20
column partition_name format a20
column segment_type format a20
select segment_name,
       partition_name,
       segment_type,
       bytes / 1024 / 1024 "�ֽ���(M)",
       tablespace_name
  from user_segments
 where segment_name IN('HASH_PART_TAB');



�ű�4-28  �۲���Ϸ����Ķη���ĸ���
select count(*)
      from user_segments
     where segment_name ='RANGE_LIST_PART_TAB';


�ű�4-29  �۲췶Χ������ķ���������������������
set linesize 1000
set autotrace traceonly
set timing on
select *
      from range_part_tab
     where deal_date >= TO_DATE('2012-09-04', 'YYYY-MM-DD')
       and deal_date <= TO_DATE('2012-09-07', 'YYYY-MM-DD');


�ű�4-30  �Ƚ���ͬ��䣬��ͨ���޷��õ�DEAL_DATE�������з������������
select *
      from norm_tab
     where deal_date >= TO_DATE('2012-09-04', 'YYYY-MM-DD')
       and deal_date <= TO_DATE('2012-09-07', 'YYYY-MM-DD');


�ű�4-31  �۲�LIST������ķ��������ķ�������
set autotrace traceonly
set linesize 1000
select *
      from range_list_part_tab
     where deal_date >= TO_DATE('2012-09-04', 'YYYY-MM-DD')
       and deal_date <= TO_DATE('2012-09-07', 'YYYY-MM-DD')
       and area_code=591;


�ű�4-32  �Ƚ���ͬ��䣬��ͨ���޷���area_code�������з������������
select *
      from norm_tab
     where deal_date >= TO_DATE('2012-09-04', 'YYYY-MM-DD')
       and deal_date <= TO_DATE('2012-09-07', 'YYYY-MM-DD')
       and area_code=591;


�ű�4-33  ��������ķ�������
delete from norm_tab where deal_date>=TO_DATE('2012-09-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-09-30', 'YYYY-MM-DD');
--Ϊ�˺����½�����ķ��㣬�������ҽ�ɾ���ļ�¼���ˡ�
rollback;
alter table range_part_tab truncate partition p9;
select count(*) from range_part_tab where deal_date>=TO_DATE('2012-09-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-09-30', 'YYYY-MM-DD');


�ű�4-34  ������������������
drop table mid_table purge;
create table mid_table (id number deal_date date,area_code number,contents varchar2(4000));
select count(*) from mid_table ;
select count(*) from range_part_tab partition(p8);
---��Ȼ������������partition(p8)��ָ����������ѯ�⣬Ҳ���Բ��÷������������ѯ��
select count(*) from range_part_tab where deal_date>=TO_DATE('2012-08-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-08-31', 'YYYY-MM-DD');
--����������Ǿ���ķ���������
alter table range_part_tab exchange partition p8 with table mid_table;
--��ѯ���ַ���8���ݲ����ˡ�
select count(*) from range_part_tab partition(p8);
---����ͨ���¼�ɸղŵ�0����Ϊ8628���ˣ���Ȼʵ���˽�����
select count(*) from mid_table ;


�ű�4-35  ��������������ͨ������������
alter table range_part_tab exchange partition p8 with table mid_table;
select count(*) from range_part_tab partition(p8);
select count(*) from mid_table ;

�ű�4-36  �����и�
alter table range_part_tab split partition p_max  at (TO_DATE('2013-02-01', 'YYYY-MM-DD')) into (PARTITION p2013_01 ,PARTITION P_MAX);
alter table range_part_tab split partition p_max  at (TO_DATE('2013-03-01', 'YYYY-MM-DD')) into (PARTITION p2013_02 ,PARTITION P_MAX);

�ű�4-37  �۲�����и����
SQL> column segment_name format a20
SQL> column partition_name format a20
SQL> column segment_type format a20
SQL> select segment_name,
           partition_name,
           segment_type,
           bytes / 1024 / 1024 "�ֽ���(M)",
           tablespace_name
      from user_segments
     where segment_name IN('RANGE_PART_TAB');


�ű�4-38  �����ϲ�����
SQL> alter table range_part_tab  merge partitions p2013_02, P_MAX INTO PARTITION P_MAX;
���Ѹ��ġ�
SQL> alter table range_part_tab  merge partitions p2013_01, P_MAX INTO PARTITION P_MAX;
���Ѹ��ġ�


�ű�4-39  �۲�����ϲ����
SQL> column segment_name format a20
SQL> column partition_name format a20
SQL> column segment_type format a20
SQL> select segment_name,
           partition_name,
           segment_type,
           bytes / 1024 / 1024 "�ֽ���(M)",
           tablespace_name
      from user_segments
     where segment_name IN('RANGE_PART_TAB');


�ű�4-40  ���һ��������maxvalue��������׷�ӣ�ֻ����split
alter table range_part_tab add partition  p2013_01 values less than (TO_DATE('2013-02-01', 'YYYY-MM-DD'));
alter table range_part_tab add partition  p2013_01 values less than (TO_DATE('2013-02-01', 'YYYY-MM-DD'))




�ű�4-41  ����ɾ��maxvalue�����з���׷��
alter table range_part_tab drop partition  p_max;
alter table range_part_tab add partition  p2013_01 values less than (TO_DATE('2013-02-01', 'YYYY-MM-DD'));
alter table range_part_tab add partition  p2013_02 values less than (TO_DATE('2013-03-01', 'YYYY-MM-DD'));


�ű�4-42  ȫ��������ֲ�����
-----�����Ƕ�deal_date�н�ȫ������
create  index idx_part_tab_date on range_part_tab(deal_date) ;
-----�����Ƕ�area_code�н�һ���ֲ�����
create  index idx_part_tab_area on range_part_tab(area_code) local;



�ű�4-43  ȫ�������η������
column partition_name format a20
column segment_type format a20
select segment_name,
           partition_name,
           segment_type,
           bytes / 1024 / 1024 "�ֽ���(M)",
           tablespace_name
      from user_segments
     where segment_name IN('IDX_PART_TAB_DATE');


�ű�4-44  �ֲ������η������
SET LINESIZE 666
set pagesize 5000
column segment_name format a20
column partition_name format a20
column segment_type format a20
select segment_name,
           partition_name,
           segment_type,
           bytes / 1024 / 1024 "�ֽ���(M)",
           tablespace_name
      from user_segments
     where segment_name IN('IDX_PART_TAB_AREA');



�ű�4-45  �۲�ȫ�ֺ;ֲ�������״̬
select index_name, status
      from user_indexes
     where index_name in('IDX_PART_TAB_DATE', 'IDX_PART_TAB_AREA');

select index_name, partition_name, status
     from user_ind_partitions
    where index_name = 'IDX_PART_TAB_AREA';


�ű�4-46  ������truncate��ȫ������ʧЧ���ֲ�����δʧЧ
select count(*) from range_part_tab partition(p1);
alter table range_part_tab truncate partition p1;
select count(*) from range_part_tab partition(p2);

select index_name, status
      from user_indexes
     where index_name in('IDX_PART_TAB_DATE', 'IDX_PART_TAB_AREA');

select index_name, partition_name, status
      from user_ind_partitions
     where index_name = 'IDX_PART_TAB_AREA';



�ű�4-47  ��ʧЧ��ȫ�����������ؽ�
alter index IDX_PART_TAB_DATE rebuild;
select index_name, status from user_indexes where index_name ='IDX_PART_TAB_DATE';



�ű�4-48  update global indexes�ؼ��ֿɱ���ȫ������ʧЧ
select count(*) from range_part_tab partition(p2);
alter table range_part_tab truncate partition p2 update global indexes;
select count(*) from range_part_tab partition(p2);
select index_name, status from user_indexes where index_name ='IDX_PART_TAB_DATE';


�ű�4-49  Ӧ�÷�����ľֲ������������߼����ܴ�
create  index idx_range_list_tab_date on range_list_part_tab(id) local;
set autotrace traceonly
set linesize 1000
select * from range_list_part_tab where id=100000;



�ű�4-50  Ӧ����ͨ�����ͨ�����������߼�����С
create  index idx_norm_tab_date on norm_tab(id);
set autotrace traceonly
set linesize 1000
select * from norm_tab where id=100000;


�ű�4-51  ���������Ҫ�����������Ч���õ��������������޲��޴�
select *
      from range_list_part_tab
     where id=100000
     and deal_date >= sysdate-1
     and area_code=591;



�ű�4-52  �ֱ�������֯�����ͨ���������
drop table heap_addresses purge;
drop table iot_addresses purge;
create table heap_addresses
   (empno    number(10),
    addr_type varchar2(10),
    street    varchar2(10),
    city      varchar2(10),
    state     varchar2(2),
    zip       number,
    primary key (empno)
   )
/

create table iot_addresses
   (empno    number(10),
    addr_type varchar2(10),
    street    varchar2(10),
    city      varchar2(10),
    state     varchar2(2),
    zip       number,
   primary key (empno)
   )
   organization index
/
insert into heap_addresses
   select object_id,'WORK','123street','washington','DC',20123
   from all_objects;
insert into iot_addresses
    select object_id,'WORK','123street','washington','DC',20123
    from all_objects;
commit;





�ű�4-53  �ֱ�Ƚ�������֯�����ͨ��Ĳ�ѯ����
set linesize 1000
set autotrace traceonly
select * from heap_addresses where empno=22;
select * from iot address where empno=22;




�ű�4-54  �ر���ƺã��ɱ�������
Drop table cust_orders;
Drop cluster shc;


CREATE CLUSTER shc
    (
       cust_id     NUMBER,
       order_dt    timestamp SORT
    )
    HASHKEYS 10000
    HASH IS cust_id
    SIZE  8192
/

CREATE TABLE cust_orders
   (  	cust_id       	number,
      	order_dt      	timestamp SORT,
      	order_number 	number,
      	username    	varchar2(30),
      	ship_addr     	number,
      	bill_addr     	number,
      	invoice_num  	number
   )
   CLUSTER shc ( cust_id, order_dt )
/


---��ʼִ�з���
set autotrace traceonly explain
variable x number
select cust_id, order_dt, order_number
     from cust_orders
     where cust_id = :x
     order by order_dt;


