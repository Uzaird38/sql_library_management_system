---Library Management System

---Creating Branch Table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
branch_id varchar(10) PRIMARY KEY,	
manager_id varchar(10),
branch_address varchar(55),
contact_no varchar(10)
);
---Branch contact number is more than 12 digit
ALTER TABLE branch
ALTER column contact_no TYPE varchar(15)

---Creating Employees Table
CREATE TABLE employees(
emp_id varchar(10) PRIMARY KEY,	
emp_name varchar(20),
position varchar(15),
salary int,
branch_id varchar(10)
);
---Salary is not in INT, Its in FLOAT
ALTER TABLE employees
ALTER column salary TYPE float

---Creating Books Table
CREATE TABLE books(
isbn varchar(20) PRIMARY KEY,	
book_title varchar(25),
category varchar(10),
rental_price float,	
status varchar(10),
author varchar(20),
publisher varchar(30)
);
---Book name conatins more than 40 characters
ALTER TABLE books
ALTER Column book_title TYPE varchar(60)

---Update category lenght 
ALTER TABLE books
ALTER COLUMN category TYPE varchar(20)

----Update author lenght 
ALTER TABLE books
ALTER COLUMN author TYPE varchar(30)

---Creating members Table
CREATE TABLE members(
member_id varchar(15)PRIMARY KEY,
member_name varchar(15),
member_address varchar(25),
reg_date date
);

---Creating issued_status Table
CREATE TABLE issued_status(
issued_id varchar(10) PRIMARY KEY,	
issued_member_id varchar(10),---FK
issued_book_name varchar(25),	
issued_date DATE,
issued_book_isbn varchar(20),---FK
issued_emp_id varchar(20) ---FK
);
---Update lenght for issued_book_name column
ALTER TABLE issued_status
ALTER Column issued_book_name TYPE varchar(60)

---Creating return_status Table
CREATE TABLE return_status(
return_id varchar(10) PRIMARY KEY,
issued_id varchar(10),	
return_book_name varchar(25),	
return_date	DATE,
return_book_isbn varchar(20)
)
--- Deleting two columns because it doesnot have any values.

ALTER TABLE return_status
DROP COLUMN return_book_name,
DROP COLUMN return_book_isbn;

---FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY(issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_book
FOREIGN KEY(issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY(issued_emp_id)
REFERENCES employees(emp_id);



ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY(branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY(issued_id)
REFERENCES issued_status(issued_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_book
FOREIGN KEY(return_book_isbn)
REFERENCES books(isbn);
----View all the table
SELECT * FROM return_status
SELECT * FROM books
SELECT * FROM employees
SELECT * FROM branch
SELECT * FROM members
SELECT * FROM issued_status
--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher) 
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

--Task 2: Update an Existing Member's Address
-- Check Address before 
SELECT member_address
FROM members
WHERE member_id='C101'
--Update the address
UPDATE members
SET member_address='6446 VALKI'
WHERE member_id='C101'
--Check after updation
SELECT member_address
FROM members
WHERE member_id='C101'

--Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
--Check record before deletion
SELECT *
FROM issued_status
WHERE issued_id='IS121'
--Deletion of record
DELETE FROM  issued_status
WHERE issued_id= 'IS121'
--Check After Deletion(Nothing will be dislayed)
SELECT *
FROM issued_status
WHERE issued_id='IS121'

--Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT issued_book_name
FROM issued_status
WHERE issued_emp_id= 'E101'

--Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

     SELECT issued_emp_id, COUNT(issued_emp_id) as cnt
     FROM issued_status
     GROUP BY issued_emp_id
	 HAVING count(issued_emp_id)>1

	

--Task 6: Create Summary Tables:
--Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**
CREATE TABLE book_summary_count AS
   (
   SELECT b.isbn, b.book_title,COUNT(ist.issued_id) as no_issued
   FROM issued_status as ist
   JOIN books as b
   ON ist.issued_book_isbn = b.isbn
   GROUP BY b.isbn, b.book_title
   )
----To view created CTAS
 SELECT * FROM book_summary_count
 
--

--Task 7. Retrieve All Books in a Specific Category:
SELECT *
FROM books
where category='Classic'

--Task 8: Find Total Rental Income by Category:
SELECT b.category,
      SUM( b.rental_price),
	  COUNT(*)
   FROM issued_status as ist
   JOIN books as b
   ON ist.issued_book_isbn = b.isbn
   GROUP BY b.category
---

--Task 9:List Members Who Registered in the Last 180 Days:
SELECT *  from members
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES('C117','Uzair','Main st 1122','2026-10-03'),
      ('C120','Maaz','Highway 23','2026-09-04')
--Now check for the members who registered in last 180 days using CURRENT_DATE function
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'

--Task 10:List Employees with Their Branch Manager's Name and their branch details:
SELECT * FROM branch
--
SELECT e1.*,
       b.manager_id,
       e2.emp_name as manager
from employees as e1
JOIN branch as b
ON e1.branch_id=b.branch_id
JOIN
employees as e2
ON b.manager_id=e2.emp_id

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE books_above_threshold AS
   SELECT book_title,rental_price
    FROM books
    WHERE rental_price>6
--Checkfor the CTAS Table books_above_threshold
SELECT * 
FROM books_above_threshold

--Task 12: Retrieve the List of Books Not Yet Returned
SELECT 
     DISTINCT i.issued_book_name
FROM issued_status as i
LEFT JOIN
return_status as r
ON
i.issued_id=r.issued_id
WHERE r.return_id is NULL
/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
--issued_status==members==books==return_status
--filter books which is return
--overdue >30
SELECT * FROM issued_status

SELECT m.member_id,
       b.book_title,
	   i.issued_date,
	   CURRENT_DATE - i.issued_date as over_due_days
FROM issued_status as i
JOIN
members as m
ON i.issued_member_id=m.member_id
JOIN
books as b
ON b.isbn=i.issued_book_isbn
LEFT JOIN
return_status as r
ON i.issued_id=r.issued_id
WHERE r.return_date is NULL
      AND
      (CURRENT_DATE - i.issued_date) >30
ORDER BY 1

/*
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn,issued_emp_id)
VALUES('IS141','C111','The Kite Runner','2024-9-01','978-0-06-112241-5','E110'),
      ('IS142',	'C103'	,'Dune','2026-9-28'	,'978-0-345-39180-3'	,'E109');

UPDATE issued_status
SET issued_date='2026-9-01'
WHERE issued_id='IS141'
	 
	 SELECT * FROM issued_status


INSERT INTO members(member_id, member_name, member_address,reg_date)
VALUES('C111','Osama','1245 Hnr','2024-05-01')
*/


--Task 14: Update Book Status on Return.
--Write a query to update the status of books in the books table to "Yes" when they are returned 
--(based on entries in the return_status table).
SELECT * FROM issued_status
WHERE issued_book_isbn='978-0-307-58837-1'
--"IS135"	"C107"

SELECT * FROM issued_status
WHERE issued_book_isbn='978-0-375-41398-8'
--"IS134"	"C107"

SELECT * FROM issued_status
WHERE issued_book_isbn='978-0-7432-7357-1'
--"IS136"	"C107"
--Check for the books with status as 'no'

SELECT * FROM books
WHERE status='no'

SELECT * FROM return_status
--Add column in return_status table  'book_condition' set default value as good
ALTER TABLE return_status
ADD COLUMN book_condition varchar(20) DEFAULT 'good';
SELECT * FROM return_status
--'RS106','RS112','RS118'
--Update book_condition status for some book as damaged
UPDATE return_status
SET book_condition ='damaged'
WHERE return_id IN ('RS106','RS112','RS118')

--Insert some record into return_status table 
--Before we start will check for the record in return_status table
SELECT * FROM return_status
SELECT * FROM books
SELECT * FROM issued_status
--Store Procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id varchar(10),p_issued_id varchar(10),p_book_condition varchar(20))
LANGUAGE plpgsql
AS $$

DECLARE
v_isbn varchar(20);
v_book_title varchar(60);
BEGIN
INSERT INTO return_status(return_id,issued_id,return_date,book_condition)
VALUES(p_return_id,p_issued_id,current_date,p_book_condition);

SELECT issued_book_isbn,issued_book_name
INTO v_isbn, v_book_title
FROM issued_status
WHERE issued_id=p_issued_id;

UPDATE books
SET status='yes'
WHERE isbn=v_isbn;
RAISE NOTICE'Thankyou for returning book: %',v_book_title;
END
$$
CALL add_return_records('RS119','IS135','damaged')
/*
--Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch,
showing the number of books issued, 
the number of books returned, 
and the total revenue generated from book rentals.
*/
SELECT * FROM return_status
SELECT * FROM books
SELECT * FROM issued_status
SELECT * FROM branch
SELECT * FROM employees

SELECT e1.emp_id,e2.branch_id
FROM employees as e1
JOIN employees as e2
ON e1.emp_id=e2.emp_id
ORDER BY e2.branch_id
--Branch id with associated employees id
--Branch B001 "E101""E103""E104""E105""E106"
--Branch B002 E102
--Branch B003 E109
--Branch B004 E108
--Branch B005 "E111" "E107" "E110"
--
CREATE TABLE branch_reports
AS
SELECT b.branch_id,b.manager_id,
SUM(bk.rental_price) as total_revenue,
COUNT(i.issued_id) as number_book_issued,
COUNT(r.return_id) as number_book_return
FROM issued_status as i
RIGHT JOIN
employees as e
ON e.emp_id=i.issued_emp_id
JOIN
branch as b
ON e.branch_id=b.branch_id
 LEFT JOIN
return_status as r
ON r.issued_id=i.issued_id
JOIN 
books as bk
ON i.issued_book_isbn= bk.isbn
Group by b.branch_id,b.manager_id
ORDER BY total_revenue DESC;

SELECT * FROM branch_reports
--Task 16: CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
--containing members who have issued at least one book in the last 2 months.
CREATE TABLE active_members
AS
   SELECT * FROM members
   WHERE member_id IN (SELECT DISTINCT issued_member_id, issued_date
                      FROM issued_status
                      WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month')

SELECT * FROM active_members


--Task 17: Find Employees with the Most Book Issues Processed
--Write a query to find the top 3 employees who have processed the most book issues. 
--Display the employee name, number of books processed, and their branch.
SELECT * from employees 

SELECT e.emp_name, e.branch_id,
COUNT(issued_emp_id) as number_book_issued
FROM issued_status as i
JOIN 
employees as e
ON i.issued_emp_id=e.emp_id
GROUP by e.emp_name, e.branch_id
ORDER BY number_book_issued DESC
LIMIT 4
--Task 18: Identify Members Issuing High-Risk Books
--Write a query to identify members who have issued books more than twice with the status "damaged" 
--in the books table. Display the member name, book title, and the number of times they've issued damaged books.
SELECT * FROM
return_status
WHERE book_condition='damaged'
"IS135"
"IS108"
"IS114"
"IS120" 'C110'
SELECT * FROM issued_status
WHERE issued_member_id='C110'

INSERT INTO issued_status(issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id)
VALUES('IS151','C110','Animal Farm','2026-09-15','978-0-330-25864-8','E108')

SELECT * FROM members
SELECT * FROM return_status
INSERT INTO return_status(return_id,issued_id,return_date,book_condition)
VALUES('RS150','IS151','2026-10-07','damaged')
---
SELECT m.member_name,
COUNT(issued_member_id)as return_damaged_count
FROM issued_status as i
JOIN
return_status as r
ON i.issued_id=r.issued_id
JOIN members as m
ON i.issued_member_id=m.member_id
WHERE r.book_condition ='damaged'
GROUP BY member_name



--Task 19: Stored Procedure Objective: 
--Create a stored procedure to manage the status of books in a library system. 
--Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
--The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
--The procedure should first check if the book is available (status = 'yes'). 
--If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
--If the book is not available (status = 'no'), 
--the procedure should return an error message indicating that the book is currently not available.
SELECT * FROM issued_status

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id varchar(10),p_issued_member_id varchar(10),p_issued_book_name varchar(60),p_issued_book_isbn varchar(20),p_issued_emp_id varchar(20))
LANGUAGE plpgsql
AS
$$
DECLARE 
v_status varchar(10);

BEGIN
SELECT status
 INTO v_status
 FROM books
 WHERE isbn=p_issued_book_isbn;
IF v_status='yes' THEN
    INSERT INTO issued_status(issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id)
    VALUES(p_issued_id,p_issued_member_id,p_issued_book_name,CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id);
    UPDATE books
    SET status='no'
	WHERE isbn=p_issued_book_isbn;
    RAISE NOTICE 'Book issued successfully with isbn: %',p_issued_book_isbn;
 
ELSE
    RAISE NOTICE 'Sorry for the inconvenience, Requested book with isbn: % is not available ', p_issued_book_isbn;
END IF;
END;
$$

CALL issue_book('IS152','C106','Jane Eyre','978-0-141-44171-6','E105')

CALL issue_book('IS153','C106','The Guns of August','978-0-19-280551-1','E106')
SELECT * FROM issued_status

SELECT * FROM books
WHERE status='no'

UPDATE books
SET status='no'
WHERE isbn ='978-0-19-280551-1'
--Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
--Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
--The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
--The number of books issued by each member. 
--The resulting table should show: Member ID Number of overdue books Total fines
--


