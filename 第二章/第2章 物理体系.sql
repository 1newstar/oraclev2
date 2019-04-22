�ű�2-1  SQL����״β�ѯ�����
drop table t ;
create table t as select * from all_objects;
create index idx_object_id on t(object_id);
set autotrace on
set linesize 1000
set timing on
select object_name from t where object_id=29;

�ű�2-2  ͬһSQL�ٴβ�ѯ����������
select object_name from t where object_id=29;

�ű�2-3  ����ǿ����ȫ��ɨ������
set autotrace on 
set linesize 1000
set timing on 
select /*+full(t)*/ object_name from t where object_id=29;
---�����ǹ�����ִ��һ��
select /*+full(t)*/ object_name from t where object_id=29;


�ű�2-4  �鿴SGA��PGA�ķ����С
sqlplus "/ as sysdba"
--10g
show parameter sga
--11g
show parameter memory


�ű�2-5  �鿴����غ����ݻ���صķ����С
show parameter shared_pool_size
show parameter db_cache_size  


�ű�2-6  �Ӳ���ϵͳ����������SAG�������
ipcs -m

�ű�2-7  �鿴��־�������ķ����С
show parameter log_buffer

�ű�2-8  �޸�SGA��С(scope=spfile��ʽ)
show parameter sga
alter system set sga_target=2000M scope=spfile;

�ű�2-9  �޸�SGA��С(scope=both��ʽ)
show parameter sga
alter system set sga_target=2000M scope=both;
show parameter sga

�ű�2-10  �޸�LOG_BUFFER����
show parameter log_buffer;
alter system set log_buffer=15000000  scope=memory ; 
alter system set log_buffer=15000000  scope=both;
alter system set  log_buffer=15000000  scope=spfile;
show parameter log_buffer;

�ű�2-11  �鿴Oracleʵ����
show parameter instance_name


�ű�2-12  �鿴Oracle�鵵����
ps -ef |grep arc

�ű�2-13  �鿴Oracle�鵵�Ƿ���
sqlplus "/ as sysdba"
archive log list;

�ű�2-14  ��Oracle�鵵��������
shutdown immediate
startup mount;
alter database archivelog;
alter database open;


�ű�2-15  �鿴�����Ƿ�ɹ�
archive log list;


�ű�2-16  �鿴Oracle�鵵����
ps -ef |grep arc

�ű�2-17  �鿴Oracle��spfile�������
show parameter spfile

�ű�2-18  Oracle����������
startup nomount
alter database mount;
alter database open;

�ű�2-19  Oracle�ر�
shutdown immediate

�ű�2-20  �۲�Oracle�رպ�Ĺ����ڴ����
ipcs -m

�ű�2-21  �۲�Oracle�������
ps -ef |grep itsmtest

�ű�2-22  ����Oracle��nomount״̬
sqlplus "/ as sysdba"
startup nomount


�ű�2-23  �۲�Oracle�������ڴ����ͽ������
ipcs -m
ps -ef |grep itmtest
 
 
�ű�2-24  �鿴���������ơ����ݡ���־���鵵���澯�ļ�
show parameter spfile;
show parameter control
sqlplus "/ as sysdba"
select file_name from dba_data_files;
select group#,member from v$logfile ; 
show parameter recovery
set linesize 1000
show parameter dump
--����·������߸���ʵ��������е���
cd /home/oracle/admin/itmtest/bdump
ls -lart alert*


�ű�2-25  �鿴����״̬
lsnrctl status


�ű�2-26  �ر�Oracle����
lsnrctl stop
 
 
�ű�2-27  �鿴�ر�Oracle���������� 
lsnrctl status


�ű�2-28  ����Oracle����
lsnrctl start


�ű�2-29  �������ɴ�����ǰ��׼������
sqlplus ljb/ljb
drop table t purge;
create table t ( x int );
--����������
alter system flush shared_pool;


�ű�2-30  �������ɴ�����ǰ����proc1
create or replace procedure proc1
as
begin
    for i in 1 .. 100000
    loop
        execute immediate
        'insert into t values ( '||i||')';
    commit;
    end loop;
end;
/ 


�ű�2-31  �״�����42����ɣ����ǵ����ٶ�
connect ljb/ljb
drop table t purge;
create table t ( x int );
alter system flush shared_pool;
set timing on
exec proc1 ;
select count(*) from t;


�ű�2-32  ԭ������Ϊδ�ð󶨱���
select t.sql_text, t.sql_id,t.PARSE_CALLS, t.EXECUTIONS
  from v$sql t
 where sql_text like '%insert into t values%';


�ű�2-33 ��2�θĽ�����proc1������а󶨱�����proc2
create or replace procedure proc2
as
begin
    for i in 1 .. 100000
    loop
        execute immediate
        'insert into t values ( :x )' using i;   
        commit;
    end loop;
end;
/


�ű�2-34  ��2�θĽ���8����ɣ�������Ħ��
drop table t purge;
create table t ( x int );
alter system flush shared_pool;
set timing on
exec proc2;
select count(*) from t;


�ű�2-35  ��3�θĽ�����proc2����ɾ�̬SQL��proc3
create or replace procedure proc3
as
begin
    for i in 1 .. 100000
    loop
     insert into t values (i);   
     commit;
    end loop;
end;
/


�ű�2-36  ��3�θĽ���6����ɣ�Ħ�б�����
drop table t purge;
create table t ( x int );
alter system flush shared_pool;
set timing on
exec proc3;
select count(*) from t;
 
�ű�2-37 ��4�θĽ�����proc3������ύ��ѭ�����proc4
create or replace procedure proc4
as
begin
    for i in 1 .. 100000
    loop
     insert into t values (i);   
    end loop;
  commit;
end;
/


�ű�2-38  ��4�θĽ���2����ɣ������䶯��
drop table t purge;
create table t ( x int );
alter system flush shared_pool;
set timing on
exec proc4;
select count(*) from t;


�ű�2-39  ��5���ü���д����0.25����ɣ�������ɻ�
drop table t purge;
create table t ( x int );
alter system flush shared_pool;
set timing on
insert into t select rownum from dual connect by level<=100000;
commit;
select count(*) from t;
 

�ű�2-40  ����׼����������д���������������Ŵ�100��
connect ljb/ljb
drop table t purge;
create table t ( x int );
alter system flush shared_pool;
set timing on
insert into t select rownum from dual connect by level<=10000000;
commit;


�ű�2-41  ��6�θĽ���ֱ��·���÷ɻ�����
drop table t purge;
alter system flush shared_pool;
set timing on
create table t as select rownum x from dual connect by level<=10000000;


�ű�2-42  ��7�θĽ�������ԭ���û����ɴ�
drop table t purge;
alter system flush shared_pool;
set timing on 
create table t nologging parallel 64 
as select rownum x from dual connect by level<=10000000;
