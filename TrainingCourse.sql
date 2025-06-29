create database TrainingCourse 

use TrainingCourse 

CREATE TABLE Trainee_ ( 
    Trainee_id INT PRIMARY KEY, 
    Trainee_name VARCHAR(50) NOT NULL,
    gender BIT DEFAULT 0,
    Trainee_email VARCHAR(50) NOT NULL, 
    Background VARCHAR(100) NOT NULL
);

-- Insert Trainee data
	INSERT INTO Trainee_ (trainee_id, Trainee_name, gender, Trainee_email, background) VALUES
	(1, 'Aisha Al-Harthy', '1', 'aisha@example.com', 'Engineering'),
	(2, 'Sultan Al-Farsi', '0', 'sultan@example.com', 'Business'),
	(3, 'Mariam Al-Saadi', '1', 'mariam@example.com', 'Marketing'),
	(4, 'Omar Al-Balushi', '0', 'omar@example.com', 'Computer Science'),
	(5, 'Fatma Al-Hinai', '1', 'fatma@example.com', 'Data Science');
	select * from Trainee_

create table Trainer ( 
		Trainer_id INT PRIMARY KEY, 
		Trainer_name VARCHAR(50) not null,
		Trainer_email  VARCHAR(50) not null, 
		Phone INT,
		Specialty VARCHAR(100) not null, 
);
alter table Trainer
alter column Phone VARCHAR(20)

-- Insert Trainer data
	INSERT INTO Trainer (Trainer_id, Trainer_name, Specialty, Phone, Trainer_email) VALUES
	(1, 'Khalid Al-Maawali', 'Databases', '96891234567', 'khalid@example.com'),
	(2, 'Noura Al-Kindi', 'Web Development', '96892345678', 'noura@example.com'),
	(3, 'Salim Al-Harthy', 'Data Science', '96893456789', 'salim@example.com');
	select * from Trainer


create table Course ( 
		Course_id INT PRIMARY KEY, 
		Title VARCHAR(100) not null,
		Working_Hours DECIMAL(5,2),
		Category VARCHAR(100) not null, 
		levels VARCHAR(100),
);
alter table Course
alter column Working_Hours INT

-- Insert Course data
	INSERT INTO Course (Course_id, Title, Category, Working_Hours, levels) VALUES
	(1, 'Database Fundamentals', 'Databases', 20, 'Beginner'),
	(2, 'Web Development Basics', 'Web', 30, 'Beginner'),
	(3, 'Data Science Introduction', 'Data Science', 25, 'Intermediate'),
	(4, 'Advanced SQL Queries', 'Databases', 15, 'Advanced');
	select * from Course

create table Schedule  ( 
		Schedule_id INT PRIMARY KEY, 
		Course_id INT not null,
		trainer_id INT not null,
		start_date DATE not null,
		end_date DATE NOT NULL,
		time_slot VARCHAR(50),
		
		FOREIGN KEY (Course_id) REFERENCES Course(Course_id),
		FOREIGN KEY (trainer_id) REFERENCES Trainer(trainer_id)
);

-- Insert Schedule data
	INSERT INTO Schedule (Schedule_id, Course_id, trainer_id, start_date, end_date, time_slot) VALUES
	(1, 1, 1, '2025-07-01', '2025-07-10', 'Morning'),
	(2, 2, 2, '2025-07-05', '2025-07-20', 'Evening'),
	(3, 3, 3, '2025-07-10', '2025-07-25', 'Weekend'),
	(4, 4, 1, '2025-07-15', '2025-07-22', 'Morning');
	select * from Schedule

create table Enrollment_  ( 
		enrollment_id INT PRIMARY KEY, 
		trainee_id INT not null,
		Course_id INT not null,
		enrollment_date DATE NOT NULL,
		
		FOREIGN KEY (trainee_id) REFERENCES Trainee_(trainee_id),
		FOREIGN KEY (Course_id) REFERENCES Course(Course_id)
);

INSERT INTO Enrollment_ (enrollment_id, trainee_id, Course_id, enrollment_date) VALUES
	(1, 1, 1, '2025-06-01'),
	(2, 2, 1, '2025-06-02'),
	(3, 3, 2, '2025-06-03'),
	(4, 4, 3, '2025-06-04'),
	(5, 5, 3, '2025-06-05'),
	(6, 1, 4, '2025-06-06');
	select * from Enrollment_

--SQL Query Instructions 
--1 Show all available courses (title, level, category)
SELECT Title, levels, Category
FROM Course 

--2 View beginner-level Data Science courses
SELECT Title, levels, Category, Working_Hours
FROM Course 
WHERE levels = 'Beginner' Or Category = 'Data Science';

--3 Show courses this trainee is enrolled in (assuming trainee_id = 1)
SELECT Course_id, Title, Category, levels
FROM Course 
WHERE Course_id IN (
    SELECT Course_id
    FROM Enrollment_
    WHERE trainee_id = 1
);

--4 View the schedule for the trainee's enrolled courses
SELECT C.Title, S.start_date, S.end_date, S.time_slot
FROM Course C
JOIN Enrollment_ E ON C.Course_id = E.Course_id
JOIN Schedule S ON C.Course_id = S.Course_id
WHERE E.trainee_id = 1
ORDER BY S.start_date;

--5 Count how many courses the trainee is enrolled in
SELECT COUNT(*) AS Enrolled_Courses
FROM Enrollment_
WHERE trainee_id = 1;

--6 Show course titles, trainer names, and time slots the trainee is attending
SELECT 
	C.Title AS Course_Title,
    T.Trainer_name AS Trainer_Name,
    S.time_slot AS Time_Slot
FROM Enrollment_ E
JOIN Schedule S ON E.Course_id = S.Course_id
JOIN Course C ON E.Course_id = C.Course_id
JOIN Trainer T ON S.Trainer_id = T.Trainer_id
WHERE E.trainee_id = 1;

-- Trainer Perspective Queries

--1 List all courses the trainer is assigned to (assuming trainer_id = 1)
SELECT C.Course_id, C.Title, C.Category, C.levels, S.time_slot, S.start_date, S.end_date
FROM Schedule S
JOIN Course C ON S.Course_id = C.Course_id
WHERE S.Trainer_id = 1;

-- 2 Show upcoming sessions (with dates and time slots)
SELECT C.Title, S.start_date, S.end_date, S.time_slot
FROM Course C
JOIN Schedule S ON C.course_id = S.course_id
WHERE S.start_date > GETDATE(); 

--3 See how many trainees are enrolled in each of your courses
SELECT C.Course_id, C.Title, COUNT(E.trainee_id) AS NumberOfTrainees
FROM Course C
LEFT JOIN Enrollment_ E ON C.Course_id = E.Course_id
GROUP BY C.Course_id, C.Title
ORDER BY C.Course_id;

--4 List names and emails of trainees in each of your courses
SELECT T.Trainee_name, T.Trainee_email,
	C.Title AS Course_Title
FROM Enrollment_ E
JOIN Trainee_ T ON E.trainee_id = T.Trainee_id
JOIN Course C ON E.Course_id = C.Course_id
ORDER BY C.Title, T.Trainee_name;

--5 Show the trainer's contact info and assigned courses
SELECT TR.Trainer_name, TR.Trainer_email, TR.Phone,
       C.Title AS Course_Title
FROM Trainer TR
JOIN Schedule S ON TR.Trainer_id = S.trainer_id
JOIN Course C ON S.Course_id = C.Course_id
ORDER BY TR.Trainer_name, C.Title;

--6 Count the number of courses the trainer teaches
SELECT Trainer_name, COUNT(*) AS Number_of_Courses
FROM Trainer tr
JOIN Schedule S ON TR.Trainer_id = S.trainer_id
GROUP BY Trainer_name;


--Admin Perspective Queries
--1. Add a new course (INSERT statement)

INSERT INTO Course (Course_id, Title, Category, Working_Hours, levels) 
VALUES (5, 'Machine Learning Basics', 'Data Science', 40, 'Beginner');
	  select * from Course

--2 Create a new schedule for a trainer
INSERT INTO Schedule (Schedule_id, Course_id, trainer_id, start_date, end_date, time_slot)
VALUES (5, 5, 3, '2025-08-01', '2025-08-20', 'Evening');
	select * from Schedule

--3 View all trainee enrollments with course title and schedule info
SELECT TR.Trainee_name, TR.Trainee_email,
    C.Title AS Course_Title,
    S.start_date, S.end_date, S.time_slot

FROM Enrollment_ E
JOIN Trainee_ TR ON E.trainee_id = TR.Trainee_id
JOIN Course C ON E.Course_id = C.Course_id
JOIN Schedule S ON C.Course_id = S.Course_id
ORDER BY TR.Trainee_name, C.Title;

--4 Show how many courses each trainer is assigned to
SELECT TR.Trainer_name,
    COUNT(S.Course_id) AS Number_of_Courses
FROM Trainer TR
LEFT JOIN Schedule S ON TR.Trainer_id = S.trainer_id
GROUP BY TR.Trainer_name
ORDER BY Number_of_Courses DESC;

--5 List all trainees enrolled in "Database Fundamentals"
SELECT T.Trainee_name, T.Trainee_email
FROM Enrollment_ E
JOIN Trainee_ T ON E.trainee_id = T.Trainee_id
JOIN Course C ON E.Course_id = C.Course_id
WHERE c.Title = 'Database Fundamentals';

--6 Identify the course with the highest number of enrollments
SELECT C.Title, COUNT(*) AS Enrollments
FROM Enrollment_ E
JOIN Course C ON E.Course_id = C.Course_id
GROUP BY C.Title
ORDER BY Enrollments DESC;

--7 Display all schedules sorted by start date
SELECT 
    C.Title AS Course_Title,
    T.Trainer_name,
    S.start_date, S.end_date, S.time_slot
FROM Schedule S
JOIN Course C ON S.Course_id = C.Course_id
JOIN Trainer t ON S.trainer_id = T.Trainer_id
ORDER BY s.start_date;

