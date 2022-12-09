--Comments

--First, an apology. Because "seeing how you think" is a desired outcome of this exercise, I may have written too many comments. And my comments may range from amusing to snide. I don't think they tend toward snide often, but I'd rather you know I'll admit to it before you get there. So I'm sorry. My only excuse is "this is probably the best way to get to know my and my approach to working without actually talking to me."

--I haven't done ER Diagrams since 2010-2011 in the IS Junior Core. I likely haven't represented each relationship accurately (nor do I think my N:N relationships are totally fleshed out the way they ought to be). Additionally, in a few cases, I'm sure my 1:N are in the wrong direction on paper, but correct in my head. Obviously, I'm responsible for that, and have to take the loss, because you only know what I wrote.
--I also want to point out I would test my queries much more intensely (to make sure output and syntax are correct) in the real world, but because I am writing for humans under a time limit, I'm not about to attempt to create this entire database and write queries against it. :D
--Having said that, there are likely minor logical errors that significantly affect output that exist in my "code" (for lack of better term) below which would be obvious when tested for accurancy. I'll own the errors. And vociferously assert I'd see it quickly when dealing with non-theoretical data
--I know DB programming has different preferences from Casing than I tend to prefer (pure sentence case), but I did my own thing here, and am happy to adopt whatever is the organizational standard from day one.
--this is similar for listing multiple selected columns. My preferred method is to put the , on the line _preceding_ the next column selected because ALT+MOUSECLICK/DRAG allows for quick editing of all lines, but again, whatever organizational standard is, I'll adopt.
--Also worth noting none of these are optimized for speed/efficiency. They are simply written to obtain the responses desired. Optimization can come after correct outcome is achieved. 
--Additionally, I wrote them as close to possible as I could without testing. There are some things, like declaring variables that I have purposely stayed away from--despite potential usefulness--because I'm only comfortable writing code for those when I can test it immediately and get feedback from the compiler that I've done it write. Potenitally such practices could make every query better. But I've only alluded to doing so in #6 because it's intense enough that I would rather discuss approach than attempt to actually code it.
--So with my begging for leniency concluded, let's get onto the fun?


SQL Queries:
1. 

--START QUERY 1
Select 
	Count(Distinct E.StudentID) as 'Students Enrolled Today'
	--can change this name to specific day or ('on day') as needed to fit the report request, once the correct query is fully developed.
	--Distinct is required to ensure that we count _students_ not _enrollments_ (students may have many enrollments)
From 
	Enrollment E left join CourseInstance CI on E.CourseInstanceID =  CI.CourseInstanceID 
	--Option 1: Should give expected answer, but is not reliant on snapshot
Where 
	CI.CourseID = '12345' and E.DateAdded < TODAY() and E.DateDropped is NULL

	--Option 2: Reliant on snapshot and a join I'm not sure how to make (and is not defined above)
	-- where CI.CourseID = '12345' and S.SnapshotDate = '2022-02-02"


--END QUERY 1

--With the historical snapshot of information, there would be a way to query that snapshot for the specific information. Given my experience with Domo, and Domo snapshots, I could do it, but I have no idea how to represent a daily snapshop in an ERD other than how I have.

2. 
--Assuming this question means for all courses this instructor teaches in a given semester.

--START QUERY 2
Select
	count(EG.GradeReceived) as 'Remaining grades to submit'

From
	Instructor I left join CourseInstance CI on I.InstructorID = CI.InstructorID 
	left join Enrollment E on CI.CourseInstanceID = E.CourseInstanceID 
	left join EnrollmentGrade EG on E.EnrollmentID = EG.EnrollmentID

Where
	I.InstructorID = 'XYZ' and EG.GradeReceived = Null 

-- END QUERY 2

--depending on Database setup the "is NULL" in #1 and the "= Null" directly above may have to be altered for some other code that communicates the same message to the code interpreter. Because I'm writing for humans, I assume supplied code--even if it would return errors when run--is sufficient.


3. 
--Assuming GPA is weighted by number of credits 
--And assuming this must all be done in one step. In a real world scenario, I would not do this in one step.  I would do each join separately, make a table, ensure my data is correct, and then move to the next.

--START QUERY 3
 Select 
	SUM(GS.GPA Equivalent * E.CreditHoursSelected) / SUM( E.CreditHoursSelected) as 'Semester GPA'
from 
	Enrollment E left join CourseInstance CI on E.CourseInstanceID = CI.CourseInstanceID
	left join EnrollmentGrade EG on E. E.EnrollmentID = EG.EnrollmentID
	left join GradeScale GS on EG.GradeScaleID = GS.GradeScaleID

Where 
	CI.SemesterID = '456' AND (E.StudentID = '12345'  AND E.GradeAudit = 'Grade' AND E.DateDropped  is NULL)


-- END QUERY 3

4.
--Again, assuming GPA is weighted by credit hours


--START QUERY 4
Select
SUM(GS.GPA Equivalent * E.CreditHoursSelected) / SUM( E.CreditHoursSelected) as 'CumulativeGPA'

From
E.Enrollment left join EnrollmentGrade EG on E.EnrollmentID = EG.EnrollmentID left join GradeScale GS on EG.GradeScaleID = GS.GradeScaleID
Where
E.StudentID = '12345'  AND E.GradeAudit = 'Grade' AND E.DateDropped  is NULL

-- END QUERY 4

--need to ensure we show sstudents the same as in #3, without attempting to include dropped courses, etc. in the calculation.
--it's probable that we may also need in include a join and where clause in 3&4 to account for Incompletes. However, because the requirements document is relatively sparse on how such are to be handled, we'll leave that until the business analyst can have a discussion with stakeholders directly--which is outside the scope of this assignment.


5.
--This question is HIGHLY ambiguous and should be sent back for a better definition. 
--Potential interpretiations:
--A. How many students passed at least one course each semester?
--B. How many students passed ALL their courses each semester?
--C. How many total passing grades were given each semester?
--Because of the ambiguity, I'm going to choose to answer A.
--Obviously, this type of question is the header for a cool graph an executive has on their PPT slide, and they think the definition is obvious, but when they ask for this report from the data, the BI analyst needs to factor in a few more things, AND record what this year's definition was--because often executives like changing definitions from year to year.


--START QUERY 5
Select
S.Name as 'Semester'
, count(Distinct E.StudentID) as 'Students Passing at least one class'


From
CourseInstance CI left join Enrollment E on CI. CourseInstanceID = E. EnrollmentID 
left join Semester S on CI.SemesterID = S.SemesterID
left join EnrollmentGrade EG on E.EnrollmentID = EG.EnrollmentID
left join GradeScale GS on EG.GradeScaleID = GS.GradeScaleID



Where
GS.PassingGrade = 'Yes'

Group By 1
-- END QUERY 5


--assuming we don't alter the syntax of this query, the above can stay the same, but we can also choose to group by S.Name
--Note, S.Name and the related Join is included only to make it human readable. We could have used SemesterID, and simply used the course instance table.

6.
--there are a few ways to do this. I can give only two answers. The two semesters in question. I don't really like this outcome. Reading output of extremly succint SQL queries doesn't generally help people reporting on the information. The below intentionally outputs ALL semesters' enrollment activity, which can easily be put into an Excel sheet or Tableau/Domo/PowerBI visualization to show trend in enrollment activity over time, and the person presenting can tell their own story.
--However _daily_ enrollment (as requested) can be shown in a number of ways. With average, when aggregated by day or reported by day. I've defaulted to aggregating and reporting by day, rather than trying to average by day over the whole period (and last year's period), again, because minor work in a reporting suite will give better insight to underlying data for presenters 

--ok. I'll admit I bit off more than I could chew without testing in such a short span. I'll try to make it obvious where I was headed in comments, but I may not succeed.


--this would work better If I were planning to work with declared variables. If I declared @currentDay for example and used in throughout the query, then incremented to the next day, I could simplify the group by clause below, as well as the 'Date' column.

--ALso with @currentDate, I would be able to compare the E.DateAdded and E.DateDropped and E.DateWithdrawn columns to @currentDate to define whether they should be counted as "activity within the enrollment period." (And I'm not sure Withdraws are counted as within the enrollment period, but better to report more than less, when the end user needs are not clearly known..)

--START QUERY 6
Select
S.Name as 'Semester'
Date(E.DateAdded | E.DateDropped | E.DateWithdrawn), as 'Date' 
--This is highly suspect as noted before. There are a few ways alluded to doing what I want (list all days within a range) mentioned here: https://stackoverflow.com/questions/5899829/sql-server-how-to-select-all-days-in-a-date-range-even-if-no-data-exists-for-so that I would investigate and attempt to write in my actual solution. But without the ability to test my query, I have no idea how to tweak those to work within this context.
--With declared @currentDate, replace above with @currentDate
, as 'Enrollments Added' 
--when E.DateAdded = @currentDate, add 1 to total here

--I'll admit this is not the easiest, nor most common name for a non-data-oriented person to present from. But it's common to the database entity name, and the closer we can keep the NDO person to those names without having to translate what they mean by "classes added/dropped" (when the DB definition of "class" doesn't exist (in my case)), then the better we are off as data suppliers. AT some point there may need to be a translation document created and referred to, but as soon as we make that document, people stop reading it.
, as 'Enrollments Dropped'
--when E.DateAdded = @currentDate, add 1 to total here

From
Enrollment E left join EnrollmentPeriod EP on E.EnrollmentPeriodID = EP.EnrollmentPeriodID
left join EP.SemesterID = S.SemesterID

--no where needed, reporting intentionally on all dates within enrollment periods over ALL time, as stated above in assumptions.

group by Date(E.DateAdded | E.DateDropped | E.DateWithdrawn) Desc
--I'm not sure you can do this, but it would be cool if you could
--replace long length with @currentDate
, S.StartDate Desc--Group by start date to get Semesters in correct order datewise

-- END QUERY 6

--Output of this should look something like
Semester, Date, Enrollments Added, Enrollments Dropped
Winter 2023, 2022-12-09, 1300, 400
Winter 2023, 2022-12-08, 1134, 376
...
Winter 2022, 2021-12-09, 1230, 493
Winter 2022, 2021-12-08, 1233, 317
...