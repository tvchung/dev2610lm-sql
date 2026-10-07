/* =====================================================================
   Devmaster Academy – Hệ quản trị CSDL SQL Server 2022
   BUỔI 1 – Nền tảng SQL Server 2022 & ngôn ngữ T-SQL
   File: Buoi1_Demo.sql – code demo theo thứ tự slide
   Chuẩn bị: chạy 00_DevmasterLab_Setup.sql trước
   ===================================================================== */
USE DevmasterLab;
GO

/* ---------------------------------------------------------------------
   PHẦN 1 – NỀN TẢNG
   --------------------------------------------------------------------- */
SELECT @@SERVERNAME                       AS ServerName,
       SERVERPROPERTY('ProductVersion')   AS ProductVersion,   -- 16.0.x
       SERVERPROPERTY('Edition')          AS Edition;

SELECT name, database_id, compatibility_level
FROM sys.databases
ORDER BY database_id;                     -- master, tempdb, model, msdb, DevmasterLab
GO

/* ---------------------------------------------------------------------
   PHẦN 2 – NGÔN NGỮ T-SQL
   --------------------------------------------------------------------- */
DECLARE @CourseCode varchar(20) = 'NET-FS',
        @Total      int;

SELECT @Total = COUNT(*)
FROM dbo.Enrollments AS e
JOIN dbo.Courses     AS c ON c.CourseId = e.CourseId
WHERE c.CourseCode = @CourseCode;

SELECT @Total AS TotalEnrollments;        -- 4
GO                                        -- hết lô: @Total mất
-- SELECT @Total;       -- Msg 137: chưa khai báo biến
GO

DECLARE @Fee  decimal(12,0),
        @Name nvarchar(200);

SELECT @Fee = Fee, @Name = CourseName    -- SELECT gán được nhiều biến
FROM dbo.Courses
WHERE CourseCode = 'SQL-DEV';

SET @Fee += 500000;                      -- toán tử gán kép
SELECT @Name AS CourseName, @Fee AS NewFee, @@ROWCOUNT AS RowsRead;
-- SQL Server cho Developer · 6.500.000 · 1
GO

-- IF … ELSE
DECLARE @unpaid int = (SELECT COUNT(*) FROM dbo.Enrollments WHERE PaidAmount = 0);
IF @unpaid > 0
    PRINT CONCAT(N'Có ', @unpaid, N' ghi danh chưa đóng tiền');   -- 1
ELSE
    PRINT N'Tất cả đã đóng tiền';

-- WHILE với BREAK / CONTINUE
DECLARE @i int = 1, @sum int = 0;
WHILE @i <= 10
BEGIN
    IF @i % 2 = 0                        -- bỏ qua số chẵn
    BEGIN
        SET @i += 1;
        CONTINUE;
    END;
    SET @sum += @i;
    IF @sum > 20 BREAK;                  -- dừng khi vượt 20
    SET @i += 1;
END;
SELECT @i AS LastI, @sum AS Total;       -- 9 · 25
GO

SELECT 10 / 3     AS IntDiv,             -- 3   (chia nguyên)
       10 / 3.0   AS DecDiv,             -- 3.333333
       LEN(N'Hà Nội ')        AS Len,    -- 6   (bỏ khoảng trắng cuối)
       DATALENGTH(N'Hà Nội')  AS BytesN, -- 12  (nvarchar: 2 byte/ký tự)
       DATALENGTH('Ha Noi')   AS BytesV; -- 6   (varchar: 1 byte/ký tự)

-- float gây sai số nhị phân; decimal thì chính xác
SELECT 0.1 + 0.2 AS DecimalSum,                                   -- 0.3
       CASE WHEN CAST(0.1 AS float) + CAST(0.2 AS float) = 0.3
            THEN N'bằng' ELSE N'khác' END AS FloatCompare;        -- khác
GO

DROP TYPE IF EXISTS dbo.PhoneNumber;
DROP TYPE IF EXISTS dbo.EnrollmentList;
GO
CREATE TYPE dbo.PhoneNumber FROM varchar(15) NULL;        -- alias type
CREATE TYPE dbo.EnrollmentList AS TABLE (                 -- table type (TVP)
    StudentId  int           NOT NULL,
    CourseId   int           NOT NULL,
    PaidAmount decimal(12,0) NOT NULL
);
GO
DECLARE @list dbo.EnrollmentList;
INSERT INTO @list VALUES (1, 2, 5000000), (2, 2, 4500000);
SELECT * FROM @list;                                      -- 2 dòng
GO
DROP TYPE dbo.EnrollmentList;
DROP TYPE dbo.PhoneNumber;
GO

SELECT 2 + 2 * (4 + (5 - 3)) AS Precedence,   -- 14
       17 % 5               AS Modulo,        -- 2
       7 & 5                AS BitAnd,        -- 5
       7 | 8                AS BitOr,         -- 15
       7 ^ 5                AS BitXor,        -- 2
       N'Dev' + N'master'   AS Joined;        -- Devmaster
GO

SELECT FullName FROM dbo.Students WHERE Phone = NULL;     -- 0 dòng (UNKNOWN)
SELECT FullName FROM dbo.Students WHERE Phone IS NULL;    -- 6 dòng

SELECT NULL + 5                       AS A,   -- NULL
       CONCAT(N'A', NULL, N'B')       AS B,   -- AB
       ISNULL(NULL, N'x')             AS C,   -- x
       COALESCE(NULL, NULL, N'y')     AS D,   -- y
       NULLIF(5, 5)                   AS E;   -- NULL (hai vế bằng nhau)
GO

DECLARE @city nvarchar(50) = NULL;
SELECT FullName FROM dbo.Students
WHERE City = @city;                       -- 0 dòng

SELECT FullName FROM dbo.Students
WHERE City IS NOT DISTINCT FROM @city;    -- Vũ Đức Huy
GO

SELECT '10' + 5                           AS A,   -- 15  (chuỗi tự đổi sang số)
       '10' + '5'                         AS B,   -- 105 (ghép chuỗi)
       CAST(123.456 AS int)               AS C,   -- 123 (cắt phần thập phân)
       TRY_CONVERT(int, '12a')            AS D,   -- NULL (không báo lỗi)
       TRY_CAST('2026-13-45' AS date)     AS E,   -- NULL
       CONVERT(varchar(10), CAST('2026-10-07' AS date), 103) AS F,  -- 07/10/2026
       FORMAT(18000000, 'N0', 'vi-VN')    AS G;   -- 18.000.000
GO

SELECT FullName,
       LEFT(FullName, CHARINDEX(N' ', FullName) - 1) AS Ho,
       REVERSE(LEFT(REVERSE(FullName),
                    CHARINDEX(N' ', REVERSE(FullName)) - 1)) AS Ten,
       SUBSTRING(Email, 1, CHARINDEX('@', Email) - 1) AS UserName,
       STUFF(Phone, 5, 3, '***') AS MaskedPhone
FROM dbo.Students
WHERE StudentId = 1;
-- Nguyễn · An · an.nv · 0912***678

SELECT CONCAT_WS(N' | ', CourseCode, CourseName) AS Line,
       REPLICATE('=', 10) AS Bar,
       TRANSLATE('2*[3+4]/{7-2}', '[]{}', '()()') AS Expr
       -- Expr: 2*(3+4)/(7-2)
FROM dbo.Courses
WHERE CourseCode = 'GIT';
GO

DECLARE @d date = '2026-10-07';
SELECT DATEADD(month, 1, @d)             AS NextMonth,   -- 2026-11-07
       DATEDIFF(day, '2026-09-07', @d)   AS DaysBetween, -- 30
       EOMONTH(@d)                       AS EndOfMonth,  -- 2026-10-31
       DATEFROMPARTS(2026, 12, 25)       AS Xmas,        -- 2026-12-25
       DATENAME(weekday, @d)             AS WeekdayName, -- Wednesday
       DATEPART(quarter, @d)             AS Q,           -- 4
       DATEPART(iso_week, @d)            AS IsoWeek;     -- 41
GO

SELECT ROUND(2.5678, 2)                         AS Rounded,   -- 2.5700
       CEILING(7.2)                             AS Ceil,      -- 8
       FLOOR(7.8)                               AS Flr,       -- 7
       POWER(2, 10)                             AS Pw,        -- 1024
       IIF(18000000 > 10000000, N'Cao', N'Thấp') AS FeeLevel, -- Cao
       CHOOSE(2, N'Bronze', N'Silver', N'Gold') AS Tier;      -- Silver
GO

/* ---------------------------------------------------------------------
   PHẦN 3 – T-SQL MỚI TRONG SQL SERVER 2022 (compatibility level 160)
   --------------------------------------------------------------------- */
SELECT name, compatibility_level
FROM sys.databases
WHERE name = 'DevmasterLab';              -- 160

-- Nếu chưa phải 160:
-- ALTER DATABASE DevmasterLab SET COMPATIBILITY_LEVEL = 160;
GO

SELECT EnrollmentId, Score1, Score2, Score3,
       GREATEST(Score1, Score2, Score3) AS Best,     -- NULL bị bỏ qua
       LEAST(Score1, Score2, Score3)    AS Worst
FROM dbo.Enrollments
WHERE EnrollmentId IN (1, 2, 7);
-- 1: 8.00 · 7.50     2: 7.50 · 6.00     7: NULL · NULL (cả 3 đều NULL)
GO

SELECT c.CourseCode, TRIM(s.value) AS Tag,
       s.ordinal
FROM dbo.Courses AS c
CROSS APPLY STRING_SPLIT(c.Tags, ',', 1) AS s
WHERE c.CourseCode = 'NET-FS'   -- tham số 3 = 1: có ordinal
ORDER BY s.ordinal;
-- csharp(1) · aspnetcore(2) · sql(3) · react(4)
GO

SELECT TRIM(LEADING '0' FROM '000123') AS A,  -- 123
       TRIM(BOTH '#' FROM '##SQL##')   AS B,  -- SQL
       LTRIM('xxDevmaster', 'x')       AS C,  -- Devmaster
       RTRIM('SQL2022...', '.')        AS D;  -- SQL2022
GO

DECLARE @t datetime2(0) = '2026-10-07T15:20:45';
SELECT DATETRUNC(month,   @t) AS MonthStart,    -- 2026-10-01 00:00:00
       DATETRUNC(quarter, @t) AS QuarterStart,  -- 2026-10-01 00:00:00
       DATETRUNC(year,    @t) AS YearStart,     -- 2026-01-01 00:00:00
       DATETRUNC(hour,    @t) AS HourStart;     -- 2026-10-07 15:00:00
GO

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
GO

SELECT StudentId, Flags,
       GET_BIT(Flags, 1) AS HasScholarship,
       BIT_COUNT(Flags)  AS NumFlags
FROM dbo.Students
WHERE StudentId <= 5;
-- Flags 1,3,5,0,7 → HasScholarship 0,1,0,0,1 · NumFlags 1,2,2,0,3

BEGIN TRANSACTION;                                          -- thử rồi hoàn tác
    UPDATE dbo.Students SET Flags = SET_BIT(Flags, 2) WHERE StudentId = 1;
    SELECT Flags FROM dbo.Students WHERE StudentId = 1;     -- 5
ROLLBACK TRANSACTION;

SELECT LEFT_SHIFT(1, 2) AS Mask, RIGHT_SHIFT(8, 1) AS Half;   -- 4 · 4
GO
