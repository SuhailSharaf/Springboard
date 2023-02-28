/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT * 
FROM `Facilities` 
WHERE membercost > 0;

Facilities that charge a fee to members:
Tennis Court 1 
Tennis Court 2
Massage Room 1 
Massage Room 2
Squash Court 

/* Q2: How many facilities do not charge a fee to members? */

SELECT count(name) 
FROM `Facilities` 
WHERE membercost = 0;

4 facilities are not free for members


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance 
FROM `Facilities` 
WHERE membercost > 0 
AND membercost < 0.2*monthlymaintenance;

The facilities that are returned:
Tennis Court 1 
Tennis Court 2
Massage Room 1 
Massage Room 2
Squash Court 

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * 
FROM `Facilities` 
WHERE facid in (1,5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, 
    monthlymaintenance, 
    CASE WHEN monthlymaintenance > 100 THEN 'Expensive' 
    ELSE 'Cheap' END as "Cheap or Expensive?" 
FROM `Facilities`;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname 
FROM `Members` 
WHERE memid = (
    SELECT MAX(memid) 
    FROM `Members`)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT CONCAT(m.surname, ", ", m.firstname) AS "Full Name",
	f.name AS "Tennis Court Used"
FROM `Bookings` as b 
INNER JOIN `Facilities` as f ON b.facid = f.facid
INNER JOIN `Members` as m ON b.memid = m.memid
WHERE b.facid IN (0,1)
GROUP BY 1,2 
ORDER BY 1;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name AS  "Facility Name",
       CONCAT( m.surname,  ", ", m.firstname ) AS "Full Name", 
       CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
            ELSE f.membercost * b.slots END AS "Cost"
FROM `Bookings` AS b
JOIN `Members` AS m ON b.memid = m.memid
JOIN `Facilities` AS f ON b.facid = f.facid
WHERE b.starttime LIKE '2012-09-14%'
HAVING Cost > 30
ORDER BY 3 DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT subq.facilname AS "Facility Name",
       subq.fullname AS "Name",
       subq.totalcost AS "Cost"
FROM (

    SELECT f.name AS facilname,
           CONCAT( m.surname,  ", ", m.firstname ) AS fullname, 
           CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
                ELSE f.membercost * b.slots END AS totalcost
    FROM `Bookings` AS b
    JOIN `Members` AS m ON b.memid = m.memid
    JOIN `Facilities` AS f ON b.facid = f.facid
    WHERE b.starttime LIKE '2012-09-14%'
    ) subq

WHERE subq.totalcost > 30
ORDER BY 3 DESC

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

from sqlalchemy import create_engine
import pandas as pd
engine = create_engine('sqlite:///sqlite_db_pythonsqlite.db')
command_10 = '''SELECT facility, SUM(cost) as tot_revenue
FROM
(SELECT f.name as facility, firstname || ' ' || surname as client,
CASE WHEN firstname = 'GUEST' THEN guestcost*slots
  ELSE membercost*slots END AS cost
FROM Members as m
INNER JOIN Bookings as b
USING(memid)
INNER JOIN Facilities as f
USING(facid)) AS subquery_1
GROUP BY facility
HAVING tot_revenue < 1000
ORDER BY tot_revenue'''
revenue = pd.read_sql_query(command_10, engine)
print(revenue)

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

command_11 = '''SELECT m1.firstname as firstname, m1.surname as surname,
m2.firstname || ' ' || m2.surname as recommendedby
FROM Members AS m1
INNER JOIN Members AS m2
ON (m1.recommendedby = m2.memid AND m1.recommendedby>0)
ORDER BY surname, firstname'''
name_and_recommendedby = pd.read_sql_query(command_2, engine)
print(name_and_recommendedby.head(10))


/* Q12: Find the facilities with their usage by member, but not guests */

command_12 = '''SELECT f.name as facility, SUM(b.slots) as member_bookings
FROM Members as m
INNER JOIN Bookings as b
USING(memid)
INNER JOIN Facilities as f
USING(facid)
WHERE m.memid != 0
GROUP BY facility'''
facility_and_member_usage = pd.read_sql_query(command_12, engine)
print(facility_and_member_usage)

/* Q13: Find the facilities usage by month, but not guests */

command_13 = '''SELECT f.name as facility, strftime('%m', b.starttime) as month,
SUM(b.slots) as member_bookings
FROM Members as m
INNER JOIN Bookings as b
USING(memid)
INNER JOIN Facilities as f
USING(facid)
WHERE m.memid != 0
GROUP BY facility, month'''
facility_usage_each_month_by_members = pd.read_sql_query(command_13, engine)
print(facility_usage_each_month_by_members)