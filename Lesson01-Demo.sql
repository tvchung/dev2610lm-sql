/**========================
DEMO Lesson01
Author: Chung Trinhj
Email: chungtrinhj@ggmai.com
===========================*/
-- Sử dụng cơ sở dữ liệu DevmasterLab
Use DevmasterLab
Go
/*--------------------------------------------------------------
PHẦN 1 - NỀN  TẢNG
----------------------------------------------------------------*/
SELECT	@@SERVERNAME						AS [Máy chủ],
		SERVERPROPERTY('ProductVersion')	AS 'Phiên bản', -- 15.0.x
		SERVERPROPERTY('Edition')			AS 'Editor'

SELECT name, database_id , compatibility_level
FROM sys.databases

/*--------------------------------------------------------------
PHẦN 2 - NGÔN NGỮ T-SQL
----------------------------------------------------------------*/
-- khai báo biến
DECLARE @coursecode varchar(20) = 'NET-FS',
		@Total int;
-- Truy vấn và tính toán gán giá trị cho biên, điều kiện  sử  dụng biến
SELECT @Total = Count(*)
FROM Enrollments as e
	JOIN Courses as c ON e.CourseId = c.CourseId
WHERE CourseCode = @coursecode

-- Lấy giá trị của biến / In giá  trị
SELECT @Total
--PRINT  @Total
GO -- Kết thúc lô

--- Khai báo biến
DECLARE @Fee	decimal(12,0),
		@Name	nvarchar(200)

-- Gán giá trị: SET / /SELECT
SELECT @Fee = Fee, @Name = CourseName 
FROM Courses
WHERE CourseCode = 'SQL-DEV'
print @fee
-- Tính toán
SET @Fee += 500000;
-- Hiển thị
SELECT @Name , @Fee , @@ROWCOUNT

GO
--------------------------------------
-- CẤU TRÚC IF ... ELSE

DECLARE @num int = 10
IF @num % 2 = 0
	SELECT CAST(@num AS VARCHAR) + N' Là số chẵn' AS 'Số'
ELSE 
	SELECT CAST(@num AS VARCHAR) + N' Là số lẻ' as 'Số'
GO

-----
DECLARE @unpaid  int
SELECT  @unpaid = (SELECT Count(*) FROM Enrollments WHERE PaidAmount = 0)
IF @unpaid > 0 
	PRINT CONCAT(N'Có ', @unpaid , N' ghi danh chưa đóng  tiền')
ELSE
	PRINT N'Tất cả đã đóng tiền'
GO



/*--------------------------------------------------------------
PHẦN 3 - TÍNH NĂNG MỚI
----------------------------------------------------------------*/

---GREATEST

SELECT EnrollmentId, Score1, Score2, Score3,
		GREATEST(Score1, Score2, Score3) AS MaxScore, -- bỏ qua giá trị NULL
		LEAST(Score1, Score2, Score3) AS MinScore -- 
FROM Enrollments
GO

/*
DECLARE @city nvarchar(50) = NULL;
SELECT FullName FROM dbo.Students
WHERE City = @city;                       -- 0 dòng
 
SELECT FullName FROM dbo.Students
WHERE City IS NOT DISTINCT FROM @city;    -- Vũ Đức Huy

*/
SELECT c.CourseCode, TRIM(s.value) AS Tag,
       s.ordinal
FROM dbo.Courses AS c
CROSS APPLY STRING_SPLIT(c.Tags, ',', 1) AS s
WHERE c.CourseCode = 'NET-FS'   -- tham số 3 = 1: có ordinal
ORDER BY s.ordinal;
-- csharp(1) · aspnetcore(2) · sql(3) · react(4)

/*
SELECT JSON_OBJECT(
           'id'     : s.StudentId,
           'name'   : s.FullName,
           'contact': JSON_OBJECT('email': s.Email,
                                  'phone': s.Phone ABSENT ON NULL),
           'tags'   : JSON_ARRAY('devmaster', s.City)
       ) AS Payload
FROM dbo.Students AS s
WHERE s.StudentId IN (1, 2);
-- Học viên 2 không có phone → thuộc tính "phone" biến mất khỏi JSON
 
DECLARE @j nvarchar(max) = N'{"level":"junior","hours":120,"skills":["sql","c#"]}';
SELECT ISJSON(@j)                  AS IsJson,     -- 1
       ISJSON(@j, OBJECT)          AS IsObject,   -- 1  (kiểu: 2022)
       ISJSON(N'[1,2]', OBJECT)    AS IsObject2,  -- 0
       JSON_PATH_EXISTS(@j, '$.hours') AS HasHours,   -- 1
       JSON_VALUE(@j, '$.level')   AS Level,      -- junior
       JSON_QUERY(@j, '$.skills')  AS Skills;     -- ["sql","c#"]

    */
