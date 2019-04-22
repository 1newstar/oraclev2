�ű�3-1  �鿴Oracle ��Ĵ�С
sqlplus "/ as sysdba"
show parameter db_block_size
select block_size
 from dba_tablespaces 
where tablespace_name='SYSTEM';

�ű�3-2  �鿴Oracle ���ݡ���ʱ���ع���ϵͳ��ռ����
sqlplus "/ as sysdba"
create tablespace TBS_LJB
datafile  'E:\ORADATA\ORA10\DATAFILE\TBS_LJB_01.DBF'  size 100M
extent management local
segment space management auto;
col file_name format a50
set linesize 366
SELECT file_name, tablespace_name, autoextensible,bytes
        FROM DBA_DATA_FILES
       WHERE TABLESPACE_NAME = 'TBS_LJB'
       order by substr(file_name, -12);
       
---��ʱ��ռ䣨�﷨��Щ�ر���TEMPORARY��TEMPFILE�Ĺؼ��֣�
CREATE TEMPORARY TABLESPACE  temp_ljb
     TEMPFILE 'E:\ORADATA\ORA10\DATAFILE\TMP_LJB.DBF' SIZE 100M;
SELECT FILE_NAME,BYTES,AUTOEXTENSIBLE FROM DBA_TEMP_FILES where tablespace_name='TEMP_LJB';

---�ع��α�ռ䣨�﷨��Щ�ر���UNDO�Ĺؼ��֣�
create undo tablespace undotbs2 datafile 'E:\ORADATA\ORA10\DATAFILE\UNDOTBS2.DBF' size 100M;
SELECT file_name,
 tablespace_name, 
autoextensible,
bytes/1024/1024 
     FROM DBA_DATA_FILES
     WHERE TABLESPACE_NAME = 'UNDOTBS2'
       order by substr(file_name, -12); 

---ϵͳ��ռ䣨Oracle 10g��ϵͳ��ռ仹������SYSAUX��Ϊ����ϵͳ��ռ�ʹ�ã�
SELECT file_name, 
tablespace_name,
 autoextensible,bytes/1024/1024
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME LIKE 'SYS%'
 order by substr(file_name, -12);

---ϵͳ��ռ���û���ռ䶼�������ñ������ݵı�ռ�
select tablespace_name,
contents                                
  from dba_tablespaces                                         
 where tablespace_name in                                      
       ('TBS_LJB', 'TEMP_LJB', 'UNDOTBS2', 'SYSTEM', 'SYSAUX');




�ű�3-3  Oracle ���û�����Ȩ������
---sysdba�û���¼������ljb�û����ڣ���ɾ��
sqlplus "/ as sysdba"
drop user ljb cascade;
---���û���������ǰ���ı�ռ�tbs_ljb����ʱ��ռ�temp_ljb��Ϊljb�û���Ĭ��ʹ�ÿռ䡣
create user ljb 
identified by ljb 
default tablespace tbs_ljb 
temporary tablespace temp_ljb;
---��Ȩ�����Ҹ����Ȩ�޸�ljb�û�������м�ֻ���ڷ�����������ʵ�飩
grant dba to ljb;
--���Ե�¼ljb�û���
connect ljb/ljb


�ű�3-4  Oracle ��extent���
---����t��ע�����û��ָ����ռ䣬�����û�ljb��Ĭ�ϱ�ռ䣩
sqlplus ljb/ljb
drop table t purge;
create table t (id int)  tablespace tbs_ljb;
---��ѯ�����ֵ��ȡextent�����Ϣ
select segment_name,
extent_id,
tablespace_name,
bytes/1024/1024,blocks 
from user_extents 
where segment_name='T'  

----�������ݺ�����۲�,������ԭ����1��������Ϊ28����
insert into t select rownum from dual connect by level<=1000000;
commit;
select segment_name,
extent_id,
bytes/1024/1024,blocks 
from user_extents 
where segment_name='T' ; 


�ű�3-5  Oracle ��segment���
---����t��
sqlplus ljb/ljb
drop table t purge;
create table t (id int) tablespace tbs_ljb;

---��ѯ�����ֵ��ȡsegment�����Ϣ
select segment_name, 
segment_type,
tablespace_name,
blocks,
extents,bytes/1024/1024 
from user_segments  
where segment_name = 'T';

---�������ݺ�����۲�
insert into t select rownum from dual connect by level<=1000000;
commit;

---���������¼�󣬷���ȷʵ�б仯��BLOCKS��EXTENTS�������ˣ�����1������Ϊ28�����������ԭ����8������Ϊ1664�����εĴ�С��0.0625MB����Ϊ13MB���������£�
select segment_name, segment_type,tablespace_name,blocks,extents,bytes/1024/1024 
from user_segments  where segment_name = 'T';

---�۲������Σ�����IDX_ID����ε�segment_type ΪINDEX��
create index idx_id on t(id);

select segment_name, 
segment_type,
tablespace_name,
blocks,
extents,
bytes/1024/1024 
from user_segments  
where segment_name = 'IDX_ID';

select count(*) from   user_extents  WHERE segment_name='IDX_ID';


�ű�3-6  Oracle�����ò�ͬ��С�Ŀ�
show parameter cache_size

�ű�3-7  ����BLOCK_SIZEΪ16K�Ŀ�
alter system set db_16k_cache_size=100M;
show parameter 16k

�ű�3-8  ������СΪ16K�Ŀ��½���ռ�
create tablespace TBS_LJB_16k 
blocksize 16K
datafile  'E:\ORADATA\ORA10\DATAFILE\TBS_LJB_16k_01.DBF' size 100M  
autoextend on  
extent management local 
segment space management auto;
----�۲췢�֣�TBS_LJB_16K�����ռ��Ȼ��ͬ��ԭ����TBS_LJB2��ռ�ģ���Ĵ�С��ȻΪ16K
select tablespace_name,
block_size
 from dba_tablespaces 
where tablespace_name in ('TBS_LJB2','TBS_LJB_16K');


�ű�3-9  ��UNIFORM SIZEΪ10M�ı�ռ�
create tablespace TBS_LJB2 
datafile  'E:\ORADATA\ORA10\DATAFILE\TBS_LJB2_01.DBF'  size 100M  
extent management local 
uniform size 10M 
segment space management auto;

�ű�3-10  �۲�UNIFORM SIZEΪ10M�ı�ռ�ķ������
sqlplus ljb/ljb
create table t2 (id int ) tablespace TBS_LJB2;
select segment_name,
extent_id,
tablespace_name,
bytes/1024/1024,blocks 
from user_extents 
where segment_name='T2';
--������������������
insert into t2 select rownum from dual connect by level<=1000000;
commit;
--�ٹ۲�EXTENT�ķ������
select segment_name,
extent_id,
tablespace_name,
bytes/1024/1024,blocks 
from user_extents 
where segment_name='T2';


�ű�3-11  �۲��ռ��ʣ�����
select sum(bytes) / 1024 / 1024
     from dba_free_space
     where tablespace_name = 'TBS_LJB';
     
�ű�3-12  �۲��ռ������������
select  sum(bytes) / 1024 / 1024
  from dba_data_files
  where tablespace_name = 'TBS_LJB' ;

�ű�3-13  ���ϲ����¼��ģ���ռ䲻��ĳ���
insert into t select rownum from dual connect by level<=1000000;
commit;
insert into t select rownum from dual connect by level<=1000000;

�ű�3-14  ��ռ䲻�㱨��ʱ�ٹ۲�һ�±�ռ�ʣ�����
select sum(bytes) / 1024 / 1024
      from dba_free_space
     where tablespace_name = 'TBS_LJB';


�ű�3-15  ��ռ�����ķ���
ALTER TABLESPACE  TBS_LJB 
    ADD DATAFILE  'E:\ORADATA\ORA10\DATAFILE\TBS_LJB_02.DBF' SIZE  100M;
     

�ű�3-16  ��ռ����������۲�ʣ��ռ����
select sum(bytes) / 1024 / 1024
      from dba_free_space
      where tablespace_name = 'TBS_LJB';

�ű�3-17  �۲��ռ��Ƿ����Զ���չ��
col file_name format a50
SELECT file_name, 
      tablespace_name,
      autoextensible,bytes/1024/1024                          
           FROM DBA_DATA_FILES                                                      
         WHERE TABLESPACE_NAME = 'TBS_LJB';


�ű�3-18  ����ռ����Ը���Ϊ�Զ���չ
alter database datafile 'E:\ORADATA\ORA10\DATAFILE\TBS_LJB_02.DBF'  autoextend on;


�ű�3-19  �����鿴��ռ����ԣ������Ѿ�����Ϊ�Զ���չ
col file_name format a50                                                         
SELECT file_name,
tablespace_name, 
autoextensible,
bytes/1024/1024                          
  FROM DBA_DATA_FILES                                                      
  WHERE TABLESPACE_NAME = 'TBS_LJB';


�ű�3-20  �Զ���չ���õ��ı�ռ䲻�㣬����ҲҪС�Ĵ��̿ռ����
insert into t select rownum from dual connect by level<=1000000;
insert into t select rownum from dual connect by level<=1000000;
insert into t select rownum from dual connect by level<=1000000;
insert into t select rownum from dual connect by level<=1000000;
commit;
SELECT file_name,
tablespace_name, 
autoextensible,
bytes/1024/1024                          
 FROM DBA_DATA_FILES                                                      
WHERE TABLESPACE_NAME = 'TBS_LJB'; 


�ű�3-21  ɾ����ռ��Զ�ɾ�������ļ����� 
drop tablespace TBS_LJB 
including contents and datafiles;

create tablespace TBS_LJB 
datafile  'E:\ORADATA\ORA10\DATAFILE\TBS_LJB_01.DBF' size 100M  
autoextend on  
extent management local 
segment space management auto;


�ű�3-22  ���Զ���չ��ռ�ɿ��������չ������
create tablespace TBS_LJB3 
datafile  'E:\ORADATA\ORA10\DATAFILE\TBS_LJB3_01.DBF' size 100M  
autoextend on  
next 64k
maxsize 5G;


�ű�3-23  �鿴���ݿ⵱ǰ���ûع���
sqlplus "/ as sysdba"
 show parameter undo
 
 
�ű�3-24  �鿴���ݿ��м����ع���
select tablespace_name, 
      sum(bytes) / 1024 / 1024
      from dba_data_files
      where tablespace_name in ('UNDOTBS1', 'UNDOTBS2')
      group by tablespace_name;

�ű�3-25  �鿴���ݿ��м����ع��Σ����ó����ǵĴ�С
select tablespace_name, 
      sum(bytes) / 1024 / 1024
      from dba_data_files
      where tablespace_name in ('UNDOTBS1', 'UNDOTBS2')
      group by tablespace_name;


�ű�3-26  �л��ع��εķ���
alter system set undo_tablespace=undotbs2 scope=both;

�ű�3-27  �л��ع��κ��ٲ鿴��ǰ�ع�������һ��
show parameter undo


�ű�3-28  ��ǰ���ûع����޷�ɾ��
drop tablespace undotbs2;
drop tablespace undotbs1 including contents and datafiles;

�ű�3-29  �鿴��ʱ��ռ��С
select tablespace_name, 
      sum(bytes) / 1024 / 1024
      from dba_temp_files
     group by tablespace_name;


�ű�3-30  ���û�ʱ��ָ����ռ����ʱ��ռ�
create user ljb 
identified by ljb 
default tablespace tbs_ljb 
temporary tablespace temp_ljb;


�ű�3-31  �鿴�û���Ĭ�ϱ�ռ����ʱ��ռ�
select DEFAULT_TABLESPACE,TEMPORARY_TABLESPACE from dba_users where username='LJB';


�ű�3-32  �鿴�����û�����ʱ��ռ�
select default_tablespace,
      temporary_tablespace 
      from dba_users 
where username='SYSTEM';


�ű�3-33  ָ��SYSTEM�û��л���ָ������ʱ��ռ�
sqlplus "/ as sysdba"
alter user system temporary tablespace TEMP_LJB;
select default_tablespace,
       temporary_tablespace 
  from dba_users 
  where username='SYSTEM';



�ű�3-34  �۲첻ͬ�û��ڲ�ͬ��ʱ��ռ�ķ������
select TEMPORARY_TABLESPACE,COUNT(*) 
  from dba_users 
  GROUP BY TEMPORARY_TABLESPACE; 


�ű�3-35  �л������û���ָ����ʱ��ռ�
alter database default temporary tablespace temp_ljb;


�ű�3-36  �����û�Ĭ����ʱ��ռ䶼���л���TEMP_LJB
select TEMPORARY_TABLESPACE,COUNT(*) 
  from dba_users 
  GROUP BY TEMPORARY_TABLESPACE;


�ű�3-37  ��ѯ��ʱ��ռ����
select * from dba_tablespace_groups;


�ű�3-38  �½���ʱ��ռ���
create temporary tablespace temp1_1 tempfile  'E:\ORADATA\ORA10\DATAFILE\TMP1_1.DBF'  size 100M  tablespace group tmp_grp1;
create temporary tablespace temp1_2 tempfile  'E:\ORADATA\ORA10\DATAFILE\TMP1_2.DBF'  size 100M  tablespace group tmp_grp1;
create temporary tablespace temp1_3 tempfile  'E:\ORADATA\ORA10\DATAFILE\TMP1_3.DBF'  size 100M  tablespace group tmp_grp1;


�ű�3-39  �ٲ鿴��ʱ��ռ��������������3����Ա
select * from dba_tablespace_groups;


�ű�3-40  ��ָ��ĳ��ʱ��ռ��Ƶ���ʱ��ռ���
alter tablespace temp_ljb tablespace group tmp_grp1;


�ű�3-41  �ƶ���ʱ��ռ�󣬼����鿴��ʱ��ռ���
select * from dba_tablespace_groups;
      

�ű�3-42  ���û�ָ������ʱ��ռ�
alter user LJB temporary tablespace  tmp_grp1;


�ű�3-43  �鿴ָ���û�����ʱ��ռ�
select temporary_tablespace 
  from dba_users 
  where username='LJB';


�ű�3-44  ��SQLִ�л���������
select a.table_name, b.table_name
  from all_tables a, all_tables b
 order by a.table_name;

�ű�3-45  �����ִ�д��������SQL
SELECT USERNAME,
      SESSION_NUM,
      TABLESPACE 
  FROM V$SORT_USAGE;
  
�ű�3-46  �鿴������SESSIONʹ�õ���ʱ��ռ����
SELECT USERNAME,
    SESSION_NUM,
    TABLESPACE 
  FROM V$SORT_USAGE;


�ű�3-47  ��ʱ��ռ���Ҳ�������ö��
create temporary tablespace temp2_1 tempfile  'E:\ORADATA\ORA10\DATAFILE\TMP2_1.DBF'  size 100M  tablespace group tmp_grp2;
create temporary tablespace temp2_2 tempfile  'E:\ORADATA\ORA10\DATAFILE\TMP2_2.DBF'  size 100M  tablespace group tmp_grp2;
create temporary tablespace temp2_3 tempfile  'E:\ORADATA\ORA10\DATAFILE\TMP2_3.DBF'  size 100M  tablespace group tmp_grp2;
alter user YXL temporary tablespace  tmp_grp2;
  

�ű�3-48  �ֱ�ͳһ�ߴ���Զ���չ��������ռ�
set timing on
drop tablespace tbs_ljb_a including contents and datafiles;
drop tablespace tbs_ljb_b including contents and datafiles;
create tablespace TBS_LJB_A datafile  'D:\ORA11G\DATAFILE\TBS_LJB_A.DBF' size 1M autoextend on uniform size 64k;
create tablespace TBS_LJB_B datafile  'D:\ORA11G\DATAFILE\TBS_LJB_B.DBF' size 2G ;


�ű�3-49  �ֱ���������ͬ��ռ佨��
connect ljb/ljb
set timing on
CREATE TABLE t_a (id int) tablespace TBS_LJB_A; 
CREATE TABLE t_b (id int) tablespace TBS_LJB_B;


�ű�3-50  �ֱ�Ƚϲ�����ٶȲ���
insert into t_a select rownum from dual connect by level<=10000000;
insert into t_b select rownum from dual connect by level<=10000000;

�ű�3-51  �ٶȲ����ԭ��
select count(*) from user_extents where segment_name='T_A';
select count(*) from user_extents where segment_name='T_B';


�ű�3-52  ����uniformΪ64K��tablespace�Ĳ������
create tablespace TBS_LJB_C datafile  'E:\ORADATA\ORA10\DATAFILE\TBS_LJB_C_01.DBF' size 2G autoextend on uniform size 64k;
connect ljb/ljb
CREATE TABLE t_c (id int) tablespace TBS_LJB_C;
insert into t_c select rownum from dual connect by level<=10000000;


�ű�3-53  PCTFREE����׼��֮����
DROP TABLE EMPLOYEES PURGE;
CREATE TABLE EMPLOYEES AS SELECT * FROM HR.EMPLOYEES ;
desc EMPLOYEES;

�ű�3-54  PCTFREE����׼��֮�����ֶ�
alter table EMPLOYEES modify FIRST_NAME VARCHAR2(2000);
alter table EMPLOYEES modify LAST_NAME  VARCHAR2(2000);
alter table EMPLOYEES modify EMAIL VARCHAR2(2000);
alter table EMPLOYEES modify PHONE_NUMBER  VARCHAR2(2000);


�ű�3-55  PCTFREE����׼��֮���±�
UPDATE EMPLOYEES
  SET FIRST_NAME = LPAD('1', 2000, '*'), LAST_NAME = LPAD('1', 2000, '*'), EMAIL = LPAD('1', 2000, '*'),
  PHONE_NUMBER = LPAD('1', 2000, '*');
COMMIT;


�ű�3-56  PCTFREE����׼��֮�鿴�߼������
SET AUTOTRACE TRACEONLY
set linesize 1000
select * from EMPLOYEES;
 
 
�ű�3-57  PCTFREE����׼��֮������Ǩ�ƺ���߼������ 
CREATE TABLE EMPLOYEES_BK AS select * from EMPLOYEES;
SET AUTOTRACE TRACEONLY
set linesize 1000
select * from EMPLOYEES_BK;

�ű�3-58  �鿴EMPLOYEES��PCTREEֵ
select pct_free from user_tables where table_name='EMPLOYEES';

�ű�3-59  ����PCTFREE�ķ���
alter table EMPLOYEES  pctfree 20 ;
select pct_free from user_tables where table_name='EMPLOYEES';


�ű�3-60  ���ִ�����Ǩ�Ƶķ���
--���Ƚ�chaind_rows��ر����Ǳ���Ĳ���
--sqlplus "/ as sysdba"
sqlplus ljb/ljb
@?/rdbms/admin/utlchain.sql
----�����������EMPLOYEES���EMPLOYEES_BK����������������Ǩ�Ƶļ�¼���뵽chained_rows����
analyze table EMPLOYEES list chained rows into chained_rows;
analyze table EMPLOYEES_BK list chained rows into chained_rows;
select count(*)  from chained_rows where table_name='EMPLOYEES';
select count(*)  from chained_rows where table_name='EMPLOYEES_BK';

ע����Ҫ˵�����������ڻ��������⣬���������������ֵû�����𣬿ɿ��������·�����ȷ�ϣ�
drop table EMPLOYEES_TMP;
create table EMPLOYEES_TMP as select * from EMPLOYEES where rowid in (select head_rowid from chained_rows);
Delete from EMPLOYEES where rowid in (select head_rowid from chained_rows);
Insert into EMPLOYEES_BK select * from EMPLOYEES_TMP;
analyze table EMPLOYEES list chained rows into chained_rows;
select count(*)  from chained_rows where table_name='EMPLOYEES';
--��ʱ��ȡֵһ��Ϊ0�������ַ�������Ǩ���������϶���û����ģ�
---------------------------------------------------------------------------------

�ű�3-61  ������б��Ƿ������Ǩ�ƵĽű�
select 'analyze table '|| table_name ||' list chained rows into chained_rows;' from user_tables;
select * from chained_rows;


�ű�3-62  ��Ĵ�СӦ�û����������ֱ�8K��16K�ı�ռ䣩
drop tablespace TBS_LJB INCLUDING CONTENTS AND DATAFILES;
create tablespace TBS_LJB 
datafile  'E:\ORADATA\ORA10\DATAFILE\TBS_LJB_01.DBF'  size 1G;  

drop tablespace TBS_LJB_16K INCLUDING CONTENTS AND DATAFILES;
create tablespace TBS_LJB_16K
blocksize 16K 
datafile  'E:\ORADATA\ORA10\DATAFILE\TBS_LJB_16k_01.DBF'  size 1G; 


�ű�3-63  ��Ĵ�СӦ��׼����������16K��ռ佨��
drop table t_16k purge;
create table t_16k tablespace tbs_ljb_16k as select * from dba_objects ;
insert into t_16k  select * from t_16k;
insert into t_16k  select * from t_16k;
insert into t_16k  select * from t_16k;
insert into t_16k  select * from t_16k;
insert into t_16k  select * from t_16k;
insert into t_16k  select * from t_16k;
commit;
update t_16k set object_id=rownum ;
commit;
create index idx_object_id on t_16k(object_id);


�ű�3-64  ��Ĵ�СӦ��׼����������8K��ռ佨��
drop table t_8k purge;
create table t_8k tablespace  tbs_ljb as select * from dba_objects ;
insert into t_8k  select * from t_8k;
insert into t_8k  select * from t_8k;
insert into t_8k  select * from t_8k;
insert into t_8k  select * from t_8k;
insert into t_8k  select * from t_8k;
insert into t_8k  select * from t_8k;
commit;
update t_8k set object_id=rownum ;
commit;
create index idx_object_id_8k on t_8k(object_id);


�ű�3-65  BLOCKΪ16K��Ŀռ�ȫ��ɨ����
set linesize 1000
set timing on
select count(*) from t_16k;


�ű�3-66  BLOCKΪ 8K�ı�ռ��ȫ��ɨ����
select count(*) from t_8k;

�ű�3-67  BLOCK��СΪ 8K�ı�ռ������������
select * from t_8k where object_id=29;


�ű�3-68  BLOCK��СΪ 16K�ı�ռ������������
select * from t_16k where object_id=29;
