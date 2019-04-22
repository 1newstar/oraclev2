�ű�6-1  �о�Nested Loops Join���ʴ���ǰ׼��
DROP TABLE t1 CASCADE CONSTRAINTS PURGE; 
DROP TABLE t2 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE t1 (
     id NUMBER NOT NULL,
     n NUMBER,
     contents VARCHAR2(4000)
   )
   ; 
CREATE TABLE t2 (
     id NUMBER NOT NULL,
     t1_id NUMBER NOT NULL,
     n NUMBER,
     contents VARCHAR2(4000)
   )
   ; 
execute dbms_random.seed(0); 
INSERT INTO t1
     SELECT  rownum,  rownum, dbms_random.string('a', 50)
       FROM dual
     CONNECT BY level <= 100
      ORDER BY dbms_random.random; 
INSERT INTO t2 SELECT rownum, rownum, rownum, dbms_random.string('b', 50) FROM dual CONNECT BY level <= 100000
    ORDER BY dbms_random.random; 
COMMIT; 
select count(*) from t1;
select count(*) from t2;




�ű�6-2  �о�Nested Loops Join��T2������100��
SELECT /*+ leading(t1) use_nl(t2)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id;

������������������statistics_level=all�ķ�ʽ���۲����±���������ִ�мƻ���

Set linesize 1000
alter session set statistics_level=all ;
SELECT /*+ leading(t1) use_nl(t2)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id;
--��ȥ��¼���
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-3  ������䣬���T2������2��
Set linesize 1000
alter session set statistics_level=all ;
SELECT /*+ leading(t1) use_nl(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n in(17, 19);
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-4  ����������䣬���T2������1��
Set linesize 1000
alter session set statistics_level=all ;
SELECT /*+ leading(t1) use_nl(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19;
SQL> select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-5  ��д�����T2���Ȼ������0��
SELECT /*+ leading(t1) use_nl(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 999999999;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));


�ű�6-6  ����T2�����ʴ�����ͬ��ԭ��
---����T2��Ϊɶ������100��
select count(*) from t1;
---����T2��Ϊɶ������2��
select count(*) from t1 where t1.n in (17,19);
---����T2��Ϊɶ������1��
select count(*) from t1 where t1.n = 19;
---����T2��Ϊɶ������0��
select count(*) from t1 where t1.n = 999999999;




�ű�6-7  Hash Join�� T2��ֻ�ᱻ����1�λ�0��
SELECT /*+ leading(t1) use_hash(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));


�ű�6-8  Hash Join��T2������0�ε����
SELECT /*+ leading(t1) use_hash(t2)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id
and t1.n=999999999;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));


�ű�6-9  Hash Join��T1��T2������0�ε����
SELECT /*+ leading(t1) use_hash(t2)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id
and 1=2;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));


�ű�6-10  Merge Sort Join���������Hash Joinһ��
SELECT /*+ ordered use_merge(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));


�ű�6-11  Ƕ��ѭ�����ӵ�t1���ȷ��ʵ����
alter session set statistics_level=all;
SELECT /*+ leading(t1) use_nl(t2)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-12  Nested Loops Join��t2���ȷ��ʵ����
alter session set statistics_level=all;
SELECT /*+ leading(t2) use_nl(t1)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-13  HASH���ӵ�t1���ȷ��ʵ����
alter session set statistics_level=all;
SELECT /*+ leading(t1) use_hash(t2)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id
and t1.n=19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-14  Hash Join��t2���ȷ������
SELECT /*+ leading(t2) use_hash(t1)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id
and t1.n=19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-15  Merge Sort Join��t1���ȷ������
alter session set statistics_level=all;
SELECT /*+ leading(t1) use_merge(t2)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id
and t1.n=19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-16  Merge Sort Join��t2���ȷ������
SELECT /*+ leading(t2) use_merge(t1)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id
and t1.n=19;

select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-17  Merge Sort Joinȡ�����ֶε����
alter session set statistics_level=all ;
SELECT /*+ leading(t2) use_merge(t1)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id
and t1.n=19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-18  Merge Sort Joinȡ�����ֶε����
SELECT /*+ leading(t2) use_merge(t1)*/ t1.id
FROM t1, t2
WHERE t1.id = t2.t1_id
and t1.n=19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));




�ű�6-19  Hash Join��֧�ֲ���ֵ��������
explain plan for
    SELECT /*+ leading(t1) use_hash(t2)*/ *
    FROM t1, t2
    WHERE t1.id <> t2.t1_id
    AND t1.n = 19;

SELECT * FROM table(dbms_xplan.display);



�ű�6-20  Hash Join��֧�ִ��ڻ���С�ڵ���������
explain plan for
    SELECT /*+ leading(t1) use_hash(t2)*/ *
    FROM t1, t2
    WHERE t1.id > t2.t1_id
    AND t1.n = 19;

SELECT * FROM table(dbms_xplan.display);



�ű�6-21  Hash Join��֧��LIKE����������
explain plan for
    SELECT /*+ leading(t1) use_hash(t2)*/ *
    FROM t1, t2
    WHERE t1.id like t2.t1_id
    AND t1.n = 19;

SELECT * FROM table(dbms_xplan.display);



�ű�6-22  Merge Sort Join��֧�ֲ����ڵ���������
explain plan for
    SELECT /*+ leading(t1) use_merge(t2)*/ *
    FROM t1, t2
    WHERE t1.id<> t2.t1_id
    AND t1.n = 19;

SELECT * FROM table(dbms_xplan.display);



�ű�6-23  Merge Sort Join֧�ִ��ڻ���С�ڵ���������
explain plan for
    SELECT /*+ leading(t1) use_merge(t2)*/ *
    FROM t1, t2
    WHERE t1.id>t2.t1_id
    AND t1.n = 19;

SELECT * FROM table(dbms_xplan.display);




�ű�6-24  Merge Sort Join��֧��LIKE����������
explain plan for
    SELECT /*+ leading(t1) use_merge(t2)*/ *
    FROM t1, t2
    WHERE t1.id like t2.t1_id
    AND t1.n = 19;
SELECT * FROM table(dbms_xplan.display);




�ű�6-25  Nested Loops Join��������������
alter session set statistics_level=all ;
SELECT /*+ leading(t1) use_nl(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-26  ���������������������HINT��һ����Hash Join
alter session set statistics_level=all ;
SELECT *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));




�ű�6-27  �����Ż�����t1�����������������
CREATE INDEX t1_n ON t1 (n);



�ű�6-28  ��������������������Nested Loops Join������������
alter session set statistics_level=all ;
SELECT /*+ leading(t1) use_nl(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-29  �ٴζ����Ż�����ζ�t1�����������������
CREATE INDEX t2_t1_id ON t2(t1_id);



�ű�6-30  �����������������±������������˴��������
alter session set statistics_level=all ;
SELECT /*+ leading(t1) use_nl(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-31  ������������Oracle����HINT����Ȼѡ��Nested Loops Join
alter session set statistics_level=all ;
SELECT *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-32  ��������δ��������Merge Sort Join�����򲻿ɱ���
alter session set statistics_level=all ;
SELECT /*+ ordered use_merge(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



�ű�6-33  ����������������Merge Sort Join���������һ��
--Ȼ������
create index idx_t1_id on t1(id);
--����������¼����۲�
SELECT /*+ ordered use_merge(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));
