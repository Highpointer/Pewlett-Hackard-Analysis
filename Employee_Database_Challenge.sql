-- To grade this assignment, go to section Module 7 Challenge --

-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
     dept_no VARCHAR(4) NOT NULL,
     dept_name VARCHAR(40) NOT NULL,
     PRIMARY KEY (dept_no),
     UNIQUE (dept_name)
);

CREATE TABLE dept_emp (
     emp_no INT NOT NULL,
     dept_no VARCHAR(4) NOT NULL,
	 from_date DATE NOT NULL,
     to_date DATE NOT NULL
);

CREATE TABLE employees (    
	 emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
dept_no VARCHAR(4) NOT NULL,
    emp_no INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
  emp_no INT NOT NULL,
  title VARCHAR NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL
);

CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);

SELECT first_name, last_name FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31'

-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Save the data into a table, Module 7.3.1
SELECT first_name, last_name
INTO retirement_info FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT emp_no, first_name, last_name
INTO retirement_info FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info as r;

-- Joining departments and dept_manager tables. 7.3.3 Use Inner Join for Departments and dept-manager Tables
SELECT d.dept_name, dm.emp_no, dm.from_date, dm.to_date
FROM departments as d INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables. 7.3.3 Use Left Join to Capture retirement-info Table
SELECT r.emp_no, r.first_name, r.last_name, de.to_date
FROM retirement_info as r LEFT JOIN dept_emp as de
ON r.emp_no = de.emp_no;
--The "Data Output" tab contains each of the four columns specified earlier: emp_no (employee number), first_name, last_name, and the to_date

SELECT r.emp_no, r.first_name, r.last_name, de.to_date
INTO current_emp
FROM retirement_info as r LEFT JOIN dept_emp as de
ON r.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01')

-- 7.3.4 Use Count, Group By, and Order By
-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no FROM current_emp as ce
LEFT JOIN dept_emp as de ON ce.emp_no = de.emp_no
GROUP BY de.dept_no ORDER BY COUNT(ce.emp_no) DESC;

-- 7.3.5
SELECT emp_no, first_name, last_name, gender
INTO emp_info FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT e.emp_no, e.first_name, e.last_name, e.gender, s.salary, de.to_date
INTO emp_info FROM employees as e
INNER JOIN salaries as s ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31') 
AND (de.to_date = '9999-01-01');

-- List of managers per department
SELECT dm.dept_no, d.dept_name, dm.emp_no, ce.last_name, ce.first_name, dm.from_date, dm.to_date
-- INTO manager_info 
FROM dept_manager AS dm
INNER JOIN departments AS d ON (dm.dept_no = d.dept_no)
INNER JOIN current_emp AS ce ON (dm.emp_no = ce.emp_no);

SELECT ce.emp_no, ce.first_name, ce.last_name, d.dept_name
-- INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales', 'Development');

-- 7.3.6 Create a Tailored List
-- Using the ERD you created in this module as a reference and your knowledge of SQL queries, create a 
-- Retirement Titles table that holds all the titles of employees who were born between January 1, 1952
-- and December 31, 1955. Because some employees may have multiple titles in the database — for example,
-- due to promotions—you’ll need to use the DISTINCT ON statement to create a table that contains the most 
-- recent title of each employee. Then, use the COUNT() function to create a table that has the number of
-- retirement-age employees by most recent job title. Finally, because we want to include only current
-- employees in our analysis, be sure to exclude those employees who have already left the company.

-- Module 7 Challenge --
-- Deliverable 1: The Number of Retiring Employees by Title (50 points) --

-- This query is written and executed to create a Retirement Titles table for
-- employees who are born between January 1, 1952 and December 31, 1955. (10 pt/10 pt overall)
SELECT e.emp_no, e.first_name, e.last_name, t.title, t.from_date, t.to_date
INTO retirement_titles FROM employees as e
INNER JOIN titles AS t ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31') 
ORDER BY e.emp_no
-- The Retirement Titles table is exported as retirement_titles.csv (5 pt/15 pt overall)

-- This query is written and executed to create a Unique Titles table that contains the
-- employee number, first and last name, and most recent title. (15 pt/30 pt overall)
SELECT DISTINCT ON (r.emp_no) r.emp_no, r.first_name, r.last_name, r.title
INTO unique_titles FROM retirement_titles as r
WHERE (r.to_date = '9999-01-01')
ORDER BY r.emp_no, r.to_date DESC;
-- The Unique Titles table is exported as unique_titles.csv (5 pt/35 pt overall)

-- This query is written and executed to create a Retiring Titles table that contains
-- the number of titles filled by employees who are retiring. (10 pt/45 pt overall)
SELECT COUNT(u.emp_no), u.title 
INTO retiring_titles FROM unique_titles as u
GROUP BY u.title ORDER BY COUNT(u.emp_no) DESC;
-- The Retiring Titles table is exported as retiring_titles.csv (5 pt/50 pt overall)

-- Deliverable 2: The Employees Eligible for the Mentorship Program (30 points) --
-- Using the ERD you created in this module as a reference and your knowledge of
-- SQL queries, create a mentorship-eligibility table that holds the current
-- employees who were born between January 1, 1965 and December 31, 1965.

-- This query is written and executed to create a Mentorship Eligibility table for current
-- employees who were born between January 1, 1965 and December 31, 1965. (25 pt/75 pt overall)
SELECT DISTINCT ON (e.emp_no) e.emp_no, e.first_name, e.last_name, e.birth_date, de.from_date, de.to_date, t.title
INTO mentorship_eligibility
FROM employees as e
INNER JOIN dept_emp AS de ON (e.emp_no = de.emp_no)
INNER JOIN titles AS t ON (e.emp_no = t.emp_no)
WHERE (de.to_date = '9999-01-01') AND (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
ORDER BY e.emp_no;
-- The Mentorship Eligibility table is exported and saved as mentorship_eligibilty.csv (5 pt/80 pt overall)