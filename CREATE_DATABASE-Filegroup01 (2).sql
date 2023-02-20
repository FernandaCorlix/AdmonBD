drop database library 
go 
CREATE DATABASE LIBRARY
ON PRIMARY
( NAME = LIB_DAT_PRIM,
   FILENAME = 'c:\data\LIBRARYPRIM01.mdf',
   SIZE = 10,
   MAXSIZE = 20,
   FILEGROWTH = 5 ),
   FILEGROUP Library01
( NAME = LIB_DAT_SEC,
   FILENAME = 'c:\data\LIBRARYSEC01.ndf',
   SIZE = 10,
   MAXSIZE = 20,
   FILEGROWTH = 5% )
LOG ON
( NAME = 'Sales_log',
   FILENAME = 'c:\data\LIBRARYlog01.ldf',
   SIZE = 10,
   MAXSIZE = 20,
   FILEGROWTH = 5 )
go 
/********************************************/
use library
/*exec sp_droptype member_no
exec sp_droptype title
exec sp_droptype title_no
exec sp_droptype isbn
exec sp_droptype zipcode*/

go
execute sp_addtype member_no ,'INT' ,'NOT NULL'
execute sp_addtype title  ,'varchar(20)' ,'NOT NULL'
execute sp_addtype title_no  ,'INT' ,'NOT NULL'
EXEC  sp_addtype isbn, 'smallint', 'NOT NULL'
EXEC  sp_addtype zipcode, 'char(10)'
go
/*****************************/

use library
go
create table member
(
member_no member_no primary key,
lastname char(20) not null,
middleinitial char(1)
)  

create table adult
(
member_no member_no primary key references member(member_no),
street char(20) not null,
zipcode zipcode check (zipcode like '[0-9][0-9][0-9][0-9][0-9]'),
city char(20),
state char(20),
phone_no char(20)
) on Library01

create table juvenile
(member_no member_no primary key references member(member_no),
 adult_member_no member_no references adult(member_no),
 birthdate datetime not null
) on SalesGroup1

create table title
(
title_no title_no primary key,
title title not null,
author char(20) not null,
synopsis text 
) on Library01


 
GO


CREATE TABLE item 
(
 isbn isbn PRIMARY KEY,
 title_no title_no references title(title_no),
 idioma VARCHAR(20) NOT NULL,
 cover VARCHAR(20) NULL,
 loanable char(2)
) on Library01
go
CREATE TABLE COPY 
(
isbn isbn,
copy_no int not null,
title_no title_no references title(title_no),
on_loan char (2),
primary key (isbn,copy_no)
) 
go
CREATE TABLE loan 
(
isbn isbn, 
copy_no int not null,
title_no int not null references title(title_no),
member_no int not null references member(member_no),
out_date datetime not null,
due_date datetime not null,
primary key (isbn, copy_no, out_date),
foreign key (isbn, copy_no) references copy (isbn, copy_no)
)
go
create table reservation
(
isbn isbn references item(isbn),
member_no member_no references member(member_no),
log_date datetime,
remarks varchar(100)
primary key (isbn, member_no)
) on Library01

go
--instruccion para ver que tabla se encuentra en los archivos de datos.
select 'owner'=user_name(o.uid) 
,'table_name'=object_name(i.id)
,'filegroup'=f.name ,'file_name'=d.physical_name
,'dataspace'=s.name from sys.sysindexes i
,sys.sysobjects o,sys.filegroups f 
,sys.database_files d, sys.data_spaces s
where objectproperty(i.id,'IsUserTable') = 1
and i.id = o.id
and f.data_space_id = i.groupid
and f.data_space_id = d.data_space_id
and f.data_space_id = s.data_space_id

GO