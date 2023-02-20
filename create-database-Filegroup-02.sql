--Ejemplo 02. Creacion de una Bds con Filegroups.
drop database mydb 
go 
CREATE DATABASE mydb 
ON PRIMARY
( NAME = mydb,
FILENAME = 'C:\data\mydb.mdf' ,
SIZE = 2048KB , 
FILEGROWTH = 1024KB ),
FILEGROUP Index_FG
( NAME = mydb_index1,
FILENAME = 'c:\data\mydb_index1.ndf' ,
SIZE = 2048KB , 
FILEGROWTH = 1024KB ),
FILEGROUP UserData_FG
( NAME = mydb_userdata1,
FILENAME = 'c:\data\mydb_userdata1.ndf' ,
SIZE = 2048KB ,
FILEGROWTH = 1024KB ),
( NAME = mydb_userdata2,
FILENAME = 'c:\data\mydb_userdata2.ndf' ,
SIZE = 2048KB , 
FILEGROWTH = 1024KB ),
( NAME = mydb_userdata3,
FILENAME = 'c:\data\mydb_userdata3.ndf' ,
SIZE = 2048KB ,
 FILEGROWTH = 1024KB )
LOG ON
( NAME =mydb_log,
FILENAME = 'c:\data\mydb_log.ldf' ,
SIZE = 1024KB , 
FILEGROWTH = 10%)
Go
use mydb 
go 
CREATE TABLE dbo.Table1
(TableId int NULL,
TableDesc varchar(50) NULL) on UserData_FG
Go
CREATE CLUSTERED INDEX [CI_Table1_TableID] ON [dbo].Table1
( [TableId] ASC)
ON Index_FG
go 
CREATE TABLE dbo.Table2 --Se crea en el grupo por default que es el primary.
(TableId int NULL,
TableDesc varchar(50) NULL) 
go 
--instruccion para cambiar al grupo por default.
ALTER DATABASE mydb MODIFY FILEGROUP UserData_FG DEFAULT
go 
--esta nueva tabla se crea en el nuevo grupo por default.
CREATE TABLE dbo.Table3 --Se crea en el nuevo grupo por default UserData_FG.
(TableId int NULL,
TableDesc varchar(50) NULL) 

--Consulta  para ver donde se encuentran las tablas 
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