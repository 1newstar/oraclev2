�ű�5-1  �������߶Ƚϵ�Ӧ������ǰ�Ĺ����
drop table t1 purge;
drop table t2 purge;
drop table t3 purge;
drop table t4 purge;
drop table t5 purge;
drop table t6 purge;
drop table t7 purge;
create table t1 as select rownum as id ,rownum+1 as id2 from dual connect by level<=5;
create table t2 as select rownum as id ,rownum+1 as id2 from dual connect by level<=50;
create table t3 as select rownum as id ,rownum+1 as id2 from dual connect by level<=500;
create table t4 as select rownum as id ,rownum+1 as id2 from dual connect by level<=5000;
create table t5 as select rownum as id ,rownum+1 as id2 from dual connect by level<=50000;
create table t6 as select rownum as id ,rownum+1 as id2 from dual connect by level<=500000;
create table t7 as select rownum as id ,rownum+1 as id2 from dual connect by level<=5000000;



�ű�5-2  ������ɽ�������׼������
create index idx_id_t1 on t1(id);
create index idx_id_t2 on t2(id);
create index idx_id_t3 on t3(id);
create index idx_id_t4 on t4(id);
create index idx_id_t5 on t5(id);
create index idx_id_t6 on t6(id);
create index idx_id_t7 on t7(id);



�ű�5-3  �۲�Ƚϸ��������Ĵ�С
select segment_name, bytes/1024                                             
      from user_segments                                                        
     where segment_name in ('IDX_ID_T1', 'IDX_ID_T2', 'IDX_ID_T3', 'IDX_ID_T4', 
            'IDX_ID_T5', 'IDX_ID_T6', 'IDX_ID_T7');     


�ű�5-4  �۲�Ƚϸ��������ĸ߶�
select index_name,
              blevel,
              leaf_blocks,
              num_rows,
              distinct_keys,
              clustering_factor
         from user_ind_statistics
        where table_name in( 'T1','T2','T3','T4','T5','T6','T7');


�ű�5-5  �۲�������t6����ص�����ɨ�������
set autotrace traceonly
set linesize 1000
set timing on
select * from t6 where id=10;



�ű�5-6  �۲�������t7����ص�����ɨ�������
select * from t7 where id=10;



�ű�5-7  �ٴβ�����t6����ص�ȫ��ɨ���ѯ������
drop index IDX_ID_T6 ;
select * from t6 where id=10;



�ű�5-8  �ٴβ�����t7����ص�ȫ��ɨ���ѯ������
drop index IDX_ID_T7 ;
select * from t7 where id=10;



�ű�5-9  ����������������׼������
drop table part_tab purge;
create table part_tab (id int,col2 int,col3 int)
           partition by range (id)
           (
           partition p1 values less than (10000),
           partition p2 values less than (20000),
           partition p3 values less than (30000),
           partition p4 values less than (40000),
           partition p5 values less than (50000),
           partition p6 values less than (60000),
           partition p7 values less than (70000),
           partition p8 values less than (80000),
           partition p9 values less than (90000),
           partition p10 values less than (100000),
           partition p11 values less than (maxvalue)
           )
           ;
insert into part_tab select rownum,rownum+1,rownum+2 from dual connect by rownum <=110000;
commit;
create  index idx_par_tab_col2 on part_tab(col2) local;
create  index idx_par_tab_col3 on part_tab(col3) ;



�ű�5-10  ������������鿴
col segment_name format a20
select segment_name, partition_name, segment_type
      from user_segments
     where segment_name = 'PART_TAB';

select segment_name, partition_name, segment_type
      from user_segments
     where segment_name = 'IDX_PAR_TAB_COL2';


select segment_name, partition_name, segment_type
      from user_segments
     where segment_name = 'IDX_PAR_TAB_COL3';



�ű�5-11  ������׼��������������ͨ������
drop table norm_tab purge;
create table norm_tab (id int,col2 int,col3 int);
insert into norm_tab select rownum,rownum+1,rownum+2 from dual connect by rownum <=110000;��
commit;
create  index idx_nor_tab_col2 on norm_tab(col2) ;
create  index idx_nor_tab_col3 on norm_tab(col3) ;



�ű�5-12  ȫ��������ɨ����������߼���
set autotrace traceonly
set linesize 1000
set timing on
select * from part_tab where col2=8 ;



�ű�5-13  ��ͨ������ɨ���߼����ٵĶ�
select * from norm_tab where col2=8 ;



�ű�5-14  �ֱ�۲���������ͨ��������߶�
select index_name,
         blevel,
         leaf_blocks,
         num_rows,
         distinct_keys,
clustering_factor 
FROM USER_IND_PARTITIONS
 where index_name='IDX_PAR_TAB_COL2';

select index_name,
               blevel,
               leaf_blocks,
               num_rows,
               distinct_keys,
               clustering_factor
          from user_ind_statistics
         where index_name ='IDX_NOR_TAB_COL2';


�ű�5-15  ��������ɨ�������ĳһ���������ܴ������
select * from part_tab where col2=8 and id=7;




�ű�5-16  COUNT(*)�Ż�����ǰ�Ľ�������
drop table t purge;
create table t as select * from dba_objects;
create index idx1_object_id on t(object_id);
select count(*) from t;



�ű�5-17  COUNT(*)���������п�ֵʱ�޷��õ�����
---��Ҫ˵������11g��ĳЩ�汾�£�T������object_id�п���������not null����������£��ɿ���ִ��alter table T modify object_id  null����������
set autotrace on
set linesize 1000
set timing on
select count(*) from t;



�ű�5-18  ��ȷ�����зǿգ�������COUNT(*)�õ�����
set autotrace on
set linesize 1000
set timing on
select count(*) from t where object_id is not null;



�ű�5-19  �鿴T������Ƿ�Ϊ��
desc t;   


�ű�5-20  �޸�object_id��Ϊ�ǿ�
SQL> alter table t modify OBJECT_ID not null;



�ű�5-21  ���²���SQL����count(*)�õ�����
set autotrace on
set linesize 1000
set timing on
select count(*) from t ;




�ű�5-22  object_id��Ϊ������Ҳ��˵���˷ǿ�����
drop table t purge;
create table t as select * from dba_objects;
alter table t add constraint pk1_object_id primary key (OBJECT_ID);
set autotrace on
set linesize 1000
set timing on
select count(*) from t;




�ű�5-23  SUM/AVG�Ż�����׼��֮����������
drop table t purge;
create table t as select * from dba_objects;
create index idx1_object_id on t(object_id);



�ű�5-24  SUM/AVG�ò�����������Ϊ������Ϊ�գ�
---��Ҫ˵������11g��ĳЩ�汾�£�T������object_id�п���������not null����������£��ɿ���ִ��alter table T modify object_id  null����������
set autotrace on
set linesize 1000
set timing on
select sum(object_id) from t;



�ű�5-25  ��˵�������зǿպ�SUM/AVG���õ�����
set autotrace on
set linesize 1000
select sum(object_id) from t where object_id is not null;



�ű�5-26  SUM��AVG��COUNT�ۺ�д������
select sum(object_id) ,avg(object_id),count(*) from t where object_id is not null;



�ű�5-27  MAX/MIN����ǰ��׼������
drop table t purge;
create table t as select * from dba_objects;
create index idx1_object_id on t(object_id);



�ű�5-28  MAX/MIN���Ӧ�������ǳ���Ч
select max(object_id) from t;



�ű�5-29  ��MAX����ǰ��׼��������һ�Ŵ��
create table t_max as select * from dba_objects��
create index idx_t_max_obj on t_max(object_id);
   insert into t_max select * from t_max;
   insert into t_max select * from t_max;
   insert into t_max select * from t_max;
   insert into t_max select * from t_max;
   insert into t_max select * from t_max;
commit;
select count(*) from t_max;




�ű�5-30  ���С�������ԣ�MAX/MIN������ȴ���޲���
set autotrace on
set linesize 1000
select max(object_id) from t_max;
select min(object_id) from t_max;



�ű�5-31  MIN��MAXͬʱд���Ż�����ֵ�����ò���������
set autotrace on
set linesize 1000
select min(object_id),max(object_id) from t ;


�ű�5-32  MIN��MAXͬʱд���Ż����޷���INDEX FULL SCAN (MIN/MAX)��
set autotrace on
set linesize 1000
select min(object_id),max(object_id) from t  where object_id is not null;


�ű�5-33  ��Ȥ�ĸ�д�������MAX/MINͬʱд������Ż�
set autotrace on
set linesize 1000
set timing on 
 select max, min
      from (select max(object_id) max from t ) a, (select min(object_id) min from t) b;
ע����һд�����ο���Ч����һ����
SELECT (select max(object_id) max from t) max_id
     , (select min(object_id) min from t) min_id
  FROM DUAL;



�ű�5-34  �����ر����TABLE ACCESS BY INDEX ROWID��������
drop table t purge;
create table t as select * from dba_objects;
create index idx1_object_id on t(object_id);
set autotrace traceonly
set linesize 1000
set timing on
select * from t where object_id<=5;


�ű�5-35  �Ƚ�����TABLE ACCESS BY INDEX ROWID������
set autotrace traceonly
set linesize 1000
set timing on
select object_id from t where object_id<=5;



�ű�5-36  �ٹ۲�һ��TABLE ACCESS BY INDEX ROWID������
set autotrace traceonly
set linesize 1000
select object_id,object_name from t where object_id<=5;



�ű�5-37  ׼����������t����������
create index idx_un_objid_objname on t(object_id,object_name);



�ű�5-38  ��������������TABLE ACCESS BY INDEX ROWID
select object_id,object_name from t where object_id<=5


�ű�5-39  �ۺ���������׼�����ֱ��������������ı�
drop table t_colocated purge;
create table t_colocated ( id number, col2 varchar2(100) );
begin
        for i in 1 .. 100000
        loop
            insert into t_colocated(id,col2)
            values (i, rpad(dbms_random.random,95,'*') );
        end loop;
    end;
    /

alter table t_colocated add constraint pk_t_colocated primary key(id);
drop table t_disorganized purge;
create table t_disorganized
     as
    select id,col2
    from t_colocated
    order by col2;

alter table t_disorganized add constraint pk_t_disorg primary key (id);




�ű�5-40  �ֱ�������ű�ľۺ����Ӳ��
set linesize 1000                                                          
select index_name,                                                         
              blevel,                                                          
              leaf_blocks,                                                     
              num_rows,                                                        
              distinct_keys,                                                   
              clustering_factor                                                
         from user_ind_statistics                                              
        where table_name in( 'T_COLOCATED','T_DISORGANIZED');        


�ű�5-41  ���ȹ۲������Ĳ�ѯ����
set linesize 1000
alter session set statistics_level=all;

select /*+index(t)*/ * from  t_colocated t  where id>=20000 and id<=40000;
---�˴���ȥ2���м�¼�������������
SELECT * FROM table(dbms_xplan.display_cursor(NULL,NULL,'runstats_last')); 



�ű�5-42  �ٹ۲������Ĳ�ѯ����
select /*+index(t)*/ * from  t_disorganized t  where id>=20000 and id<=40000;
SELECT * FROM table(dbms_xplan.display_cursor(NULL,NULL,'runstats_last')); 



�ű�5-43  δ����ǰ�����ܿ�����COST���ϵ�
set autotrace traceonly
set linesize 1000
drop table t purge;
create table t as select * from dba_objects;
set autotrace traceonly
select * from t where object_id>2;



�ű�5-44  ���������ܿ�����COST������
select * from t where object_id>2 order by object_id;



�ű�5-45  �۲���������Ľ�����׼������
create index idx_t_object_id on t(object_id);


�ű�5-46  ����������������ʱ�������Ȼ������
set linesize 1000
set autotrace traceonly
select * from t where object_id>2 order by object_id;



�ű�5-47  ����TABLE ACCESS BY INDEX ROWID��COST������
select object_id from t where object_id>2 order by object_id;



�ű�5-48  DISTINCT����ǰ��׼��
drop table t purge;
create table t as select * from dba_objects;
alter table T modify OBJECT_ID not null;
update t set object_id=2;
update t set object_id=3 where rownum<=25000;
commit;




�ű�5-49  ����DISTINCT���������
set autotrace traceonly
select  distinct object_id from t ;



�ű�5-50  SQLȥ��DISTINCT������������ʧ
set autotrace traceonly
select object_id from t ;


�ű�5-51  DISTINCT������ֵ��ѯʱ��������
SQL> select  distinct object_id from t where object_id=2;



�ű�5-52  ΪT���object_id�н�����
create index idx_t_object_id on t(object_id);



�ű�5-53  ���н�������DISTINCT���������򼴿�����
select  /*+index(t)*/ distinct object_id from t ;



�ű�5-54  INDEX FAST FULL SCAN�������߼����٣������޷���������
set linesize 1000
set autotrace traceonly
select  distinct object_id from t ;



�ű�5-55  INDEX FULL SCAN�����������򣬵��߼�������������ȫɨ��ࣩ
select object_id from t order by object_id;



�ű�5-56  UNION ����Ҫ�����
drop table t1 purge;
create table t1 as select * from dba_objects;
alter table t1 modify OBJECT_ID not null;
drop table t2 purge;
create table t2 as select * from dba_objects;
alter table t2 modify OBJECT_ID not null;
set linesize 1000
set autotrace traceonly
select object_id from t1
    union
    select object_id from t2;



�ű�5-57  �����޷�����UNION ����INDEX FAST FULL SCAN��
create index idx_t1_object_id on t1(object_id);
�����Ѵ�����
create index idx_t2_object_id on t2(object_id);
set autotrace traceonly
set linesize 1000
select  object_id from t1
    union
    select  object_id from t2;



�ű�5-58  INDEX FULL SCAN��������Ȼ�޷�����UNION����
select /*+index(t1)*/ object_id from t1
    union
    select /*+index(t2)*/  object_id from t2;



�ű�5-59  ������������о�֮׼��
drop table t_p cascade constraints purge;
drop table t_c cascade constraints purge;
CREATE TABLE T_P (ID NUMBER, NAME VARCHAR2(30));
ALTER TABLE T_P ADD CONSTRAINT  T_P_ID_PK  PRIMARY KEY (ID);
CREATE TABLE T_C (ID NUMBER, FID NUMBER, NAME VARCHAR2(30));
ALTER TABLE T_C ADD CONSTRAINT FK_T_C FOREIGN KEY (FID) REFERENCES T_P (ID);
INSERT INTO T_P SELECT ROWNUM, TABLE_NAME FROM ALL_TABLES;
INSERT INTO T_C SELECT ROWNUM, MOD(ROWNUM, 1000) + 1, OBJECT_NAME  FROM ALL_OBJECTS;
COMMIT;


�ű�5-60  ���δ������ǰ�ı��������ܷ���
set autotrace traceonly
set linesize 1000
SELECT A.ID, A.NAME, B.NAME FROM T_P A, T_C B WHERE A.ID = B.FID AND A.ID = 880;



�ű�5-61  �����������ı��������ܷ���
CREATE INDEX IND_T_C_FID ON T_C (FID);
SELECT A.ID, A.NAME, B.NAME FROM T_P A, T_C B WHERE A.ID = B.FID AND A.ID = 880;



�ű�5-62  �����������û�������������
--���ȿ����Ự1
select sid from v$mystat where rownum=1;
DELETE T_C WHERE ID = 2;

--�����������Ự2��Ҳ���ǿ���һ���µ�����
select sid from v$mystat where rownum=1;
DELETE T_P WHERE ID = 2000;



�ű�5-63  ���������ɾ��
drop index  IND_T_C_FID;



�ű�5-64  �������ɾ�������������������
--���ȿ����Ự1
select sid from v$mystat where rownum=1;
DELETE T_C WHERE ID = 2;
--�����������Ự2��Ҳ���ǿ���һ���µ�����
select sid from v$mystat where rownum=1;
 
--Ȼ��ִ�����½��й۲�
DELETE T_P WHERE ID = 2000;
--��Ȼ���ֿ�ס���첻���ˣ�



�ű�5-65  ɾ���������ڱ�ļ�¼ʧ��
DELETE T_P WHERE ID = 2;

        
        
�ű�5-66  ���������Ķ�Ӧ��¼ûɾ��
select count(*) from T_C WHERE FID=2;



�ű�5-67  ������ڱ����ؼ�¼ɾ���󣬲����ɹ�
delete from T_C WHERE FID=2;
COMMIT;
DELETE T_P WHERE ID = 2;
COMMIT;



�ű�5-68  ����ɾ������
alter table T_C drop constraint FK_T_C;
ALTER TABLE T_C ADD CONSTRAINT FK_T_C FOREIGN KEY (FID) REFERENCES T_P (ID) ON DELETE CASCADE;



�ű�5-69  ��Ȼ����ͨ�������Զ�ɾ��
SELECT COUNT(*) FROM T_C WHERE FID=3;
DELETE FROM T_P WHERE ID=3;
COMMIT;
SELECT COUNT(*) FROM T_C WHERE FID=3;



�ű�5-70  �ڱ�T��ID�н���ͨ����
drop table t cascade constraints purge;
CREATE TABLE T (ID NUMBER, NAME VARCHAR2(30));
INSERT INTO T SELECT ROWNUM, TABLE_NAME FROM ALL_TABLES;
COMMIT;
CREATE INDEX IDX_T_ID ON t(ID);



�ű�5-71  ΪID����������Լ������������
alter table t add constraint t_id_pk primary key (ID);



�ű�5-72  �۲�object_id,object_type ˳����������
drop table t purge;
create table t as select * from dba_objects;
create index idx1_object_id on t(object_id,object_type);
create index idx2_object_id on t(object_type,object_id);
set autotrace traceonly
set linesize 1000
select /*+index(t,idx1_object_id)*/ * from  t  where object_id=20  and object_type='TABLE';



�ű�5-73  �۲�object_type, object_id˳����������
set autotrace traceonly
set linesize 1000
select /*+index(t,idx2_object_id)*/ * from  t  where object_id=20  and object_type='TABLE';



�ű�5-74  �����У��õ�dx1_object_id���ܸ���
set autotrace traceonly
set linesize 1000
select /*+index(t,idx1_object_id)*/ *  from  t where object_id>=20 and object_id<2000  and object_type='TABLE';



�ű�5-75  �����У��õ�dx2_object_id���ܸ���
set autotrace traceonly
set linesize 1000
select /*+index(t,idx2_object_id)*/ *  from  t where object_id>=20 and object_id<2000   and object_type='TABLE';



�ű�5-76  in���Ż�֮����׼��
drop table t purge;
create table t as select * from dba_objects;
update t set object_id=rownum ;
UPDATE t SET OBJECT_ID=20 WHERE ROWNUM<=26000;
UPDATE t SET OBJECT_ID=21 WHERE OBJECT_ID<>20;
commit;
create index idx1_object_id on t(object_id,object_type);



�ű�5-77  in���Ż��ļ�¼׼��
drop table t purge;
create table t as select * from dba_objects;
update t set object_id=rownum ;
UPDATE t SET OBJECT_ID=20 WHERE ROWNUM<=26000;
UPDATE t SET OBJECT_ID=21 WHERE OBJECT_ID<>20;
commit;
create index idx1_object_id on t(object_id,object_type);



�ű�5-78  ��Χ��ѯ���ܽϵ�
set autotrace traceonly
set linesize 1000
select  /*+index(t,idx1_object_id)*/ * from t  where object_TYPE='TABLE'  AND OBJECT_ID >= 20 AND OBJECT_ID<= 21;



�ű�5-79  ��Χ��ѯ����ΪINд������������
select  /*+index(t,idx1_object_id)*/ * from t t where object_TYPE='TABLE'  AND  OBJECT_ID IN (20,21);


�ű�5-80  ���������ǰ׺�뵥������һ��
drop table t purge;
create table t as select * from dba_objects;
create index idx_object_id on t(object_id,object_type);
set autotrace traceonly
set linesize 1000
select * from t where object_id=19;



�ű�5-81  ���������ǰ׺�뵥��������һ��
drop index idx_object_id;
create index idx_object_id on t(object_type, object_id);
select * from t where object_id=19;



�ű�5-82  ����������������ٶ�����ǰ��׼��
drop table t_no_idx purge;
drop table t_1_idx purge;
drop table t_2_idx purge;
drop table t_3_idx purge;
drop table t_n_idx purge;
create table t_no_idx as select * from dba_objects;
insert into t_no_idx select * from t_no_idx;
insert into t_no_idx select * from t_no_idx;
insert into t_no_idx select * from t_no_idx;
insert into t_no_idx select * from t_no_idx;
insert into t_no_idx select * from t_no_idx;
commit;
select count(*) from t_no_idx;
create table t_1_idx as select * from t_no_idx;
create index idx_1_1 on t_1_idx(object_id);
create table t_2_idx as select * from t_no_idx;
create index idx_2_1 on t_2_idx(object_id);
create index idx_2_2 on t_2_idx(object_name);
create table t_3_idx as select * from t_no_idx;
create index idx_3_1 on t_3_idx(object_id);
create index idx_3_2 on t_3_idx(object_name);
create index idx_3_3 on t_3_idx(object_type);



�ű�5-83  ��������������ٶȿ�����ϵ����
set timing on
insert into t_no_idx select * from t_no_idx where rownum<=100000;
insert into t_1_idx select * from t_1_idx where rownum<=100000;
commit;
insert into t_2_idx select * from t_2_idx where rownum<=100000;
insert into t_3_idx select * from t_3_idx where rownum<=100000;



�ű�5-84 �������Ӱ�����
set timing on
insert into t_no_idx select * from t_no_idx where rownum<=100000 order by dbms_random.random
commit;
insert into t_1_idx select * from t_1_idx where rownum<=100000 order by dbms_random.random;
commit;
insert into t_2_idx select * from t_1_idx where rownum<=100000 order by dbms_random.random;
commit;
insert into t_3_idx select * from t_3_idx where rownum<=100000 order by dbms_random.random;




�ű�5-85  ����������󽨣���������������
set timing on
create index idx_no_1 on t_no_idx(object_id);
create index idx_no_2 on t_no_idx(object_name);
create index idx_no_3 on t_no_idx(object_type);



�ű�5-86  ������صĲ�ѯ�ű�
drop table t purge;
create table t as select * from dba_objects;
create index idx_t_id on t (object_id);
create index idx_t_name on t (object_name);
---δ�������ʱ��v$object_usage��ѯ�����κμ�¼
select * from v$object_usage;
--��������idx_t_id��idx_t_name�������������



�ű�5-87  ������ص�ʵʩ
alter index idx_t_id monitoring usage;
alter index idx_t_name monitoring usage;
set linesize 166
col INDEX_NAME for a10
col TABLE_NAME for a10
col MONITORING for a10
col USED for a10
col START_MONITORING for a25
col END_MONITORING for a25
select * from v$object_usage;



�ű�5-88  ������صĸ���
--���²�ѯ��Ȼ�õ�object_id�е�����
select object_id from t where object_id=19;
--�۲��������Ȼ����IDX_T_ID�е�������USED��Ȼ����ΪYES
select * from v$object_usage;



�ű�5-89  λͼ��������ǰ׼��
drop table t purge;
create table t as select * from dba_objects;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
update t set object_id=rownum;
commit;



�ű�5-90  �۲�COUNT(*)ȫ��ɨ��Ĵ���
set autotrace on
set linesize 1000
select count(*) from t;
         
         

�ű�5-91  �۲�COUNT(*)����ͨ�����Ĵ���
create index idx_t_obj on t(object_id);
alter table T modify object_id not null;
set autotrace on
select count(*) from t;



�ű�5-92  �۲�COUNT(*)��λͼ�����Ĵ���
create bitmap index idx_bitm_t_status on t(status);
select count(*) from t;



�ű�5-93  ��λͼ�����뼴ϯ��ѯ����ǰ��׼��
SQL> drop table t purge;
SQL>create table t 
(name_id,
 gender not null,
 location not null,
 age_group not null,
 data
 )
 as
 select rownum,
        decode(ceil(dbms_random.value(0,2)),
               1,'M',
               2,'F')gender,
        ceil(dbms_random.value(1,50)) location,
        decode(ceil(dbms_random.value(0,3)),
               1,'child',
               2,'young',
               3,'middle_age',
               4,'old'),
         rpad('*',20,'*')
from dual
connect by rownum<=100000;



�ű�5-94  ��ѯ��ϯ��ѯ��Ӧ��ȫ��ɨ��Ĵ���
set linesize 1000
set autotrace traceonly
select *
    from t
    where gender='M'
    and location in (1,10,30)
    and age_group='child';



�ű�5-95  ���ּ�ϯ��ѯ�У�Oracle��ѡ���������
create index idx_union on t(gender,location,age_group);
select *
    from t
    where gender='M'
    and location in (1,10,30)
    and age_group='child';




�ű�5-96  ǿ�Ƽ�ϯ��ѯʹ������������ܸ���
select /*+index(t,idx_union)*/ *
    from t
    where gender='M'
    and location in (1,10,30)
    and age_group='child';



�ű�5-97 ��ϯ��ѯӦ�õ�λͼ�����������з�Ծ
create bitmap index gender_idx on t(gender);
create bitmap index location_idx on t(location);
create bitmap index age_group_idx on t(age_group);
select *
    from t
    where gender='M'
    and location in (1,10,30)
    and age_group='41 and over';



�ű�5-98  λͼ�����������������鲽��1
sqlplus ljb/ljb
select sid from v$mystat where rownum=1;
insert into t(name_id,gender,location ,age_group ,data) values (100001,'M',45,'child',rpad('*',20,'*'));



�ű�5-99 λͼ�����������������鲽��2
sqlplus ljb/ljb
select sid from v$mystat where rownum=1;
insert into t(name_id,gender,location ,age_group ,data) values (100002,'M',46, 'young', rpad('*',20,'*'));



�ű�5-100 λͼ�����������������鲽��3
select sid from v$mystat where rownum=1;
insert into t(name_id,gender,location ,age_group ,data) values (100003,'F',47, 'middle_age', rpad('*',20,'*'));



�ű�5-101  λͼ�����������������鲽��4
select sid from v$mystat where rownum=1;
insert into t(name_id,gender,location ,age_group ,data) values (100003,'F',48, ' old', rpad('*',20,'*'));




�ű�5-102  ����ɾ��location��age_group�е�λͼ������Ϊ��һ������׼��
--�ֱ���ղż���SESSIONִ�����²�������ɻ���
rollback;
--ɾ��location��age_group�е�λͼ����
drop index location_idx;
drop index age_group_idx;




�ű�5-103  ��������в����������
λͼ����֮�������ߵ�DELETE��ʵ��

--SESSION 1�������ߣ�
DELETE FROM T WHERE GENDER='M' AND LOCATION=25;
---SESSION 2(�����Ự) �����M�ļ�¼���������赲������������䶼�ᱻ��ֹ
insert  into t (name_id,gender,location ,age_group ,data) values (100001,'M',78, 'young','TTT');
update t set gender='M' WHERE LOCATION=25;
delete from T WHERE GENDER='M';

--�����ǿ��Խ��в����谭��
insert  into t (name_id,gender,location ,age_group ,data) values (100001,'F',78, 'young','TTT');
delete from  t where gender='F' ;
UPDATE T SET LOCATION=100 WHERE ROWID NOT IN ( SELECT ROWID FROM T WHERE GENDER='F' AND LOCATION=25) ; --updateֻҪ������λͼ�������ڵ��м���
        
        

�ű�5-104  ����λͼ�����ظ���ǰ׼������
drop table t purge;
create table t as select * from dba_objects;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
update t set object_id=rownum;
commit;



�ű�5-105  COUNT(*)�����ظ��ȵ�ʱ��Ȼ��ʹ��λͼ����
create bitmap index idx_bit_object_id on t(object_id);
select count(*) from t;



�ű�5-106  ǿ��COUNT(*)��λͼ���������ܸ���
select /*+index(t,idx_bit_object_id)*/ count(*) from t;



�ű�5-107  �⺯������ǰ׼��
drop table t purge;
create table t as select * from dba_objects;
create index idx_object_id on t(object_id);
create index idx_object_name on t(object_name);
create index idx_created on t(created);
select count(*) from t;



�ű�5-108  ������UPPER�������޷��õ�����
set autotrace traceonly
set linesize 1000
select * from t  where upper(object_name)='T' ;



�ű�5-109  ȥ���е�UPPER����������������
select * from t  where  object_name='T' ;



�ű�5-110  �����������󣬶�����UPPER����Ҳ���õ�����
create index idx_upper_obj_name on t(upper(object_name));
select * from t  where upper(object_name)='T' ;



�ű�5-111  �۲�ú�������������
select index_name, index_type from user_indexes where table_name='T';



�ű�5-112  �Ƚ�where object_id-10<=30��where object_id<=40д��������
set autotrace traceonly
set linesize 1000
select * from t where object_id-10<=30;



�ű�5-113  ��Ҳ������where object_id-10<=30�õ�����
create index idx_object_id_2 on t(object_id-10);
select * from t where object_id-10<=30;






