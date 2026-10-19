/* =====================================================================
   Devmaster Academy – Hệ quản trị CSDL SQL Server 2022
   BUỔI 3 – Truy vấn dữ liệu: lọc, sắp xếp, nhóm, kết nối
   File: Buoi3_Demo.sql – code demo theo thứ tự slide
   Chuẩn bị: chạy 00_DevmasterLab_Setup.sql trước
   ===================================================================== */
USE DevmasterLab;
GO

/* ---------------------------------------------------------------------
   PHẦN 1 – SELECT CƠ BẢN
   --------------------------------------------------------------------- */
/* Khung câu lệnh (không chạy)
SELECT   [DISTINCT] [TOP (n)] <danh sách cột / biểu thức>
FROM     <bảng> [JOIN <bảng> ON <điều kiện>]
WHERE    <điều kiện lọc dòng>
GROUP BY <cột nhóm>
HAVING   <điều kiện lọc nhóm>
ORDER BY <cột sắp xếp> [ASC | DESC]
OFFSET n ROWS FETCH NEXT m ROWS ONLY;
*/

-- Chọn cột cụ thể (không dùng * trong code ứng dụng)
SELECT CourseCode, CourseName, Fee
FROM dbo.Courses;

-- Bí danh cột, hằng, biểu thức
SELECT CourseCode               AS Code,
       N'khóa học'              AS Kind,          -- hằng
       Fee / Hours              AS FeePerHour,    -- biểu thức
       Fee * 1.08               AS FeeWithVAT,
       CONCAT(CourseCode, N' – ', CourseName) AS Title
FROM dbo.Courses;

-- SELECT không cần FROM
SELECT SYSDATETIME() AS Now, 2 + 3 AS Result;
GO

SELECT e.EnrollmentId,
       e.Score3,
       CASE
           WHEN e.Score3 IS NULL THEN N'Chưa thi'
           WHEN e.Score3 >= 8.5  THEN N'Giỏi'
           WHEN e.Score3 >= 7.0  THEN N'Khá'
           WHEN e.Score3 >= 5.0  THEN N'Trung bình'
           ELSE N'Chưa đạt'
       END AS Grade
FROM dbo.Enrollments AS e;
GO

/* ---------------------------------------------------------------------
   PHẦN 2 – LỌC VÀ SẮP XẾP
   --------------------------------------------------------------------- */
-- AND được ưu tiên trước OR → kết quả KHÁC nhau
SELECT FullName, City, Flags
FROM dbo.Students
WHERE City = N'Hà Nội' OR City = N'Bắc Ninh'
  AND Flags > 1;                        -- 5 dòng

SELECT FullName, City, Flags
FROM dbo.Students
WHERE (City = N'Hà Nội' OR City = N'Bắc Ninh')
  AND Flags > 1;                        -- 3 dòng
GO

-- IN: thuộc một tập giá trị
SELECT CourseCode, Fee FROM dbo.Courses
WHERE CourseCode IN ('SQL-DEV', 'PY-DA', 'PBI');

-- BETWEEN: bao gồm cả hai đầu mút
SELECT CourseCode, Fee FROM dbo.Courses
WHERE Fee BETWEEN 5000000 AND 9000000;

-- Khoảng thời gian với datetime2: dùng >= và < (an toàn hơn BETWEEN)
SELECT EnrollmentId, EnrolledAt FROM dbo.Enrollments
WHERE EnrolledAt >= '2026-10-01' AND EnrolledAt < '2026-11-01';

-- NULL: dùng IS NULL / IS NOT NULL
SELECT FullName FROM dbo.Students WHERE Phone IS NULL;
GO

SELECT FullName FROM dbo.Students
WHERE FullName LIKE N'Nguyễn%';          -- bắt đầu bằng
SELECT FullName FROM dbo.Students
WHERE FullName LIKE N'%Thu%';            -- chứa
SELECT CourseCode FROM dbo.Courses
WHERE CourseCode LIKE '___';             -- đúng 3 ký tự
SELECT CourseCode FROM dbo.Courses
WHERE CourseCode LIKE '[A-P]%';          -- ký tự đầu A..P
SELECT CourseCode FROM dbo.Courses
WHERE CourseCode LIKE '[^A-P]%';         -- ngoài A..P
-- Tìm chính ký tự _ hoặc %: dùng ESCAPE
SELECT CASE WHEN 'SQL_2022' LIKE '%!_%' ESCAPE '!'
            THEN 1 ELSE 0 END AS HasUnderscore;
GO

SELECT DISTINCT City FROM dbo.Students;        -- mỗi TP 1 lần
SELECT DISTINCT City, Flags FROM dbo.Students; -- trùng cả dòng
SELECT COUNT(DISTINCT City) AS NumCities       -- không đếm NULL
FROM dbo.Students;
GO

SELECT CourseCode, CategoryId, Fee
FROM dbo.Courses
ORDER BY CategoryId ASC, Fee DESC;   -- ưu tiên từ trái sang

SELECT FullName, BirthDate
FROM dbo.Students
ORDER BY BirthDate;                  -- NULL đứng đầu khi ASC

SELECT CourseCode, Fee / Hours AS FeePerHour
FROM dbo.Courses
ORDER BY FeePerHour DESC;            -- dùng được bí danh
GO

SELECT TOP (3) CourseCode, Fee
FROM dbo.Courses
ORDER BY Fee DESC;

SELECT TOP (1) WITH TIES CourseCode, Hours  -- 2 khóa 240 giờ
FROM dbo.Courses
ORDER BY Hours DESC;

SELECT TOP (25) PERCENT FullName
FROM dbo.Students
ORDER BY StudentId;                    -- 3/12 dòng
GO

DECLARE @Page int = 2, @PageSize int = 5;

SELECT StudentId, FullName, Email
FROM dbo.Students
ORDER BY StudentId              -- bắt buộc
OFFSET (@Page - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

-- Tổng số dòng để tính số trang
SELECT COUNT(*) AS TotalRows
FROM dbo.Students;
GO

/* ---------------------------------------------------------------------
   PHẦN 3 – HÀM TỔNG HỢP VÀ NHÓM
   --------------------------------------------------------------------- */
SELECT COUNT(*)            AS NumRows,     -- mọi dòng
       COUNT(Score3)       AS NumScore3,   -- bỏ NULL
       COUNT(DISTINCT StudentId) AS NumStudents,
       SUM(PaidAmount)     AS TotalPaid,
       AVG(PaidAmount)     AS AvgPaid,
       MIN(EnrolledAt)     AS FirstDate,
       MAX(EnrolledAt)     AS LastDate
FROM dbo.Enrollments;

-- Bẫy chia nguyên: AVG trên cột int trả về int
SELECT AVG(Hours) AS AvgHoursInt,
       AVG(CAST(Hours AS decimal(10,2))) AS AvgHoursDec
FROM dbo.Courses;
GO

SELECT Status,
       COUNT(*)        AS NumEnrollments,
       SUM(PaidAmount) AS TotalPaid
FROM dbo.Enrollments
GROUP BY Status
ORDER BY TotalPaid DESC;

-- Lỗi Msg 8120: StudentId không nằm
-- trong GROUP BY hay hàm tổng hợp
-- SELECT Status, StudentId, COUNT(*)
-- FROM dbo.Enrollments GROUP BY Status;
GO

SELECT City, COUNT(*) AS NumStudents
FROM dbo.Students
WHERE City IS NOT NULL     -- lọc DÒNG trước khi nhóm
GROUP BY City
HAVING COUNT(*) >= 2       -- lọc NHÓM sau khi nhóm
ORDER BY NumStudents DESC;
GO

-- Danh sách khóa học của từng học viên trên một dòng
SELECT e.StudentId,
       STRING_AGG(c.CourseCode, ', ')
           WITHIN GROUP (ORDER BY e.EnrolledAt) AS Courses
FROM dbo.Enrollments AS e
JOIN dbo.Courses AS c ON c.CourseId = e.CourseId
GROUP BY e.StudentId;

-- Trung vị xấp xỉ (SQL Server 2022)
SELECT CourseId,
       APPROX_PERCENTILE_CONT(0.5)
           WITHIN GROUP (ORDER BY PaidAmount) AS MedianPaid
FROM dbo.Enrollments
GROUP BY CourseId;
GO

SELECT c.CategoryId,
       e.Status,
       SUM(e.PaidAmount) AS Total
FROM dbo.Enrollments AS e
JOIN dbo.Courses AS c ON c.CourseId = e.CourseId
GROUP BY ROLLUP (c.CategoryId, e.Status);
-- thêm dòng tổng phụ theo CategoryId
-- và một dòng tổng cộng (cả hai cột NULL)
GO

SELECT   City, COUNT(*) AS NumStudents      -- 5
FROM     dbo.Students                       -- 1
WHERE    City LIKE N'Hà%'                   -- 2
GROUP BY City                               -- 3
HAVING   COUNT(*) > 1                       -- 4
ORDER BY NumStudents DESC;                  -- 6
-- HAVING NumStudents > 1 → Msg 207: Invalid column name
GO

/* ---------------------------------------------------------------------
   PHẦN 4 – KẾT NỐI BẢNG (JOIN)
   --------------------------------------------------------------------- */
SELECT s.FullName,
       c.CourseCode,
       e.EnrolledAt,
       e.PaidAmount
FROM dbo.Enrollments AS e
INNER JOIN dbo.Students AS s ON s.StudentId = e.StudentId
INNER JOIN dbo.Courses  AS c ON c.CourseId  = e.CourseId
WHERE c.CourseCode = 'NET-FS'
ORDER BY e.EnrolledAt;
GO

-- Mọi khóa học, kể cả khóa chưa có ai ghi danh
SELECT c.CourseCode,
       COUNT(e.EnrollmentId)          AS NumEnrollments,
       COALESCE(SUM(e.PaidAmount), 0) AS Revenue
FROM dbo.Courses AS c
LEFT JOIN dbo.Enrollments AS e ON e.CourseId = c.CourseId
GROUP BY c.CourseCode
ORDER BY Revenue DESC;

-- Anti-join: học viên CHƯA ghi danh khóa nào
SELECT s.FullName
FROM dbo.Students AS s
LEFT JOIN dbo.Enrollments AS e ON e.StudentId = s.StudentId
WHERE e.EnrollmentId IS NULL;
GO

-- RIGHT JOIN = LEFT JOIN đổi chỗ hai bảng
SELECT c.CourseCode, e.EnrollmentId
FROM dbo.Enrollments AS e
RIGHT JOIN dbo.Courses AS c ON c.CourseId = e.CourseId;

-- FULL JOIN: giữ dòng không khớp ở CẢ HAI phía
SELECT s.FullName, e.EnrollmentId, e.Status
FROM dbo.Students AS s
FULL OUTER JOIN dbo.Enrollments AS e
     ON  e.StudentId = s.StudentId
     AND e.Status = 'Completed';
GO

-- Mọi tổ hợp học viên Hà Nội × khóa đang mở
SELECT s.FullName, c.CourseCode
FROM dbo.Students AS s
CROSS JOIN dbo.Courses AS c
WHERE s.City = N'Hà Nội'
  AND c.IsActive = 1;          -- 4 × 7 = 28 dòng
GO

-- Cùng một bảng, hai bí danh
SELECT parent.CategoryName AS Parent,
       child.CategoryName  AS Child
FROM dbo.Categories AS child
JOIN dbo.Categories AS parent
     ON parent.CategoryId = child.ParentId
ORDER BY Parent, Child;
GO

SELECT cat.CategoryName,
       COUNT(e.EnrollmentId)          AS NumEnrollments,
       COALESCE(SUM(e.PaidAmount), 0) AS Revenue
FROM dbo.Categories AS cat
LEFT JOIN dbo.Courses     AS c ON c.CategoryId = cat.CategoryId
LEFT JOIN dbo.Enrollments AS e ON e.CourseId   = c.CourseId
GROUP BY cat.CategoryName
ORDER BY Revenue DESC;
-- Sai thường gặp: COUNT(*) đếm cả dòng NULL do LEFT JOIN sinh ra
GO
