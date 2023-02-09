

--ejercicios para quitar  database bookrmark 
USE tempdb
GO


drop table Oneindex
go
-- Create Table OneIndex with few columns

CREATE TABLE OneIndex (ID INT,
FirstName VARCHAR(100),
LastName VARCHAR(100),
City VARCHAR(100))
GO

INSERT INTO OneIndex (ID,FirstName,LastName,City)
SELECT TOP 100000 ROW_NUMBER() OVER (ORDER BY a.name) RowID,
CASE WHEN ROW_NUMBER() OVER (ORDER BY a.name)%3 = 1 THEN 'rosa'
ELSE 'rosa' END,
CASE WHEN ROW_NUMBER() OVER (ORDER BY a.name)%2 = 1 THEN 'Smith'
ELSE 'Brown' END,
CASE
WHEN ROW_NUMBER() OVER (ORDER BY a.name)%1000 = 1 THEN 'Las Vegas'
WHEN ROW_NUMBER() OVER (ORDER BY a.name)%10 = 1 THEN 'New York'
WHEN ROW_NUMBER() OVER (ORDER BY a.name)%10 = 5 THEN 'San Marino'
WHEN ROW_NUMBER() OVER (ORDER BY a.name)%10 = 3 THEN 'Los Angeles'
ELSE 'Houston' END
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
GO


CREATE NONCLUSTERED INDEX [IX_OneIndex_City] ON [dbo].[OneIndex] (
[City] ASC ) ON [PRIMARY] 
GO

--crear un indice cluatered
CREATE CLUSTERED INDEX [IX_OneIndex_ID] ON [dbo].[OneIndex] (
[ID] ASC ) ON [PRIMARY] 

--la tabla esta ordenada por el campo ID
select * from oneindex

--Explica el plan de ejecucion para esta consulta. 
--La explicacion debe detallar por que realiza un table scan o index Seek. 
--Por que realiza un Key lookup y un nested loop--
SELECT ID, FirstName
FROM OneIndex
WHERE City = 'Las Vegas'


--Explica el plan de ejecucion para esta consulta. 
--La explicacion debe detallar por que realiza un table scan o index Seek. 
--Por que esta consulta no realiza un Key lookup y un nested loop--
SELECT ID, FirstName
FROM OneIndex
WHERE City = 'Houston'
GO



--lAS CONSULA SON SELECTIVAS (SI O NO)?. POR QUE ESTA CONSULTA NO REALIZA UN INDEX SEEK.
--QUE DEBES HACER PARA QUE LA CONSULTA REALICE UN INDEX SEEK 
SELECT ID, FirstName
FROM OneIndex
WHERE Upper(City) = 'LAS VEGAS'
GO
SELECT ID, FirstName
FROM OneIndex
WHERE City LIKE  '%LAS VEGAS%'
GO
SELECT ID, FirstName
FROM OneIndex
WHERE City LIKE  'LAS VEGAS'
GO



CREATE NONCLUSTERED INDEX [IX_OneIndex_firstame] ON [dbo].[OneIndex] (
FirstName
) ON [PRIMARY]
go
--Explica el plan de ejecucion para esta consulta. Por que realiza un index Seek por ciudad.
SELECT *
FROM OneIndex
WHERE City = 'Las Vegas' and firstname = 'Rosa'


GO
insert into Oneindex values (200000, 'alma','sanchez','culiacan')
go
--Explica el plan de ejecucion para esta consulta. Por que realiza un index Seek.

SELECT ID, FirstName
FROM OneIndex
WHERE  firstname = 'alma'
go

SELECT *
FROM OneIndex
WHERE City = 'Las Vegas' and firstname = 'alma'
go

SELECT *
FROM OneIndex
WHERE City = 'Las Vegas' or firstname = 'alma'

go
SELECT *
FROM OneIndex
WHERE City = 'Las Vegas' or City = 'houston'
go

SELECT *
FROM OneIndex
WHERE City = 'Las Vegas' or Lastname = 'Sanchez'
go

-- Es Selectivo --
SELECT *
FROM OneIndex
WHERE City = 'Las Vegas' and Lastname = 'Sanchez'

--crear un indice para mejorar el plan anterior 
--explica el plan de ejecucion para la siguiente consulta con el indice nuevo. 
--Que es el index covering y por que no realiza un key lookup.
CREATE NONCLUSTERED INDEX [IX_OneIndex_Cover] ON [dbo].[OneIndex] (
City, FirstName, ID
) ON [PRIMARY]

 GO

 -- Se pone city en el where por que es el primero del nonclustered
 SELECT ID, FirstName
FROM OneIndex
WHERE City = 'Las Vegas'
GO

--crear un indice nonclustered con el orden de las columnas invertidas 
--este indice no es igual al anterior 
--Explica que esta pasando en este ejemplo.  
--Por que no funciona el index covering
drop index OneIndex.IX_OneIndex_Cover
go
CREATE NONCLUSTERED INDEX [IX_OneIndex_Cover2] ON [dbo].[OneIndex] (
FirstName, ID, City
) ON [PRIMARY]
go


-- Este no funciona por que el primer valor es el FirstName y en el where se encuentra el city
 SELECT ID, FirstName
FROM OneIndex
WHERE City = 'Las Vegas'
GO

--Sintaxis para el index covering.
--Esta sintaxis se creo para no batallar en el acomodo, en el include se pone para incluirlos, con esto
-- es para que la consulta quede cubierta sin importar como se acomode el indice 
CREATE NONCLUSTERED INDEX [IX_OneIndex_Include] ON [dbo].[OneIndex] (
City
) INCLUDE (FirstName,ID) ON [PRIMARY] 
GO

 SELECT ID, FirstName
FROM OneIndex
WHERE City = 'culiacan'
GO

 SELECT ID, FirstName
FROM OneIndex
WHERE City >= 'culiacan'
GO

-- Cuando dice que es el 100% es por que todo se encontro en el indice
 SELECT ID, FirstName
FROM OneIndex
WHERE City <= 'culiacan'
GO

--Explica si la eleccion del ID para formar un indice clustered fue la correcta.(indice creado al inicio del 
--ejercicio.

