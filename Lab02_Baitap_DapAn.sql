/* =====================================================================
   Devmaster Academy – BUỔI 2 – ĐÁP ÁN LAB 2 & BÀI TẬP VỀ NHÀ (dành cho giảng viên)
   Chạy tuần tự trên CSDL DevmasterLab mới tạo (00_DevmasterLab_Setup.sql), rồi chạy file này.
   Kết quả mong đợi ghi trong chú thích. Bài 3 phải chạy KHÔNG lỗi nếu Bài 1–2 đúng đặc tả.
   Thang điểm gợi ý (10): Bài 1 · 1,5 | Bài 2 · 1,5 | Bài 3 · 1 | Bài 4 · 2 | Bài 5 · 2 | Bài 6 (nâng cao) · 2.
   Tiêu chí kèm theo: tên ràng buộc đúng quy ước PK_/FK_/UQ_/DF_/CK_ (20%) và script chạy lại được (20%).
   ===================================================================== */
USE DevmasterLab;
GO

-- Bài 1. dbo.Enrollments
DROP TABLE IF EXISTS dbo.Payments, dbo.Enrollments;   -- con trước, cha sau
GO
CREATE TABLE dbo.Enrollments (
    EnrollmentId int IDENTITY(1,1) CONSTRAINT PK_Enrollments PRIMARY KEY,
    StudentId    int           NOT NULL
                 CONSTRAINT FK_Enrollments_Students REFERENCES dbo.Students(StudentId),
    CourseId     int           NOT NULL
                 CONSTRAINT FK_Enrollments_Courses REFERENCES dbo.Courses(CourseId),
    EnrolledAt   datetime2(0)  NOT NULL CONSTRAINT DF_Enrollments_EnrolledAt DEFAULT SYSDATETIME(),
    PaidAmount   decimal(12,0) NOT NULL CONSTRAINT DF_Enrollments_Paid DEFAULT 0
                 CONSTRAINT CK_Enrollments_Paid CHECK (PaidAmount >= 0),
    Score1       decimal(4,2)  NULL,
    Score2       decimal(4,2)  NULL,
    Score3       decimal(4,2)  NULL,
    Status       varchar(20)   NOT NULL CONSTRAINT DF_Enrollments_Status DEFAULT 'Active',
    CONSTRAINT CK_Enrollments_Scores CHECK (Score1 BETWEEN 0 AND 10
                                        AND Score2 BETWEEN 0 AND 10
                                        AND Score3 BETWEEN 0 AND 10),
    CONSTRAINT CK_Enrollments_Status CHECK (Status IN ('Active', 'Completed', 'Cancelled'))
);
-- Lưu ý chấm: CHECK với giá trị NULL cho kết quả UNKNOWN nên vẫn được chấp nhận → điểm để trống hợp lệ.
GO

-- Bài 2. dbo.Payments
CREATE TABLE dbo.Payments (
    PaymentId    int IDENTITY(1,1) CONSTRAINT PK_Payments PRIMARY KEY,
    EnrollmentId int           NOT NULL
                 CONSTRAINT FK_Payments_Enrollments REFERENCES dbo.Enrollments(EnrollmentId)
                 ON DELETE CASCADE,
    Amount       decimal(12,0) NOT NULL CONSTRAINT CK_Payments_Amount CHECK (Amount > 0),
    PaidAt       datetime2(0)  NOT NULL CONSTRAINT DF_Payments_PaidAt DEFAULT SYSDATETIME(),
    Method       varchar(20)   NOT NULL CONSTRAINT DF_Payments_Method DEFAULT 'Transfer'
                 CONSTRAINT CK_Payments_Method CHECK (Method IN ('Cash', 'Transfer', 'Card'))
);
GO

-- Bài 3. Dữ liệu
SET IDENTITY_INSERT dbo.Enrollments ON;
INSERT INTO dbo.Enrollments (EnrollmentId, StudentId, CourseId, EnrolledAt, PaidAmount, Score1, Score2, Score3, Status) VALUES
 (1, 1, 1, '2026-09-07T09:15:00', 9000000, 7.50, 8.00, NULL, 'Active'),
 (2, 2, 2, '2026-09-08T14:00:00', 6000000, 6.00, NULL, 7.50, 'Completed'),
 (3, 3, 1, '2026-09-10T10:30:00', 18000000, 8.50, 9.00, 8.00, 'Active'),
 (4, 1, 2, '2026-09-15T19:00:00', 6000000, NULL, 8.50, 9.00, 'Completed'),
 (5, 4, 3, '2026-09-17T08:45:00', 4000000, 5.50, 6.50, 7.00, 'Active'),
 (6, 5, 4, '2026-09-30T20:10:00', 9000000, 9.00, NULL, NULL, 'Active'),
 (7, 6, 2, '2026-10-01T09:00:00', 3000000, NULL, NULL, NULL, 'Cancelled'),
 (8, 7, 1, '2026-10-06T15:20:00', 9000000, 7.00, 7.50, 8.00, 'Active'),
 (9, 8, 3, '2026-10-08T11:00:00', 8000000, 6.50, NULL, 8.50, 'Active'),
 (10, 1, 4, '2026-10-20T18:30:00', 4500000, 8.00, 8.50, NULL, 'Active'),
 (11, 5, 2, '2026-10-22T09:40:00', 6000000, 9.50, 9.00, 9.50, 'Active'),
 (12, 3, 3, '2026-10-23T13:15:00', 8000000, NULL, 7.00, NULL, 'Active'),
 (13, 10, 5, '2026-09-09T10:00:00', 7500000, 7.00, 8.00, NULL, 'Active'),
 (14, 11, 1, '2026-09-16T14:30:00', 9000000, 8.00, NULL, NULL, 'Active'),
 (15, 11, 5, '2026-10-02T19:45:00', 3750000, NULL, NULL, NULL, 'Active'),
 (16, 2, 8, '2026-10-07T08:30:00', 2500000, 9.00, 9.50, NULL, 'Completed'),
 (17, 7, 8, '2026-10-09T16:00:00', 0, NULL, NULL, NULL, 'Active'),
 (18, 4, 5, '2026-10-19T10:10:00', 7500000, NULL, NULL, NULL, 'Active'),
 (19, 10, 2, '2026-10-21T20:00:00', 6000000, 7.50, 8.00, 8.50, 'Active'),
 (20, 8, 4, '2026-10-24T09:30:00', 4500000, NULL, NULL, NULL, 'Active');
SET IDENTITY_INSERT dbo.Enrollments OFF;

SET IDENTITY_INSERT dbo.Payments ON;
INSERT INTO dbo.Payments (PaymentId, EnrollmentId, Amount, PaidAt, Method) VALUES
 (1, 1, 9000000, '2026-09-07T09:20:00', 'Transfer'),
 (2, 2, 6000000, '2026-09-08T14:05:00', 'Card'),
 (3, 3, 9000000, '2026-09-10T10:35:00', 'Transfer'),
 (4, 3, 9000000, '2026-09-30T10:35:00', 'Transfer'),
 (5, 4, 6000000, '2026-09-16T19:05:00', 'Cash'),
 (6, 5, 4000000, '2026-09-17T08:50:00', 'Cash'),
 (7, 6, 9000000, '2026-09-30T20:15:00', 'Card'),
 (8, 7, 3000000, '2026-10-01T09:05:00', 'Transfer'),
 (9, 8, 9000000, '2026-10-06T15:25:00', 'Transfer'),
 (10, 9, 5000000, '2026-10-08T11:05:00', 'Card'),
 (11, 9, 3000000, '2026-10-18T11:05:00', 'Card'),
 (12, 10, 4500000, '2026-10-20T18:35:00', 'Transfer'),
 (13, 11, 6000000, '2026-10-22T09:45:00', 'Card'),
 (14, 12, 8000000, '2026-10-23T13:20:00', 'Transfer'),
 (15, 13, 7500000, '2026-09-09T10:05:00', 'Transfer'),
 (16, 14, 9000000, '2026-09-16T14:35:00', 'Transfer'),
 (17, 15, 3750000, '2026-10-02T19:50:00', 'Card'),
 (18, 16, 2500000, '2026-10-07T08:35:00', 'Cash'),
 (19, 18, 7500000, '2026-10-21T10:15:00', 'Transfer'),
 (20, 19, 6000000, '2026-10-21T20:05:00', 'Card'),
 (21, 20, 4500000, '2026-10-24T09:35:00', 'Transfer');
SET IDENTITY_INSERT dbo.Payments OFF;
GO
SELECT (SELECT COUNT(*) FROM dbo.Enrollments) AS NumEnrollments,   -- 20
       (SELECT COUNT(*) FROM dbo.Payments)    AS NumPayments;      -- 21
GO

-- Bài 4. Vi phạm ràng buộc (mỗi câu báo lỗi, batch vẫn chạy tiếp)
INSERT INTO dbo.Enrollments (StudentId, CourseId) VALUES (999, 1);
-- Msg 547: FOREIGN KEY FK_Enrollments_Students – học viên 999 không tồn tại
INSERT INTO dbo.Students (FullName, Email) VALUES (N'Trùng', 'an.nv@devmaster.vn');
-- Msg 2627: UNIQUE UQ_Students_Email – email đã tồn tại
INSERT INTO dbo.Payments (EnrollmentId, Amount) VALUES (1, NULL);
-- Msg 515: cột Amount không cho phép NULL
UPDATE dbo.Enrollments SET Score1 = 11 WHERE EnrollmentId = 1;
-- Msg 547: CHECK CK_Enrollments_Scores – điểm vượt 10
INSERT INTO dbo.Students (FullName, Email, Phone) VALUES (N'Số dài', 'z@devmaster.vn', REPLICATE('9', 30));
-- Msg 2628: String or binary data would be truncated (Phone là varchar(15), chuỗi dài 30 ký tự)
GO

-- Bài 5. Tăng 5% học phí danh mục "Dữ liệu" và danh mục con
BEGIN TRANSACTION;                                          -- thử trong giao tác để không làm đổi dữ liệu chuẩn
    UPDATE c
    SET c.Fee = c.Fee * 1.05                                -- cột decimal(12,0) nên kết quả tự làm tròn đến đồng
    OUTPUT inserted.CourseCode, deleted.Fee AS OldFee, inserted.Fee AS NewFee
    FROM dbo.Courses AS c
    WHERE c.CategoryId IN (SELECT CategoryId
                           FROM dbo.Categories
                           WHERE CategoryName = N'Dữ liệu'
                              OR ParentId = (SELECT CategoryId FROM dbo.Categories
                                             WHERE CategoryName = N'Dữ liệu'));
    -- Kết quả mong đợi: 3 dòng – SQL-DEV 6.000.000 → 6.300.000 · PY-DA 7.500.000 → 7.875.000 · PBI 5.000.000 → 5.250.000
    -- Danh mục "Dữ liệu" (Id 2) có con là 6 và 7; bản thân danh mục 2 không có khóa học trực tiếp.
ROLLBACK TRANSACTION;                                       -- trả lại giá gốc (học phí được dùng ở các buổi sau)
GO

-- Bài 6. ON DELETE CASCADE
BEGIN TRANSACTION;
    SELECT COUNT(*) AS PaymentsBefore FROM dbo.Payments WHERE EnrollmentId = 9;   -- 2 (PaymentId 10 và 11)
    DELETE FROM dbo.Enrollments WHERE EnrollmentId = 9;
    SELECT COUNT(*) AS PaymentsAfter  FROM dbo.Payments WHERE EnrollmentId = 9;   -- 0
ROLLBACK TRANSACTION;
-- TRUNCATE TABLE dbo.Enrollments → Msg 4712: bảng đang được FK_Payments_Enrollments tham chiếu.
-- TRUNCATE không xóa theo từng dòng nên không thực hiện được hành động CASCADE.
GO

/* =====================================================================
   BÀI TẬP VỀ NHÀ
   ===================================================================== */
-- BT1 + BT2. Migration chạy lại nhiều lần không lỗi
IF OBJECT_ID(N'dbo.Instructors', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Instructors (
        InstructorId int IDENTITY(1,1) CONSTRAINT PK_Instructors PRIMARY KEY,
        FullName     nvarchar(100) NOT NULL,
        Email        varchar(150)  NOT NULL CONSTRAINT UQ_Instructors_Email UNIQUE,
        HireDate     date          NOT NULL CONSTRAINT DF_Instructors_HireDate DEFAULT CAST(SYSDATETIME() AS date),
        IsActive     bit           NOT NULL CONSTRAINT DF_Instructors_IsActive DEFAULT 1
    );
END
GO
IF COL_LENGTH(N'dbo.Courses', N'InstructorId') IS NULL
BEGIN
    ALTER TABLE dbo.Courses ADD InstructorId int NULL;
END
GO
IF OBJECT_ID(N'dbo.FK_Courses_Instructors', N'F') IS NULL
BEGIN
    ALTER TABLE dbo.Courses
        ADD CONSTRAINT FK_Courses_Instructors FOREIGN KEY (InstructorId)
            REFERENCES dbo.Instructors(InstructorId);
END
GO

-- BT3. MERGE từ bảng tạm
DROP TABLE IF EXISTS #PriceList;
CREATE TABLE #PriceList (CourseCode varchar(20) PRIMARY KEY, Fee decimal(12,0) NOT NULL);
INSERT INTO #PriceList VALUES ('SQL-DEV', 6200000), ('GIT', 2500000), ('K8S', 4000000);

BEGIN TRANSACTION;                                         -- thử trong giao tác để giữ dữ liệu chuẩn
    MERGE dbo.Courses AS t
    USING #PriceList AS s
       ON t.CourseCode = s.CourseCode
    WHEN MATCHED AND t.Fee <> s.Fee THEN
        UPDATE SET t.Fee = s.Fee
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (CourseCode, CourseName, CategoryId, Fee, Hours)
        VALUES (s.CourseCode, s.CourseCode, 1, s.Fee, 40)
    OUTPUT $action AS Action, inserted.CourseCode, deleted.Fee AS OldFee, inserted.Fee AS NewFee;
    -- Kết quả mong đợi: 2 dòng – UPDATE SQL-DEV 6.000.000 → 6.200.000 · INSERT K8S (OldFee NULL → 4.000.000)
    -- GIT trùng học phí nên không phát sinh hành động. Không có WHEN NOT MATCHED BY SOURCE → không xóa khóa nào.
    SELECT COUNT(*) AS NumCourses FROM dbo.Courses;       -- 9 (8 khóa gốc + K8S)
ROLLBACK TRANSACTION;
SELECT COUNT(*) AS NumCoursesRestored FROM dbo.Courses;   -- 8
DROP TABLE IF EXISTS #PriceList;
-- Lưu ý khi dạy: MERGE phải kết thúc bằng dấu chấm phẩy; trong môi trường đồng thời nên thêm WITH (HOLDLOCK)
-- vào bảng đích để tránh xung đột khóa; lỗi nghiệp vụ thường gặp là thiếu cột NOT NULL khi INSERT (CategoryId, Hours).
GO

-- BT4. Backup / restore (đổi đường dẫn cho phù hợp máy; trên container Linux dùng /var/opt/mssql/...)
/*
BACKUP DATABASE DevmasterLab TO DISK = N'C:\SQLBackup\DevmasterLab.bak' WITH COPY_ONLY, INIT, CHECKSUM, STATS = 10;
RESTORE VERIFYONLY FROM DISK = N'C:\SQLBackup\DevmasterLab.bak' WITH CHECKSUM;
RESTORE DATABASE DevmasterLab_Test FROM DISK = N'C:\SQLBackup\DevmasterLab.bak'
WITH MOVE 'DevmasterLab'     TO N'C:\SQLData\DevmasterLab_Test.mdf',
     MOVE 'DevmasterLab_log' TO N'C:\SQLData\DevmasterLab_Test_log.ldf', STATS = 10;
-- Kiểm tra số dòng 5 bảng ở bản gốc và bản khôi phục (kết quả mong đợi: 8 · 8 · 12 · 20 · 21 – hai bản giống nhau)
SELECT N'Categories' AS TableName, (SELECT COUNT(*) FROM DevmasterLab.dbo.Categories)      AS Src, (SELECT COUNT(*) FROM DevmasterLab_Test.dbo.Categories)  AS Dst
UNION ALL SELECT N'Courses',      (SELECT COUNT(*) FROM DevmasterLab.dbo.Courses),      (SELECT COUNT(*) FROM DevmasterLab_Test.dbo.Courses)
UNION ALL SELECT N'Students',     (SELECT COUNT(*) FROM DevmasterLab.dbo.Students),     (SELECT COUNT(*) FROM DevmasterLab_Test.dbo.Students)
UNION ALL SELECT N'Enrollments',  (SELECT COUNT(*) FROM DevmasterLab.dbo.Enrollments),  (SELECT COUNT(*) FROM DevmasterLab_Test.dbo.Enrollments)
UNION ALL SELECT N'Payments',     (SELECT COUNT(*) FROM DevmasterLab.dbo.Payments),     (SELECT COUNT(*) FROM DevmasterLab_Test.dbo.Payments);
-- COPY_ONLY: bản sao lưu không làm đổi chuỗi sao lưu vi sai (differential base) của CSDL gốc.
-- Dọn dẹp sau khi thử: DROP DATABASE DevmasterLab_Test;
*/
