/* =====================================================================
   Devmaster Academy – BUỔI 2 – ĐÁP ÁN LAB 2B & BÀI TẬP VỀ NHÀ (dành cho giảng viên)
   Chạy tuần tự trên dữ liệu gốc (00_DevmasterLab_Setup.sql). Kết quả mong đợi ghi trong chú thích.
   ===================================================================== */
USE DevmasterLab;
GO

-- Bài 1.
DROP TABLE IF EXISTS dbo.Attendance, dbo.ClassStudents, dbo.Classes,   -- con trước, cha sau
                     dbo.ClassesArchive, dbo.Rooms;                    -- bảng của phần bài tập về nhà
DROP SEQUENCE IF EXISTS dbo.seq_ClassNo;
GO
CREATE TABLE dbo.Classes (
    ClassId     int IDENTITY(1,1) CONSTRAINT PK_Classes PRIMARY KEY,
    ClassCode   varchar(20) NOT NULL CONSTRAINT UQ_Classes_Code UNIQUE,
    CourseId    int         NOT NULL
                CONSTRAINT FK_Classes_Courses REFERENCES dbo.Courses(CourseId),
    StartDate   date        NOT NULL,
    EndDate     date        NOT NULL,
    MaxStudents int         NOT NULL CONSTRAINT DF_Classes_Max DEFAULT 30
                CONSTRAINT CK_Classes_Max CHECK (MaxStudents BETWEEN 5 AND 60),
    Room        nvarchar(30) NULL,
    Status      varchar(20) NOT NULL CONSTRAINT DF_Classes_Status DEFAULT 'Open',
    CONSTRAINT CK_Classes_Dates  CHECK (EndDate > StartDate),
    CONSTRAINT CK_Classes_Status CHECK (Status IN ('Open', 'Running', 'Closed'))
);
GO

-- Bài 2.
CREATE TABLE dbo.ClassStudents (
    ClassId   int NOT NULL CONSTRAINT FK_ClassStudents_Classes  REFERENCES dbo.Classes(ClassId),
    StudentId int NOT NULL CONSTRAINT FK_ClassStudents_Students REFERENCES dbo.Students(StudentId),
    JoinedAt  datetime2(0) NOT NULL CONSTRAINT DF_ClassStudents_JoinedAt DEFAULT SYSDATETIME(),
    Grade     decimal(4,2) NULL CONSTRAINT CK_ClassStudents_Grade CHECK (Grade BETWEEN 0 AND 10),
    CONSTRAINT PK_ClassStudents PRIMARY KEY (ClassId, StudentId)
);
-- Không cần cột Id: cặp (ClassId, StudentId) đã định danh duy nhất một dòng, đồng thời tự chặn học viên
-- bị ghi danh hai lần vào cùng lớp. Đây là bảng liên kết (quan hệ nhiều–nhiều giữa Classes và Students).
GO

-- Bài 3.
CREATE TABLE dbo.Attendance (
    AttendanceId int IDENTITY(1,1) CONSTRAINT PK_Attendance PRIMARY KEY,
    ClassId      int  NOT NULL,
    StudentId    int  NOT NULL,
    SessionDate  date NOT NULL,
    IsPresent    bit  NOT NULL CONSTRAINT DF_Attendance_Present DEFAULT 1,
    Note         nvarchar(200) NULL,
    CONSTRAINT FK_Attendance_ClassStudents FOREIGN KEY (ClassId, StudentId)
        REFERENCES dbo.ClassStudents (ClassId, StudentId) ON DELETE CASCADE,
    CONSTRAINT UQ_Attendance_Session UNIQUE (ClassId, StudentId, SessionDate)
);
GO

-- Bài 4.
INSERT INTO dbo.Classes (ClassCode, CourseId, StartDate, EndDate, MaxStudents, Room) VALUES
 ('SQL-K01',   2, '2026-10-05', '2026-12-14', 25, N'P301'),
 ('REACT-K02', 3, '2026-10-12', '2027-01-18', 30, N'P302'),
 ('GIT-K01',   8, '2026-11-02', '2026-11-27', 20, NULL);
SELECT ClassId, ClassCode, CourseId, StartDate, EndDate, MaxStudents, Room, Status FROM dbo.Classes;
-- 3 dòng; ClassId 1, 2, 3; Status = 'Open' (giá trị mặc định)
GO

-- Bài 5.
INSERT INTO dbo.ClassStudents (ClassId, StudentId)
SELECT c.ClassId, s.StudentId
FROM dbo.Classes AS c
CROSS JOIN dbo.Students AS s
WHERE c.ClassCode = 'SQL-K01' AND s.City = N'Hà Nội';
SELECT @@ROWCOUNT AS Added_a;                      -- 4: học viên 1, 3, 5, 10

INSERT INTO dbo.ClassStudents (ClassId, StudentId)
SELECT c.ClassId, s.StudentId
FROM dbo.Classes AS c
CROSS JOIN dbo.Students AS s
WHERE c.ClassCode = 'REACT-K02' AND (s.Flags & 2) = 2;
SELECT @@ROWCOUNT AS Added_b;                      -- 4: học viên 2, 5, 8, 11
GO

-- Bài 6.
DECLARE @cid int = (SELECT ClassId FROM dbo.Classes WHERE ClassCode = 'SQL-K01');
INSERT INTO dbo.Attendance (ClassId, StudentId, SessionDate)
SELECT ClassId, StudentId, '2026-10-05' FROM dbo.ClassStudents WHERE ClassId = @cid;
INSERT INTO dbo.Attendance (ClassId, StudentId, SessionDate)
SELECT ClassId, StudentId, '2026-10-07' FROM dbo.ClassStudents WHERE ClassId = @cid;

UPDATE dbo.Attendance SET IsPresent = 0, Note = N'Ốm'
WHERE ClassId = @cid AND StudentId = 10 AND SessionDate = '2026-10-05';
UPDATE dbo.Attendance SET IsPresent = 0
WHERE ClassId = @cid AND StudentId IN (3, 10) AND SessionDate = '2026-10-07';

SELECT COUNT(*) AS NumAbsent FROM dbo.Attendance WHERE IsPresent = 0;   -- 3
SELECT COUNT(*) AS NumRows   FROM dbo.Attendance;                       -- 8 (2 buổi × 4 học viên)
GO

-- Bài 7.
INSERT INTO dbo.Classes (ClassCode, CourseId, StartDate, EndDate)
VALUES ('X-1', 2, '2026-12-01', '2026-11-01');                      -- (a) Msg 547: vi phạm CK_Classes_Dates
INSERT INTO dbo.Classes (ClassCode, CourseId, StartDate, EndDate, MaxStudents)
VALUES ('X-2', 2, '2026-12-01', '2026-12-31', 3);                   -- (b) Msg 547: vi phạm CK_Classes_Max
INSERT INTO dbo.Attendance (ClassId, StudentId, SessionDate)
VALUES (1, 9, '2026-10-05');                                        -- (c) Msg 547: vi phạm FK_Attendance_ClassStudents (HV 9 chưa thuộc lớp 1)
INSERT INTO dbo.Attendance (ClassId, StudentId, SessionDate)
VALUES (1, 1, '2026-10-05');                                        -- (d) Msg 2627: vi phạm UQ_Attendance_Session
INSERT INTO dbo.Classes (ClassCode, CourseId, StartDate, EndDate, Status)
VALUES ('X-5', 2, '2026-12-01', '2026-12-31', 'Paused');            -- (e) Msg 547: vi phạm CK_Classes_Status
-- Không dòng nào được thêm. Chạy từng lệnh riêng để đọc được từng thông báo lỗi.
GO

-- Bài 8.
UPDATE c
SET EndDate = DATEADD(day, 7, c.EndDate)
OUTPUT inserted.ClassCode, deleted.EndDate AS OldEnd, inserted.EndDate AS NewEnd
FROM dbo.Classes    AS c
JOIN dbo.Courses    AS co  ON co.CourseId   = c.CourseId
JOIN dbo.Categories AS cat ON cat.CategoryId = co.CategoryId
WHERE cat.CategoryId = 1 OR cat.ParentId = 1;
-- 2 dòng: REACT-K02 2027-01-18 → 2027-01-25 · GIT-K01 2026-11-27 → 2026-12-04
-- SQL-K01 (khóa SQL-DEV thuộc "Dữ liệu") không bị ảnh hưởng.
GO

-- Bài 9.
BEGIN TRANSACTION;
    SELECT (SELECT COUNT(*) FROM dbo.ClassStudents) AS ClassStudents_Before,    -- 8
           (SELECT COUNT(*) FROM dbo.Attendance)    AS Attendance_Before;       -- 8

    DELETE cs
    OUTPUT deleted.ClassId, deleted.StudentId
    FROM dbo.ClassStudents AS cs
    WHERE cs.StudentId = 10
      AND cs.ClassId = (SELECT ClassId FROM dbo.Classes WHERE ClassCode = 'SQL-K01');

    SELECT (SELECT COUNT(*) FROM dbo.ClassStudents) AS ClassStudents_After,     -- 7
           (SELECT COUNT(*) FROM dbo.Attendance)    AS Attendance_After;        -- 6 (2 dòng điểm danh bị xóa theo)
ROLLBACK TRANSACTION;
SELECT COUNT(*) AS Attendance_Restored FROM dbo.Attendance;                     -- 8
GO

-- Bài 10.
ALTER TABLE dbo.Classes
    ADD DurationDays AS (DATEDIFF(day, StartDate, EndDate) + 1) PERSISTED;
SELECT ClassCode, DurationDays FROM dbo.Classes;
-- SQL-K01 71 · REACT-K02 106 · GIT-K01 33 (sau khi đã dời hạn ở Bài 8)
GO
CREATE UNIQUE INDEX UX_Classes_Room_Start ON dbo.Classes (Room, StartDate) WHERE Room IS NOT NULL;
GO
INSERT INTO dbo.Classes (ClassCode, CourseId, StartDate, EndDate, Room)
VALUES ('T-DUP', 2, '2026-10-05', '2026-10-30', N'P301');           -- Msg 2601: trùng (P301, 2026-10-05)
GO
INSERT INTO dbo.Classes (ClassCode, CourseId, StartDate, EndDate) VALUES
 ('T-N1', 2, '2026-11-02', '2026-11-30'),
 ('T-N2', 3, '2026-11-02', '2026-11-30');                           -- thành công: Room NULL không bị ràng buộc
DELETE FROM dbo.Classes WHERE ClassCode IN ('T-N1', 'T-N2');         -- dọn dòng thử
GO

-- Bài 11 (nâng cao).
CREATE SEQUENCE dbo.seq_ClassNo AS int START WITH 4 INCREMENT BY 1;
GO
DECLARE @no int = NEXT VALUE FOR dbo.seq_ClassNo;
INSERT INTO dbo.Classes (ClassCode, CourseId, StartDate, EndDate)
VALUES (CONCAT('DM-2026-', FORMAT(@no, '000')), 2, '2026-11-02', '2027-01-11');
SELECT ClassCode, DurationDays FROM dbo.Classes WHERE ClassCode LIKE 'DM-%';   -- DM-2026-004 · 71
-- Khác nhau: (1) SEQUENCE là đối tượng độc lập cấp CSDL, dùng chung cho nhiều bảng/lệnh; IDENTITY gắn với một cột.
--            (2) SEQUENCE lấy giá trị trước khi chèn (NEXT VALUE FOR), có CYCLE/CACHE/MAXVALUE và có thể chèn
--                giá trị tường minh không cần IDENTITY_INSERT; cả hai đều có thể để lại "lỗ" khi ROLLBACK.
GO

/* =====================================================================
   BÀI TẬP VỀ NHÀ LAB 2B
   ===================================================================== */
-- BT1.
CREATE TABLE dbo.Rooms (
    RoomCode      nvarchar(30) CONSTRAINT PK_Rooms PRIMARY KEY,
    Capacity      int NOT NULL CONSTRAINT CK_Rooms_Capacity CHECK (Capacity BETWEEN 5 AND 100),
    HasProjector  bit NOT NULL CONSTRAINT DF_Rooms_Projector DEFAULT 1
);
INSERT INTO dbo.Rooms (RoomCode, Capacity) VALUES (N'P301', 30), (N'P302', 35);
ALTER TABLE dbo.Classes
    ADD CONSTRAINT FK_Classes_Rooms FOREIGN KEY (Room) REFERENCES dbo.Rooms(RoomCode);
-- Phải có dữ liệu phòng trước: SQL Server kiểm tra các dòng đang có khi tạo FK, nếu Classes đã chứa 'P301'
-- mà Rooms chưa có thì ALTER báo Msg 547. Room = NULL hợp lệ: FK chỉ kiểm tra giá trị khác NULL (lớp chưa xếp phòng).
GO

-- BT2.
CREATE TABLE dbo.ClassesArchive (
    ClassId int NOT NULL, ClassCode varchar(20) NOT NULL, CourseId int NOT NULL,
    StartDate date NOT NULL, EndDate date NOT NULL, MaxStudents int NOT NULL,
    Room nvarchar(30) NULL, Status varchar(20) NOT NULL,
    ArchivedAt datetime2(0) NOT NULL CONSTRAINT DF_ClassesArchive_At DEFAULT SYSDATETIME()
);
GO
-- Dữ liệu thử: lớp đã kết thúc, đã Closed
INSERT INTO dbo.Classes (ClassCode, CourseId, StartDate, EndDate, Status)
VALUES ('OLD-01', 8, '2026-01-05', '2026-02-05', 'Closed');
DELETE FROM dbo.Classes
OUTPUT deleted.ClassId, deleted.ClassCode, deleted.CourseId, deleted.StartDate, deleted.EndDate,
       deleted.MaxStudents, deleted.Room, deleted.Status
INTO dbo.ClassesArchive (ClassId, ClassCode, CourseId, StartDate, EndDate, MaxStudents, Room, Status)
WHERE Status = 'Closed' AND EndDate < CAST(SYSDATETIME() AS date);
SELECT ClassCode, ArchivedAt FROM dbo.ClassesArchive;               -- OLD-01
-- Lưu ý: OUTPUT … INTO không dùng được khi bảng đích có khóa ngoại/trigger; ClassesArchive không có nên hợp lệ.
-- Bảng nguồn có cột tính toán DurationDays nên phải liệt kê cột rõ ràng (không dùng SELECT * hoặc deleted.*).
GO

-- BT3. (chạy từng phép thử trong giao tác riêng, ROLLBACK ngay sau đó)
BEGIN TRANSACTION;
    SELECT IDENT_CURRENT('dbo.Attendance') AS Ident_Before;          -- 8
    DELETE FROM dbo.Attendance;
    SELECT IDENT_CURRENT('dbo.Attendance') AS Ident_AfterDelete;     -- vẫn 8 (DELETE không đặt lại IDENTITY)
ROLLBACK;
BEGIN TRANSACTION;
    TRUNCATE TABLE dbo.Attendance;
    SELECT IDENT_CURRENT('dbo.Attendance') AS Ident_AfterTruncate;   -- về 1 (đặt lại hạt giống)
    SELECT COUNT(*) AS Rows_AfterTruncate FROM dbo.Attendance;       -- 0
ROLLBACK;                                                           -- TRUNCATE vẫn ROLLBACK được trong giao tác
SELECT COUNT(*) AS Rows_Restored FROM dbo.Attendance;                -- 8
-- Bảng tóm tắt: DELETE – ghi log từng dòng, có WHERE, kích hoạt trigger, không reset IDENTITY, cần quyền DELETE;
--               TRUNCATE – ghi log theo trang, không WHERE, reset IDENTITY, cần quyền ALTER, bị chặn nếu bảng
--               được tham chiếu bởi FK (Attendance là bảng con nên được phép; Classes/ClassStudents thì không);
--               DROP – xóa cả cấu trúc, cần quyền ALTER trên schema, bị chặn nếu còn FK tham chiếu.
GO

-- BT4. Gợi ý khung đáp án (không có mã)
-- ERD: Classes 1–n ClassStudents n–1 Students; Classes 1–n ClassSessions (SessionId PK, ClassId FK, SessionNo,
--      SessionDate, Room, Topic; UNIQUE(ClassId, SessionNo)); Attendance(SessionId, StudentId) với
--      PK/UNIQUE (SessionId, StudentId), FK → ClassSessions và FK tổng hợp → ClassStudents (ClassId cần có
--      trong Attendance hoặc kiểm tra bằng trigger).
-- Phương án tốt hơn: Attendance tham chiếu SessionId – ngày/phòng/nội dung nằm đúng một nơi (chuẩn hóa), không thể
--      điểm danh vào ngày không có buổi học, đổi lịch chỉ sửa một dòng. Lưu SessionDate rời dễ sai lệch và lặp dữ liệu.
