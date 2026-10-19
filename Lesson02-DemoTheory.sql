--- Lesson02 - Demo
-- 1. TẠO CSDL ĐƠN GIẢN
CREATE DATABASE Dev2610LM_Lesson02_Db;
GO
/*
	C:\Program Files\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\DATA
*/
-- 2. TẠO CSDL VỚI TÙY CHỌN FILE VÀ COLLACTION
CREATE DATABASE DEV2610LM_Lesson02_Db1
ON PRIMARY
(
	NAME		= DEV2610LM_Lesson02_Db1_Data,
	FILENAME	= 'D:\devmaster.edu.vn\DEV2610LM-SQL\Datas\DEV2610LM_Lesson02_Db1_Data.mdf',
	SIZE		= 64MB,
	MAXSIZE		= 2GB,
	FILEGROWTH	= 64MB
)
LOG  ON
(
	NAME		= DEV2610LM_Lesson02_Db1_LOG,
	FILENAME	= 'D:\devmaster.edu.vn\DEV2610LM-SQL\Datas\DEV2610LM_Lesson02_Db1_LOG.ldf',
	SIZE		= 10MB,
	MAXSIZE		= 10MB,
	FILEGROWTH	= 2MB
)
COLLATE Vietnamese_100_CI_AS_SC_UTF8;
GO
-- 3. Collation và dữ liệu tiếng Việt

-- CI/CS: phân biệt hoa thường · AI/AS: phân biệt dấu
SELECT
  CASE WHEN N'Hà Nội' = N'ha noi' COLLATE Vietnamese_100_CI_AI
       THEN 1 ELSE 0 END AS CI_AI,        -- 1: bỏ qua hoa thường + dấu

  CASE WHEN N'Hà Nội' = N'ha noi' COLLATE Vietnamese_100_CI_AS
       THEN 1 ELSE 0 END AS CI_AS,        -- 0: phân biệt dấu

  CASE WHEN N'Hà Nội' = N'HÀ NỘI' COLLATE Vietnamese_100_CI_AS
       THEN 1 ELSE 0 END AS CI_AS_Upper;  -- 1: không phân biệt hoa/thường
GO
SELECT name FROM sys.fn_helpcollations()
WHERE name LIKE 'Vietnamese_100%UTF8';
GO
-- 4. ALTER, DROP DATABASE và USE
ALTER  DATABASE DEV2610LM_Lesson02_Db1 SET RECOVERY SIMPLE
GO
IF DB_ID(N'Dev2610LM_Lesson02_Db') IS NOT NULL
BEGIN
    ALTER DATABASE Dev2610LM_Lesson02_Db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Dev2610LM_Lesson02_Db;
END
-- 5. NULL. NOT NULL, DEFAULT

USE DEV2610LM_Lesson02_Db1;
GO
CREATE TABLE dbo.DemoDefaults
(
	Id		int  IDENTITY(1,1) 
				CONSTRAINT PK_DemoDefaults PRIMARY KEY,
	Title	nvarchar(100) NOT  NULL,  -- bắt buộc,
	Note	nvarchar(200), -- CHO PHÉP  NULL
	IsActive	BIT	NOT NULL
				CONSTRAINT DF_DemoDefaults_IsActive
					DEFAULT 1,
	CreatedAt	datetime2(0) 
				CONSTRAINT DF_DemoDefaults_CreatedAt
					DEFAULT SYSDATETIME()
)
GO
SELECT * FROM dbo.DemoDefaults
INSERT dbo.DemoDefaults (Title) VALUES (N'Bỏ qua cột default')

ALTER TABLE dbo.DemoDefaults 
	ADD CONSTRAINT  DF_DemoDefaults_Note
		DEFAULT N'Devmaster Academy' FOR Note
GO
INSERT INTO dbo.DemoDefaults (Title,IsActive)
VALUES (N'Ghi đè', 0);
SELECT * FROM dbo.DemoDefaults
-- 6. IDENTITY và SEQUENCE: sinh khóa tự động

select SCOPE_IDENTITY() AS NewId;
SELECT  IDENT_CURRENT('dbo.DemoDefaults') as  LastId;

-- SEQUENCE: độc lập, dùng chung
CREATE SEQUENCE dbo.InvoiceNo as  Int 
	START  WITH 1000 INCREMENT BY 5;
GO
SELECT	NEXT VALUE FOR  dbo.InvoiceNo as No1,
		NEXT VALUE FOR  dbo.InvoiceNo as No2;
-- Tạo bảng sequence
CREATE TABLE dbo.DemoInvoices
(
	InvoiceNo int  NOT NULL
		DEFAULT (NEXT VALUE FOR dbo.InvoiceNo)
		PRIMARY KEY,
	Amount	decimal(12,0) NOT NULL
)
GO
INSERT dbo.DemoInvoices(Amount) VALUES
(50000),
(70000),
(40000);
SELECT * FROM dbo.DemoInvoices;

-- 7. PRIMARY KEY và UNIQUE, CHECK 
CREATE TABLE dbo.Students
(
	StudentId		int
		IDENTITY(1,1)
		CONSTRAINT  PK_Students PRIMARY KEY,
	FullName		NVARCHAR(100) NOT NULL,
	Email			varchar(50) NOT NULL
		CONSTRAINT UQ_Students_Email UNIQUE,
	Phone			varchar(10),
	City			nvarchar(50),
	BirthDay		Date,
	Flags			int NOT NULL
		CONSTRAINT DF_Students_Flags DEFAULT 0,
	CreatedAt		datetime2(0) NOT NULL
		CONSTRAINT DF_Students_CreatedAt DEFAULT SYSDATETIME(),
	-- 
	CONSTRAINT CK_Students_Email CHECK(Email  LIKE '%_@_%')
)
GO
-- 8.  FOREIGN KEY và hành động tham chiếu
CREATE TABLE dbo.Categories
(
	CategoryId		int IDENTITY(1,1)
			CONSTRAINT PK_Categories PRIMARY KEY,
	CategoryName	NVARCHAR(100) NOT NULL
			CONSTRAINT UQ_Categories_Name UNIQUE,
	ParentId		int 
			CONSTRAINT FK_Categories_Parent
			REFERENCES	dbo.Categories (CategoryId)
)
GO
INSERT dbo.Categories VALUES(N'Apple',NULL)
INSERT dbo.Categories VALUES(N'Samsung',NULL)
INSERT dbo.Categories VALUES(N'Xiaomi',NULL)
INSERT dbo.Categories VALUES(N'Iphone  17 ProMax',1)

SELECT * FROM dbo.Categories
GO
CREATE TABLE dbo.Courses 
(
	CourseId   int IDENTITY(1,1) CONSTRAINT PK_Courses PRIMARY KEY,
    CourseCode varchar(20)   NOT NULL CONSTRAINT UQ_Courses_Code UNIQUE,
    CourseName nvarchar(200) NOT NULL,
    CategoryId int           NOT NULL
               CONSTRAINT FK_Courses_Categories
               REFERENCES dbo.Categories(CategoryId),
    Fee        decimal(12,0) NOT NULL
               CONSTRAINT CK_Courses_Fee CHECK (Fee >= 0),
    Hours      int           NOT NULL
               CONSTRAINT CK_Courses_Hours CHECK (Hours > 0),
    Tags       nvarchar(400) NULL,
    IsActive   bit           NOT NULL
               CONSTRAINT DF_Courses_IsActive DEFAULT 1
)
GO
-- 9. Cột tính toán (computed column)
-- Cột   FeePerHours = Fee / Hours
ALTER TABLE dbo.Courses
	Add FeePerHour As CAST(Fee/Hours as decimal(12,0)) PERSISTED;
GO
SELECT * FROM dbo.Courses 
GO
-- 10. ALTER TABLE: thêm / sửa / xóa
-- THÊM CỘT
ALTER TABLE dbo.Students
	ADD Gender char(1)
		CONSTRAINT CK_Students_Gender
			CHECK (Gender IN ('M','F'));
GO
SELECT * FROM Students
GO
-- SỬA ĐỔI KIỂU DỮ  LIỆU / ĐỘ DÀI CỘT
ALTER TABLE dbo.Students
	ALTER COLUMN Phone varchar(21)  NULL
GO
-- XÓA: CỘT/ CONSTRAINT

ALTER TABLE dbo.students 
	DROP CONSTRAINT CK_Students_Gender;
ALTER TABLE dbo.Students 
	DROP COLUMN Gender
GO
-- 11. Tra cứu cấu trúc bằng metadata
SELECT *
FROM SYS.objects
WHERE parent_object_id = OBJECT_ID('dbo.Students')

--- DML
-- 12. INSERT: một dòng, nhiều dòng, INSERT … SELECT