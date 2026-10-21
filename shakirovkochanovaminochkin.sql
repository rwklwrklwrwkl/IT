USE master;
GO

IF DB_ID(N'shakirovminochkinkochanova') IS NOT NULL
BEGIN
    ALTER DATABASE shakirovminochkinkochanova SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE shakirovminochkinkochanova;
END
GO

CREATE DATABASE shakirovminochkinkochanova;
GO

USE shakirovminochkinkochanova;
GO

CREATE TABLE [groups] (
    group_id       INT IDENTITY(1,1) PRIMARY KEY,
    group_name     NVARCHAR(20)  NOT NULL UNIQUE,
    specialty      NVARCHAR(100) NOT NULL,
    admission_year INT           NOT NULL
);

CREATE TABLE students (
    student_id  INT IDENTITY(1,1) PRIMARY KEY,
    last_name   NVARCHAR(50) NOT NULL,
    first_name  NVARCHAR(50) NOT NULL,
    middle_name NVARCHAR(50) NULL,
    birth_date  DATE         NOT NULL,
    group_id    INT          NOT NULL REFERENCES [groups](group_id)
);

CREATE TABLE teachers (
    teacher_id INT IDENTITY(1,1) PRIMARY KEY,
    last_name  NVARCHAR(50)  NOT NULL,
    first_name NVARCHAR(50)  NOT NULL,
    department NVARCHAR(100) NOT NULL
);

CREATE TABLE disciplines (
    discipline_id   INT IDENTITY(1,1) PRIMARY KEY,
    discipline_name NVARCHAR(100) NOT NULL,
    hours           INT           NOT NULL
);

CREATE TABLE lessons (
    lesson_id     INT IDENTITY(1,1) PRIMARY KEY,
    lesson_date   DATE         NOT NULL,
    group_id      INT          NOT NULL REFERENCES [groups](group_id),
    discipline_id INT          NOT NULL REFERENCES disciplines(discipline_id),
    teacher_id    INT          NOT NULL REFERENCES teachers(teacher_id),
    lesson_type   NVARCHAR(30) NOT NULL
);
GO

INSERT INTO [groups] (group_name, specialty, admission_year) VALUES
    (N'П-21',    N'Программирование',                          2021),
    (N'ИС-22',   N'Информационные системы и программирование', 2022),
    (N'ЭК-21',   N'Экономика',                                 2021),
    (N'П-23',    N'Программирование',                          2023),
    (N'ТЕСТ-01', N'Тестовая специальность',                    2026);

INSERT INTO students (last_name, first_name, middle_name, birth_date, group_id) VALUES
    (N'Иванов',   N'Иван',    N'Иванович',  '2007-03-15', 1),
    (N'Петров',   N'Алексей', N'Сергеевич', '2007-07-21', 1),
    (N'Сидорова', N'Анна',    N'Игоревна',  '2006-11-02', 2),
    (N'Кузнецов', N'Максим',  N'Олегович',  '2007-01-18', 2),
    (N'Смирнова', N'Елена',   N'Андреевна', '2006-05-10', 3);

INSERT INTO teachers (last_name, first_name, department) VALUES
    (N'Волков',  N'Александр', N'Информационные технологии'),
    (N'Орлова',  N'Мария',     N'Общеобразовательные дисциплины'),
    (N'Фёдоров', N'Дмитрий',   N'Программирование');

INSERT INTO disciplines (discipline_name, hours) VALUES
    (N'Основы проектирования баз данных', 72),
    (N'Информационные технологии',        48),
    (N'Программирование',                 144);

INSERT INTO lessons (lesson_date, group_id, discipline_id, teacher_id, lesson_type) VALUES
    ('2026-09-01', 2, 1, 1, N'Практика'),
    ('2026-09-02', 1, 1, 1, N'Лекция'),
    ('2026-09-03', 1, 3, 3, N'Практика'),
    ('2026-09-04', 2, 2, 2, N'Лекция'),
    ('2026-09-05', 3, 2, 2, N'Практика');
GO

SELECT
    s.student_id,
    s.last_name + N' ' + s.first_name + N' ' + COALESCE(s.middle_name, N'') AS ФИО,
    g.group_name AS группа,
    g.specialty AS специальность
FROM students s
JOIN [groups] g ON s.group_id = g.group_id
ORDER BY g.group_name, s.last_name;

SELECT
    g.group_name AS группа,
    COUNT(s.student_id) AS количество_студентов
FROM [groups] g
LEFT JOIN students s ON g.group_id = s.group_id
GROUP BY g.group_id, g.group_name
ORDER BY количество_студентов DESC;

SELECT
    l.lesson_date AS дата,
    g.group_name AS группа,
    d.discipline_name AS дисциплина,
    t.last_name + N' ' + t.first_name AS преподаватель,
    l.lesson_type AS вид_занятия
FROM lessons l
JOIN [groups] g ON l.group_id = g.group_id
JOIN disciplines d ON l.discipline_id = d.discipline_id
JOIN teachers t ON l.teacher_id = t.teacher_id
ORDER BY l.lesson_date, g.group_name;

SELECT
    t.last_name + N' ' + t.first_name AS преподаватель,
    t.department AS кафедра,
    COUNT(l.lesson_id) AS количество_занятий
FROM teachers t
LEFT JOIN lessons l ON t.teacher_id = l.teacher_id
GROUP BY t.teacher_id, t.last_name, t.first_name, t.department
ORDER BY количество_занятий DESC;

SELECT
    last_name + N' ' + first_name AS ФИО,
    birth_date AS дата_рождения
FROM students
WHERE birth_date > '2007-01-01'
ORDER BY birth_date;

SELECT
    discipline_name AS дисциплина,
    hours AS часы
FROM disciplines
WHERE hours > 72
ORDER BY hours DESC;

SELECT
    g.group_name AS группа,
    COUNT(s.student_id) AS студентов
FROM [groups] g
JOIN students s ON g.group_id = s.group_id
GROUP BY g.group_id, g.group_name
HAVING COUNT(s.student_id) > 1
ORDER BY студентов DESC;

SELECT
    CAST(AVG(занятий * 1.0) AS DECIMAL(4,2)) AS среднее_количество_занятий
FROM (
    SELECT
        teacher_id,
        COUNT(lesson_id) AS занятий
    FROM lessons
    GROUP BY teacher_id
) AS subquery;

SELECT DISTINCT
    specialty AS специальность
FROM [groups]
ORDER BY specialty;

SELECT
    last_name + N' ' + first_name AS ФИО,
    (SELECT group_name FROM [groups] WHERE group_id = s.group_id) AS группа
FROM students s
ORDER BY last_name;
GO

BEGIN TRY
    SET IDENTITY_INSERT [groups] ON;
    INSERT INTO [groups] (group_id, group_name, specialty, admission_year)
    VALUES (1, N'Новая группа', N'Тест', 2026);
    SET IDENTITY_INSERT [groups] OFF;
END TRY
BEGIN CATCH
    SET IDENTITY_INSERT [groups] OFF;
    PRINT N'Ошибка ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)) + N': ' + ERROR_MESSAGE();
END CATCH
GO

BEGIN TRY
    INSERT INTO students (first_name, birth_date, group_id)
    VALUES (N'Иван', '2007-01-01', 1);
END TRY
BEGIN CATCH
    PRINT N'Ошибка ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)) + N': ' + ERROR_MESSAGE();
END CATCH
GO

ALTER TABLE students ALTER COLUMN middle_name NVARCHAR(100) NULL;
GO

BEGIN TRY
    INSERT INTO [groups] (group_name, specialty, admission_year)
    VALUES (N'П-21', N'Другая специальность', 2026);
END TRY
BEGIN CATCH
    PRINT N'Ошибка ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)) + N': ' + ERROR_MESSAGE();
END CATCH
GO

EXEC sp_rename N'teachers.department', N'kafedra', N'COLUMN';
GO
EXEC sp_rename N'teachers.kafedra', N'department', N'COLUMN';
GO

ALTER TABLE teachers ADD temp_column NVARCHAR(50) NULL;
GO
ALTER TABLE teachers DROP COLUMN temp_column;
GO

ALTER TABLE [groups] ADD CONSTRAINT chk_admission_year
CHECK (admission_year BETWEEN 2000 AND 2100);
GO

BEGIN TRANSACTION;
UPDATE students SET group_id = 2 WHERE student_id = 1;
UPDATE [groups] SET group_name = N'П-21 (обновлена)' WHERE group_id = 1;
COMMIT TRANSACTION;

SELECT * FROM students WHERE student_id = 1;
GO

BEGIN TRANSACTION;
DELETE FROM students;
SELECT COUNT(*) AS внутри_транзакции FROM students;
ROLLBACK TRANSACTION;
SELECT COUNT(*) AS после_отката FROM students;
GO

BEGIN TRANSACTION;

INSERT INTO [groups] (group_name, specialty, admission_year)
VALUES (N'ВРЕМ-01', N'Временная', 2026);

SAVE TRANSACTION sp1;

INSERT INTO [groups] (group_name, specialty, admission_year)
VALUES (N'ВРЕМ-02', N'Временная', 2026);

ROLLBACK TRANSACTION sp1;

COMMIT TRANSACTION;

SELECT * FROM [groups] WHERE group_name LIKE N'ВРЕМ%';
GO

CREATE VIEW v_students_with_groups AS
SELECT
    s.student_id,
    s.last_name + N' ' + s.first_name AS full_name,
    s.birth_date,
    g.group_name,
    g.specialty
FROM students s
JOIN [groups] g ON s.group_id = g.group_id;
GO

SELECT * FROM v_students_with_groups WHERE group_name = N'П-21';
GO

DROP VIEW v_students_with_groups;
GO

CREATE INDEX idx_students_last_name ON students(last_name);
CREATE INDEX idx_lessons_date ON lessons(lesson_date);
GO

SET STATISTICS IO ON;
SELECT * FROM students WHERE last_name = N'Иванов';
SET STATISTICS IO OFF;
GO

DROP INDEX idx_students_last_name ON students;
GO

CREATE TABLE grades (
    grade_id      INT IDENTITY(1,1) PRIMARY KEY,
    student_id    INT  NOT NULL,
    discipline_id INT  NOT NULL,
    grade         INT  NOT NULL CHECK (grade BETWEEN 2 AND 5),
    grade_date    DATE NOT NULL,

    CONSTRAINT fk_grades_students
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_grades_disciplines
        FOREIGN KEY (discipline_id)
        REFERENCES disciplines(discipline_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

INSERT INTO grades (student_id, discipline_id, grade, grade_date) VALUES
    (1, 1, 5, '2026-09-15'),
    (1, 3, 4, '2026-09-16'),
    (2, 1, 3, '2026-09-15'),
    (2, 3, 5, '2026-09-16'),
    (3, 1, 4, '2026-09-17'),
    (3, 2, 5, '2026-09-18'),
    (4, 2, 4, '2026-09-18'),
    (4, 1, 3, '2026-09-19'),
    (5, 2, 5, '2026-09-20'),
    (5, 1, 4, '2026-09-21');
GO

SELECT
    s.last_name + N' ' + s.first_name AS студент,
    CAST(AVG(g.grade * 1.0) AS DECIMAL(4,2)) AS средний_балл
FROM grades g
JOIN students s ON g.student_id = s.student_id
GROUP BY s.student_id, s.last_name, s.first_name
ORDER BY средний_балл DESC;

SELECT
    d.discipline_name AS дисциплина,
    CAST(AVG(g.grade * 1.0) AS DECIMAL(4,2)) AS средний_балл,
    COUNT(g.grade_id) AS количество_оценок
FROM grades g
JOIN disciplines d ON g.discipline_id = d.discipline_id
GROUP BY d.discipline_id, d.discipline_name
ORDER BY средний_балл DESC;

SELECT
    s.last_name + N' ' + s.first_name AS студент,
    d.discipline_name AS дисциплина,
    g.grade AS оценка,
    g.grade_date AS дата
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN disciplines d ON g.discipline_id = d.discipline_id
WHERE g.grade < 4
ORDER BY g.grade, s.last_name;

SELECT
    s.last_name + N' ' + s.first_name AS студент,
    CAST(AVG(g.grade * 1.0) AS DECIMAL(4,2)) AS средний_балл
FROM grades g
JOIN students s ON g.student_id = s.student_id
GROUP BY s.student_id, s.last_name, s.first_name
HAVING AVG(g.grade * 1.0) > 4.5
ORDER BY средний_балл DESC;
GO

CREATE TABLE audit_log (
    log_id     INT IDENTITY(1,1) PRIMARY KEY,
    table_name NVARCHAR(50),
    operation  NVARCHAR(10),
    record_id  INT,
    old_data   NVARCHAR(MAX),
    new_data   NVARCHAR(MAX),
    changed_at DATETIME2 DEFAULT SYSDATETIME(),
    changed_by NVARCHAR(128) DEFAULT SUSER_SNAME()
);
GO

CREATE TRIGGER trg_students_audit ON students
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit_log (table_name, operation, record_id, new_data)
    SELECT N'students', N'INSERT', i.student_id,
        (SELECT i.student_id AS student_id, i.last_name AS last_name, i.first_name AS first_name,
                i.middle_name AS middle_name, i.birth_date AS birth_date, i.group_id AS group_id
         FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM deleted d WHERE d.student_id = i.student_id);

    INSERT INTO audit_log (table_name, operation, record_id, old_data, new_data)
    SELECT N'students', N'UPDATE', i.student_id,
        (SELECT d.student_id AS student_id, d.last_name AS last_name, d.first_name AS first_name,
                d.middle_name AS middle_name, d.birth_date AS birth_date, d.group_id AS group_id
         FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        (SELECT i.student_id AS student_id, i.last_name AS last_name, i.first_name AS first_name,
                i.middle_name AS middle_name, i.birth_date AS birth_date, i.group_id AS group_id
         FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i
    JOIN deleted d ON d.student_id = i.student_id;

    INSERT INTO audit_log (table_name, operation, record_id, old_data)
    SELECT N'students', N'DELETE', d.student_id,
        (SELECT d.student_id AS student_id, d.last_name AS last_name, d.first_name AS first_name,
                d.middle_name AS middle_name, d.birth_date AS birth_date, d.group_id AS group_id
         FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM deleted d
    WHERE NOT EXISTS (SELECT 1 FROM inserted i WHERE i.student_id = d.student_id);
END
GO

INSERT INTO students (last_name, first_name, birth_date, group_id)
VALUES (N'Новиков', N'Пётр', '2007-05-05', 1);

UPDATE students SET first_name = N'Петр' WHERE last_name = N'Новиков';

DELETE FROM students WHERE last_name = N'Новиков';

SELECT * FROM audit_log ORDER BY log_id;
GO

CREATE TRIGGER trg_check_grade ON grades
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE grade < 2 OR grade > 5)
    BEGIN
        RAISERROR(N'Оценка должна быть от 2 до 5', 16, 1);
        ROLLBACK TRANSACTION;
    END
END
GO

USE master;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'teacher_ivanov')
    CREATE LOGIN teacher_ivanov WITH PASSWORD = N'secure_password_1', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'student_petrov')
    CREATE LOGIN student_petrov WITH PASSWORD = N'secure_password_2', CHECK_POLICY = OFF;
GO

USE shakirovminochkinkochanova;
GO

CREATE ROLE teacher_role;
CREATE ROLE student_role;

CREATE USER teacher_ivanov FOR LOGIN teacher_ivanov;
CREATE USER student_petrov FOR LOGIN student_petrov;

ALTER ROLE teacher_role ADD MEMBER teacher_ivanov;
ALTER ROLE student_role ADD MEMBER student_petrov;

GRANT SELECT ON students    TO teacher_role;
GRANT SELECT ON lessons     TO teacher_role;
GRANT SELECT ON [groups]    TO teacher_role;
GRANT SELECT ON disciplines TO teacher_role;
GO

CREATE VIEW v_my_grades AS
SELECT
    gr.grade_id,
    s.student_id,
    d.discipline_name,
    gr.grade,
    gr.grade_date
FROM grades gr
JOIN students s ON gr.student_id = s.student_id
JOIN disciplines d ON gr.discipline_id = d.discipline_id;
GO

GRANT SELECT ON v_my_grades TO student_role;
GO
