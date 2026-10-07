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
SELECT @Fee = Fee, @Name = CoursesName 
SET @Fee = 
