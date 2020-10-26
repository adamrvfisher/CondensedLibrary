--Business Database
--Written in SQL Server Management Studio

--Switch Database
USE master;

--Delete Database
IF EXISTS
(
	SELECT name
	FROM sys.databases
	WHERE name = N'BusinessDatabase'
)
DROP DATABASE BusinessDatabase
GO

--Create database
IF NOT EXISTS
(
	SELECT name
	FROM sys.databases
	WHERE name = N'BusinessDatabase'
)
CREATE DATABASE BusinessDatabase;
GO

USE BusinessDatabase;
GO

--Database name
SELECT db_name() AS DatabaseName
GO

--Create Catalogue table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Catalogue'
)
	CREATE TABLE BusinessDatabase.dbo.Catalogue
		(
			SKUID int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
			SKUName nvarchar(100) NULL,
			Price decimal(18, 2) NOT NULL,
			UnitsOnHand int NOT NULL,
			UnitsOnOrder int NULL CHECK (UnitsOnOrder < 100)
		)

--Clear CatalogueTableInsert stored procedure
IF OBJECT_ID('dbo.CatalogueTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.CatalogueTableInsert
GO

--Create CatalogueTableInsert stored procedure
CREATE PROCEDURE dbo.CatalogueTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Catalogue)
			BEGIN
				SELECT 'Catalogue table is populated.' AS CatalogueTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Catalogue table is not populated - Inserting values.' AS CatalogueTableStatus
				INSERT INTO BusinessDatabase.dbo.Catalogue(
					SKUName, Price, UnitsOnHand, UnitsOnOrder
					)
				VALUES('Mango', .99, 11, 22),
					  ('Pineapple', 1.99, 5, 14),
					  ('Nectarine', 1.59, 0, 0),
					  ('PricelessTreasure', 9.95, 1, NULL)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Catalogue table insert.' 
	END CATCH
GO

--Run CatalogTableInsert stored procedure
EXECUTE dbo.CatalogueTableInsert
GO

--Clear InsertCatalog stored procedure
IF OBJECT_ID('dbo.InsertCatalogue', 'P') IS NOT NULL
	DROP PROCEDURE dbo.InsertCatalogue
GO

--Create InsertCatalogue stored procedure
CREATE PROCEDURE dbo.InsertCatalogue
	@SKUName nvarchar(100),
	@Price decimal(18, 2),
	@UnitsOnHand int,
	@UnitsOnOrder int
AS 
	BEGIN 
		INSERT INTO BusinessDatabase.dbo.Catalogue(SKUName, Price, UnitsOnHand, UnitsOnOrder)
		VALUES(@SKUName, @Price, @UnitsOnHand, @UnitsOnOrder)
	END
GO

--Alter procedure InsertCatalogue
ALTER PROCEDURE dbo.InsertCatalogue
	@SKUName nvarchar(100),
	@Price decimal(18, 2),
	@UnitsOnHand int,
	@UnitsOnOrder int
AS 
	BEGIN 
		BEGIN TRY
			INSERT INTO BusinessDatabase.dbo.Catalogue(SKUName, Price, UnitsOnHand, UnitsOnOrder)
			VALUES(@SKUName, @Price, @UnitsOnHand, @UnitsOnOrder)
		END TRY
		BEGIN CATCH
			THROW 50001, 'The catalogue item could not be created', 1
		END CATCH
	END
GO

/*
--Execute InsertCataloguestored procedure
EXECUTE dbo.InsertCatalogue
		@SKUName = 'Orange', 
		@Price = 2.99, 
		@UnitsOnHand = 2, 
		@UnitsOnOrder = 101 --Check violation
GO
*/

--Create Cities table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Cities'
)
	CREATE TABLE Cities
		(
			CityID int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
			CityName nvarchar(50),
			AverageTemperature int
		)
GO

--Clear CitiesTableInsert stored procedure
IF OBJECT_ID('dbo.CitiesTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.CitiesTableInsert
GO

--Create CitiesTableInsert stored procedure
CREATE PROCEDURE dbo.CitiesTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Cities)
			BEGIN
				SELECT 'Cities table is populated.' AS CitiesTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Cities table is not populated - Inserting values.' AS CitiesTableStatus
					INSERT INTO BusinessDatabase.dbo.Cities(CityName, AverageTemperature)
					VALUES('MegaMetropolis', 85),
						  ('VoluminousVillage', 60),
						  ('TinyTown', 32),
						  ('Los Angeles', 80),
						  ('Red Bank', 68),
						  ('Belfast', 43),
						  ('Portland', 53)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Cities table insert.' 
	END CATCH
GO

--Run CitiesTableInsert stored procedure
EXECUTE dbo.CitiesTableInsert
GO

--Create Clients table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Clients'
)
	CREATE TABLE BusinessDatabase.dbo.Clients
		(
			ClientID int IDENTITY(1, 1) PRIMARY KEY,
			ClientName varchar(50) NOT NULL,
			ClientType varchar(50) NOT NULL,
			OnboardDate date NOT NULL,
			CreditLimit money CHECK(CreditLimit < 15000),
			PrimaryContact nvarchar(50),
			MailingCityID int,
			BillingCityID int,
			HasCreditTerms bit,
			VolumeDiscountPercentage int NOT NULL CHECK(VolumeDiscountPercentage <= 8),
			PhoneNumber nvarchar(20)
		)

--Clear ClientsTableInsert stored procedure
IF OBJECT_ID('dbo.ClientsTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ClientsTableInsert
GO

--Create ClientsTableInsert stored procedure
CREATE PROCEDURE dbo.ClientsTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Clients)
			BEGIN
				SELECT 'Clients table is populated.' AS ClientsTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Clients table is not populated - Inserting values.' AS ClientsTableStatus
					INSERT INTO BusinessDatabase.dbo.Clients(ClientName, ClientType, OnboardDate, CreditLimit, PrimaryContact, 
						    MailingCityID, BillingCityID, HasCreditTerms, VolumeDiscountPercentage, PhoneNumber)
					VALUES('Custom Packaging World', 'CO', '2017-05-25', 9000, 'D. Bobby', 1, 1, 1, 8, '888-324-1029'),
						  ('Dave Greenberg', 'LLP', '2018-12-02', NULL, 'D. Greenberg', 2, 2, 0, 0, '777-453-3785'),
						  ('Flying Solo', 'SP', '2019-11-15', 7500, 'D. Erp', 3, 4, 1, 2, '111-675-5648'),
						  ('Sushi Bros', 'LP', '2020-04-28', 1000, 'D. Keehada', 5, 6, 1, 1, '222-142-8909')
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Clients table insert.' 
	END CATCH
GO

--Run ClientsTableInsert stored procedure
EXECUTE dbo.ClientsTableInsert
GO

--Clear ModifyCompanyName stored procedure
IF OBJECT_ID('dbo.ModifyCompanyName', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ModifyCompanyName
GO

--Create ModifyCompanyName stored procedure
CREATE PROCEDURE dbo.ModifyCompanyName @clientID int, @NewName nvarchar(40)
AS
	IF EXISTS(
		SELECT ClientID FROM BusinessDatabase.dbo.Clients 
		WHERE ClientID = @clientID
		)
		UPDATE BusinessDatabase.dbo.Clients
		SET ClientName = @NewName
		WHERE ClientID = @clientID
	IF NOT EXISTS(
		SELECT ClientID FROM BusinessDatabase.dbo.Clients
		WHERE ClientID = @clientID
		)
		THROW 55555, 'The ClientID does not exist', 1 
GO

--Execute ModifyCompanyName stored procedure with parameters
EXECUTE dbo.ModifyCompanyName @clientID = 1, @NewName = 'CP'
GO
EXECUTE dbo.ModifyCompanyName @clientID = 2, @NewName = 'David Greenberg'
GO

/*
--Execute ModifyCompanyName stored procedure with error to test THROW
EXECUTE dbo.ModifyCompanyName @custID = 3, @NewName = 'Flown Alone'
GO
*/

--Create ClientsAudit table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'ClientsAudit'
)
	CREATE TABLE BusinessDatabase.dbo.ClientsAudit
		(
			ClientID int PRIMARY KEY,
			DateChanged datetime DEFAULT GETDATE(),
			OldCreditLimit money,
			NewCreditLimit money,
			ChangedBy varchar(100) DEFAULT SYSTEM_USER
		)

--Increase CreditLimit by 1000 for all clients who have a less than 9000 credit limit, and who have credit terms
--Record change to ClientsAudit table
UPDATE BusinessDatabase.dbo.Clients
SET CreditLimit = CreditLimit + 1000
OUTPUT inserted.ClientID, deleted.CreditLimit, inserted.CreditLimit
INTO BusinessDatabase.dbo.ClientsAudit(ClientID, OldCreditLimit, NewCreditLimit)
WHERE CreditLimit < 9000 AND HasCreditTerms = 1

--Create Employees table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Employees'
)
	CREATE TABLE Employees
		(
			EmployeeID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
			EmployeeCode int,
			FirstName varchar(50) NOT NULL,
			LastName varchar(50) NOT NULL,
			HireDate datetime2(7),
			HourlyPay money,
			Title varchar(50),
			City varchar(50),
			MgrID int
		)

--Clear EmployeesTableInsert stored procedure
IF OBJECT_ID('dbo.EmployeesTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.EmployeesTableInsert
GO

--Create EmployeesTableInsert stored procedure
CREATE PROCEDURE dbo.EmployeesTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Employees)
			BEGIN
				SELECT 'Employees table is populated.' AS EmployeesTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Employees table is not populated - Inserting values.' AS EmployeesTableStatus
					INSERT INTO Employees(EmployeeCode, FirstName, LastName, HireDate, HourlyPay, Title, City, MgrID)
					VALUES(201, 'Blanche', 'Guzman', '2016-07-14', 106, 'CEO' , 'Los Angeles', NULL),
						  (202, 'Jarrod', 'Booth', '2020-01-25', 55, 'Developer' , 'Portland', 1),
						  (203, 'Jared', 'Broth', '2020-05-15', 35, 'Sales Representative' , 'Belfast', 1),
						  (204, 'Ryan', 'Newb', '2020-09-15', 12, 'Intern' , 'Portland', 2)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Employees table insert.' 
	END CATCH
GO

--Update Employees table to change title to Customer Representative
--for all Employees in Seattle and has title Sales Representative 
--If there is no manager defined, do not update
UPDATE BusinessDatabase.dbo.Employees
SET Title = 'Lead Developer'
WHERE Title = 'Developer' AND
	  City = 'Portland' AND MgrID IS NOT NULL

--Run EmployeesTableInsert stored procedure
EXECUTE dbo.EmployeesTableInsert
GO

--Create Projects table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Projects'
)
	CREATE TABLE BusinessDatabase.dbo.Projects
		(
			ProjectID int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
			ProjectName varchar(100),
			StartTime datetime2(7),
			EndTime datetime2(7), 
			ProjectLead int 
		)

--Clear ProjectsTableInsert stored procedure
IF OBJECT_ID('dbo.ProjectsTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ProjectsTableInsert
GO

--Create ProjectsTableInsert stored procedure
CREATE PROCEDURE dbo.ProjectsTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Projects)
			BEGIN
				SELECT 'Projects table is populated.' AS ProjectsTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Projects table is not populated - Inserting values.' AS ProjectsTableStatus
					INSERT INTO BusinessDatabase.dbo.Projects(ProjectName, StartTime, EndTime, ProjectLead)
					VALUES('ProjectX', '2020-02-20', '2020-07-14' , 1),
						  ('OperationFullSend', '2020-05-25', NULL, 1),
						  ('TheManhattanProject', '2020-08-07', NULL, 1)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Projects table insert.' 
	END CATCH
GO

--Run ProjectsTableInsert stored procedure
EXECUTE dbo.ProjectsTableInsert
GO

--Create Tasks table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Tasks'
)
	CREATE TABLE BusinessDatabase.dbo.Tasks
		(
			TaskID int NOT NULL PRIMARY KEY,
			TaskName varchar(100),
			ParentTaskID int, 
			ProjectID int FOREIGN KEY REFERENCES Projects(ProjectID),
			StartTime datetime2(7),
			EndTime datetime2(7), 
			UserID int
		)

--Clear TasksTableInsert stored procedure
IF OBJECT_ID('dbo.TasksTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.TasksTableInsert
GO

--Create TasksTableInsert stored procedure
CREATE PROCEDURE dbo.TasksTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Tasks)
			BEGIN
				SELECT 'Tasks table is populated.' AS TasksTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Tasks table is not populated - Inserting values.' AS TasksTableStatus
					INSERT INTO BusinessDatabase.dbo.Tasks(TaskID, TaskName, ParentTaskID, ProjectID, StartTime, EndTime, UserID)
					VALUES('1', 'SetMeeting', NULL, 1, '2020-03-12', NULL, 3),
						  ('2', 'UpdateSchedule', 1, 1, '2020-03-20', '2020-03-25', 3),
						  ('3', 'CancelMeeting', NULL, 2, '2020-05-29', '2020-05-30', 1),
						  ('4', 'DropClient', 3, 2, '2020-06-20', NULL, 1),
						  ('5', 'ReassignAccount', NULL, 2, NULL, NULL, 2),
						  ('6', 'DeliverGoods', NULL, NULL, NULL, NULL, NULL),
						  ('7', 'Get Coffee', NULL, NULL, NULL, NULL, 4)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Tasks table insert.' 
	END CATCH
GO

--Run TasksTableInsert stored procedure
EXECUTE dbo.TasksTableInsert
GO

--Update NULL Tasks UserID values with Projects ProjectLead values
UPDATE T SET T.UserID = P.ProjectLead
FROM Tasks AS T
INNER JOIN Projects P ON T.ProjectID = P.ProjectID
WHERE P.ProjectLead IS NOT NULL AND T.UserID IS NULL
GO

--Create Orders table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Orders'
)
	CREATE TABLE Orders
		(
			OrderID int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
			ClientID int FOREIGN KEY REFERENCES Clients(ClientID),
			SKUID int FOREIGN KEY REFERENCES Catalogue(SKUID),
			Quantity int,
			Price decimal(18, 2),
			OrderDate datetime2(7),
			ShippedDate date NULL
		)
GO

--Clear OrdersTableInsert stored procedure
IF OBJECT_ID('dbo.OrdersTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.OrdersTableInsert
GO

--Create OrdersTableInsert stored procedure
CREATE PROCEDURE dbo.OrdersTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Orders)
			BEGIN
				SELECT 'Orders table is populated.' AS OrderTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Orders table is not populated - Inserting values.' AS OrdersTableStatus
					INSERT INTO BusinessDatabase.dbo.Orders(ClientID, SKUID, Quantity, Price, OrderDate, ShippedDate)
					VALUES(1, 1, 20, .35, '2010-03-22', NULL),
						  (1, 3, 25, .65, '2011-10-16', '2011-11-01'),
						  (1, 3, 30, 1.59, '2019-04-20', '2019-05-05'),
						  (2, 2, 15, 1.99, '2019-08-08', '2019-08-16'),
						  (2, 2, 25, 1.99, '2019-09-06', '2019-09-18'),
						  (3, 1, 15, .99, '2020-03-22', '2020-03-29'),
						  (4, 4, 1, 9.95, '2020-08-15', '2020-09-01')
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Orders table insert.' 
	END CATCH
GO

--Run OrdersTableInsert stored procedure
EXECUTE dbo.OrdersTableInsert
GO

--Add TotalOrderValue column
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Orders'
          AND COLUMN_NAME = 'TotalOrderValue'
)
    BEGIN
        ALTER TABLE BusinessDatabase.dbo.Orders
        ADD TotalOrderValue decimal(18, 2) 
	END
GO

--Update TotalOrderValue
IF EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Orders'
          AND COLUMN_NAME = 'TotalOrderValue'
)
    BEGIN
		UPDATE BusinessDatabase.dbo.Orders 
		SET TotalOrderValue = (Quantity * Price)
		WHERE TotalOrderValue IS NULL
	END
GO

--Delete Orders placed before 2011-11-11 AND that have been shipped
DELETE FROM BusinessDatabase.dbo.Orders
WHERE (OrderDate < '20111111' AND 
	  ShippedDate IS NOT NULL) OR
	  TotalOrderValue < .01

--Create Log1 table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Log1'
)
	CREATE TABLE Log1
		(
			Log1ID int IDENTITY(1, 1) PRIMARY KEY,
			ErrorCode varchar(5),
			EmployeeID int FOREIGN KEY REFERENCES Employees(EmployeeID), 
			ErrorMessage varchar(100)
		)

--Create Log2 table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Log2'
)
	CREATE TABLE Log2
		(
			Log2ID int IDENTITY(1, 1) PRIMARY KEY,
			ErrorCode varchar(5),
			EmployeeID int FOREIGN KEY REFERENCES Employees(EmployeeID), 
			ErrorMessage varchar(100)
		)

--Create Log3 table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Log3'
)
	CREATE TABLE Log3
		(
			Log3ID int IDENTITY(1, 1) PRIMARY KEY,
			ErrorCode varchar(5),
			EmployeeID int FOREIGN KEY REFERENCES Employees(EmployeeID), 
			ErrorMessage varchar(100)
		)
GO

--Clear UpdateLogs stored procedure
IF OBJECT_ID('dbo.TransactionLog', 'P') IS NOT NULL
	DROP PROCEDURE dbo.TransactionLog
GO

--Create procedure to store transaction info in log tables
CREATE PROCEDURE dbo.TransactionLog @ErrorCode char(5), @EmployeeID int, @ErrorMessage varchar(1000)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO dbo.Log1 VALUES(@ErrorCode, @EmployeeID, @ErrorMessage)
			IF @EmployeeID = 4
				RAISERROR('Access denied, intern.', 16, 1)
			ELSE
				INSERT INTO dbo.Log2 VALUES(@ErrorCode, @EmployeeID, @ErrorMessage)
				BEGIN TRANSACTION
					IF @ErrorCode = 'ABORT'
						ROLLBACK TRANSACTION
					ELSE
						INSERT INTO dbo.Log3 VALUES(@ErrorCode, @EmployeeID, @ErrorMessage)
						COMMIT TRANSACTION
						IF @@TRANCOUNT > 0 
							COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF XACT_STATE() != 0
			ROLLBACK TRANSACTION
	END CATCH
END
GO	

EXECUTE dbo.TransactionLog 'DERPP', 4, 'The intern is hacking.'
EXECUTE dbo.TransactionLog 'SENDD', 1, 'Operation FullSendComplete.'
EXECUTE dbo.TransactionLog 'ABORT', 2, 'Abort, abort, abort!.'

--Clear FirstTwo Function
IF OBJECT_ID('dbo.FirstTwo') IS NOT NULL
	DROP FUNCTION dbo.FirstTwo
GO

--Create FirstTwo user defined function; for use in indexed view
CREATE FUNCTION dbo.FirstTwo(
	@SuperSecretNumber nvarchar(20)
	)
RETURNS nvarchar(10)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @firstTwo nvarchar(max)
	SELECT TOP 1 @firstTwo = VALUE FROM STRING_SPLIT(@SuperSecretNumber, '-')
	RETURN @firstTwo
END
GO

--Clear LastFour Function
IF OBJECT_ID('dbo.LastFour') IS NOT NULL
	DROP FUNCTION dbo.LastFour
GO

--Create LastFour user defined function; for use in indexed view
CREATE FUNCTION dbo.LastFour(
	@SuperSecretNumber nvarchar(20)
	)
RETURNS nvarchar(10)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @lastFour nvarchar(max)
	SELECT @lastFour = RIGHT(@SuperSecretNumber, 4)
	RETURN @lastFour
END
GO

--Tables
SELECT * FROM sys.tables

--Procedures
SELECT * FROM sys.procedures

--Functions
SELECT * FROM sys.objects 
WHERE TYPE IN('FN','IF','TF', 'FS', 'FT')

--Schemas
SELECT * FROM sys.schemas

--Queries
SELECT * FROM BusinessDatabase.dbo.Catalogue 
SELECT * FROM BusinessDatabase.dbo.Clients
SELECT * FROM BusinessDatabase.dbo.Employees
SELECT * FROM BusinessDatabase.dbo.ClientsAudit
SELECT * FROM BusinessDatabase.dbo.Cities
SELECT * FROM BusinessDatabase.dbo.Orders
SELECT * FROM BusinessDatabase.dbo.Projects
SELECT * FROM BusinessDatabase.dbo.Tasks

--Check logs for updates
SELECT * FROM BusinessDatabase.dbo.Log1
SELECT * FROM BusinessDatabase.dbo.Log2
SELECT * FROM BusinessDatabase.dbo.Log3

--Execute FirstTwo function
SELECT dbo.FirstTwo('12-123-1234') AS FirstTwo

--Execute LastFour function
SELECT dbo.LastFour('12-123-1234') AS LastFour

--Query to return all tasks and each task's owner. If no task owner, return project's owner.
SELECT T.TaskID, T.TaskName, COALESCE(T.UserID, P.ProjectLead, NULL) AS OwnerUserID
FROM BusinessDatabase.dbo.Tasks T
LEFT JOIN Projects P
ON T.ProjectID = P.ProjectID
GO

--CTE to determine the employee level for each employee in the hierarchy.
WITH EmployeeRank(MgrID, EmployeeID, FirstName, EmployeeRank)
AS(
	SELECT CAST(NULL AS int) AS MgrID, E.EmployeeID, E.FirstName, 0 AS EmployeeRank
	FROM Employees E
	WHERE E.MgrID IS NULL

	UNION ALL

	SELECT R.EmployeeID AS MgrID, E.EmployeeID, E.FirstName, R.EmployeeRank + 1 AS EmployeeRank
	FROM BusinessDatabase.dbo.Employees E INNER JOIN EmployeeRank R ON E.MgrID = R.EmployeeID
  )
SELECT * FROM EmployeeRank
GO

--Retrieve average price of all products
--Exclude items with no stock
--Exclude items with 0 UnitsOnOrder
SELECT AVG(Price) AS AverageProductCost
FROM BusinessDatabase.dbo.Catalogue
WHERE UnitsOnOrder IS NOT NULL AND
	  UnitsOnHand <> 0 
GO

--Return EmployeeID, full name, city, and average temperature for employees in Portland that aren't interns, 
--and for employees in Belfast
SELECT E.EmployeeID, E.FirstName + ' ' + E.LastName AS FullName, C.CityName, C.AverageTemperature
FROM BusinessDatabase.dbo.Employees AS E
INNER JOIN BusinessDatabase.dbo.Cities AS C 
ON E.City = C.CityName  
WHERE (E.Title <> 'Intern' AND E.City = 'Portland') OR
	  (C.CityName = 'Belfast' )
GO

	  --Create GetCustomerInformation user defined function
CREATE FUNCTION dbo.GetCustomerInformation(
	@ClientID int
	)
RETURNS TABLE
AS
RETURN(
	SELECT C.ClientName, C.PhoneNumber, C.OnboardDate, C.VolumeDiscountPercentage, 
	C.CreditLimit, C.HasCreditTerms, COUNT(O.OrderID) AS TotalNumberOfOrders
	FROM BusinessDatabase.dbo.Clients C
	INNER JOIN BusinessDatabase.dbo.Orders O
	ON C.ClientID = O.ClientID
	WHERE C.ClientID = @ClientID
	GROUP BY C.ClientName, C.PhoneNumber, C.OnboardDate, C.VolumeDiscountPercentage, C.CreditLimit, C.HasCreditTerms
)
GO

--Execute GetCustomerInformation function 
--Get first ClientID customer information
SELECT * FROM dbo.[GetCustomerInformation](1) AS GetCustomerInformation
GO

--Return all ProductIDs and ProductNames and ClientNames to which product is sold most often
SELECT DISTINCT SKUID, ClientID FROM BusinessDatabase.dbo.Orders as t1
WHERE Quantity > ALL(
	SELECT t2.Quantity FROM BusinessDatabase.dbo.Orders AS t2
	WHERE t2.SKUID = t1.SKUID AND t2.ClientID <> t1.ClientID
	)
GO

--Return total number of purchased product per SKU
SELECT ord.SKUID, SUM(ord.Quantity) AS TotalQtySold
FROM BusinessDatabase.dbo.Orders AS ord
GROUP BY SKUID
