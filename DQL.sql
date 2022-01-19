USE CarService;

---- Data selects ----

-- 1. SELECT WORKSHOPS WITH THEIR ADDRESSES
SELECT W.workshop_id, A.street, A.city, A.zip FROM workshops W
JOIN addresses A
ON A.address_id = W.address_id

-- 2. SELECT WORKSHOPS WITH THEIR STATION AND EMPLOYEE COUNT
SELECT W.workshop_id, COUNT(S.station_id) AS [Stations Count], COUNT(SE.station_id) AS [Employee Count] FROM workshops W
LEFT JOIN stations S
ON S.workshop_id = W.workshop_id
LEFT JOIN stations_employees SE
ON SE.station_id = S.station_id
GROUP BY W.workshop_id

-- 3. SELECT MIN, MAX AND AVG SALARY OF ALL EMPLOYEES FOR EVERY WORKSHOP
SELECT W.workshop_id, AVG(E.salary) AS [Avarage Salary], MAX(E.salary) AS [Highest salary], MIN(E.salary) AS [Lowest Salary] FROM workshops W
LEFT JOIN stations S
ON S.workshop_id = W.workshop_id
LEFT JOIN stations_employees SE
ON SE.station_id = S.station_id
LEFT JOIN employees E
ON E.employee_id = SE.employee_id
GROUP BY W.workshop_id

-- 4. SELECT EMPLOYEES WITH THE CITY THEY LIVE IN AND WITH CITY THEY WORK IN
SELECT DISTINCT E.pesel, CONCAT(E.firstname, ' ', lastname) AS [Firstname and lastname], E.birthdate, E.phone, E.salary, A.city AS [Lives in], WA.city AS [Works in] FROM employees E
JOIN addresses A 
ON A.address_id = E.address_id
JOIN stations_employees SE
ON SE.employee_id = E.employee_id
JOIN stations S
ON S.station_id = SE.station_id
JOIN workshops W
ON W.workshop_id = S.workshop_id
JOIN addresses WA
ON WA.address_id = W.address_id

-- 5. SELECT EMPLOYEES THAT HAVE THE HIGHEST SALARY
SELECT TOP 1 WITH TIES pesel, DATEDIFF(YY, birthdate, GETDATE()) AS [Age], salary FROM employees
WHERE salary IN (
	SELECT MAX(salary) FROM employees
) ORDER BY salary DESC

-- 6. SELECT VEHICLES THAT HAD DIFFERENT OWNER IN THE PAST
SELECT V.*, IA.client_pesel AS [Previous owner PESEL], C.pesel AS [Current Owner PESEL] FROM vehicles V
JOIN clients C
ON C.client_id = V.client_id
JOIN inspections_archive IA
ON IA.vehicle_id = V.vehicle_id
WHERE IA.client_pesel != C.pesel

-- 7. SELECT CLIENTS THAT HAVE MULTIPLE CARS
SELECT C.client_id, C.pesel, COUNT(V.vehicle_id) AS [Vehicle count] FROM clients C
JOIN vehicles V
ON V.client_id = C.client_id
GROUP BY C.client_id, C.pesel
HAVING COUNT(V.vehicle_id) > 1

-- 8. SELECT CLIENTS THAT HAVE MULTIPLE INSPECTIONS SCHEDULED
SELECT C.client_id, C.pesel, COUNT(*) AS [Inspections count] FROM clients C
JOIN vehicles V
ON V.client_id = C.client_id
JOIN inspections I
ON I.vehicle_id = V.vehicle_id
GROUP BY C.client_id, C.pesel
HAVING COUNT(*) > 1

-- 9. SELECT LAST INSPECTION FOR EACH STATION
SELECT I.startdate, I.enddate, I.price, I.vehicle_mileage, I.station_id, I.vehicle_id FROM inspections I
JOIN stations S
ON S.station_id = I.station_id
WHERE I.enddate IN (SELECT MAX(enddate) FROM inspections GROUP BY station_id)
GROUP BY I.startdate, I.enddate, I.price, I.vehicle_mileage, I.station_id, I.vehicle_id

-- 10. SELECT NUMBER OF OPEN HOURS FOR EACH STATION
SELECT station_id, 
(
	SELECT SUM(DATEDIFF(HH, startdate, enddate)) FROM schedule 
	WHERE is_excluding = 0 
	AND station_id = S.station_id
) - 
ISNULL
(
	(
		SELECT SUM(DATEDIFF(HH, startdate, enddate)) FROM schedule 
		WHERE is_excluding = 1 
		AND station_id = S.station_id
	)
, 0) AS [Number of open hours] FROM schedule S
GROUP BY station_id

-- 11. EMPLOYEES WHO EARN MORE SALARY THAN AVERAGE OF ALL
SELECT E.employee_id, E.firstname, E.lastname, E.salary FROM employees E
WHERE E.salary > 
(
	SELECT AVG(salary) FROM employees
) 
ORDER BY E.salary DESC

-- 12. SELECT NUMBER OF INSPECTIONS THAT EACH CAR EVER HAD
SELECT V.vehicle_id, COUNT(*) + 
(
	SELECT COUNT(*) FROM inspections_archive 
	WHERE V.vehicle_id = vehicle_id
) AS [Number of inspections] FROM vehicles V
JOIN inspections I
ON I.vehicle_id = V.vehicle_id
GROUP BY V.vehicle_id

-- 13. SELECT VEHICLES THAT HAVE LOWER MILEAGE THAN DURING LAST INSPECTION (FAKING MILEAGE)
SELECT I.vehicle_id FROM inspections I
LEFT JOIN inspections_archive IA
ON IA.vehicle_id = I.vehicle_id
WHERE I.vehicle_mileage < IA.vehicle_mileage

-- 14. SELECT HOW MANY INSPECTIONS WERE THERE EACH MONTH IN YEAR 2021
SELECT MONTH(enddate) AS [Month], COUNT(*) + 
(
	SELECT COUNT(*) FROM inspections_archive 
	WHERE I.vehicle_id = vehicle_id 
	AND MONTH(enddate) = MONTH(I.enddate)
) AS [Number of inspections] FROM inspections I
WHERE YEAR(enddate) = 2021
GROUP BY MONTH(enddate), I.vehicle_id

-- 15. SELECT NUMBER OF EMPLOYEES WHO LIVE IN THE SAME CITY
SELECT A.city, COUNT(*) AS [Number of people] FROM employees E
JOIN addresses A
ON A.address_id = E.address_id
GROUP BY A.city

---- Functions ----

-- 1. CALCULATE DISCOUNT
IF object_id(N'calc_discount', N'FN') IS NOT NULL
    DROP FUNCTION calc_discount
GO

GO
CREATE FUNCTION calc_discount(@price FLOAT, @vehicle INT, @station INT, @startdate DATETIME) RETURNS FLOAT
BEGIN
	DECLARE @new_price FLOAT = @price

	DECLARE @client_id INT = (SELECT client_id FROM vehicles WHERE vehicle_id = @vehicle)
	DECLARE @workshop_id INT = (SELECT workshop_id FROM stations WHERE station_id = @station)

	-- Reduce if regular customer in the same workshop
	DECLARE @how_many_in_same_workshop INT = (
		SELECT COUNT(*) 
		FROM inspections_archive 
		WHERE vehicle_id = @vehicle 
		AND workshop_city = (
			SELECT city FROM addresses WHERE address_id = (SELECT address_id FROM workshops WHERE workshop_id = @workshop_id)
		)
		AND workshop_street = (
			SELECT street FROM addresses WHERE address_id = (SELECT address_id FROM workshops WHERE workshop_id = @workshop_id)
		)
		AND client_pesel = (
			SELECT pesel FROM clients WHERE client_id = (SELECT client_id FROM vehicles WHERE vehicle_id = @vehicle)
		)
	)

	IF @how_many_in_same_workshop >= 3
		SET @new_price = @new_price - 20
	ELSE IF @how_many_in_same_workshop >= 2
		SET @new_price = @new_price - 10
	ELSE IF @how_many_in_same_workshop >= 1
		SET @new_price = @new_price - 5

	-- Reduce if customer have already scheduled another inspection for other vehicle this month
	DECLARE @other_schedules INT = (
		SELECT COUNT(*)
		FROM inspections
		WHERE vehicle_id != @vehicle
		AND vehicle_id IN (SELECT vehicle_id FROM vehicles WHERE client_id = @client_id)
		AND startdate >= GETDATE()
		AND DATEDIFF(month, startdate, @startdate) = 0
	)

	IF @other_schedules >= 2
		SET @new_price = @new_price - 20
	ELSE IF @how_many_in_same_workshop >= 1
		SET @new_price = @new_price - 10

	-- Limit reduction to 50% max
	IF @new_price <= 0.5 * @price
		SET @new_price = 0.5 * @price

	RETURN @new_price
END
GO

---- Triggers ----

-- 1. TRIGGER WHEN INSERTING A INSPECTION TO CALCULATE PRICE WITH DISCOUNT REDUCTION
IF object_id('inspection_calc_discount', 'TR') IS NOT NULL  
   DROP TRIGGER inspection_calc_discount;
GO

GO
CREATE TRIGGER inspection_calc_discount ON inspections INSTEAD OF INSERT
AS
BEGIN
	INSERT INTO inspections
	SELECT startdate, enddate, dbo.calc_discount(price, vehicle_id, station_id, startdate), vehicle_mileage, station_id, vehicle_id FROM inserted
END
GO

-- 2. TRIGGER WHEN DELETING A INSPECTION TO ARCHIVE IT INSTEAD
IF object_id('inspection_delete', 'TR') IS NOT NULL  
   DROP TRIGGER inspection_delete;
GO

GO
CREATE TRIGGER inspection_delete ON inspections AFTER DELETE
AS
BEGIN
	INSERT INTO inspections_archive
	SELECT DISTINCT D.startdate, D.enddate, D.price, D.vehicle_mileage, S.station_number, A.city, A.street, C.pesel, D.vehicle_id FROM deleted D
	JOIN stations S ON S.station_id = D.station_id
	JOIN workshops W ON W.workshop_id = S.workshop_id
	JOIN addresses A ON A.address_id = W.address_id
	JOIN vehicles V ON V.vehicle_id = D.vehicle_id
	JOIN clients C ON C.client_id = V.client_id
	WHERE D.enddate <= GETDATE() AND D.vehicle_mileage IS NOT NULL
END
GO

BEGIN
	DELETE FROM inspections WHERE startdate < GETDATE()
	SELECT * FROM inspections_archive
END

---- Procedures ----

-- 1. CREATE SCHEDULE FOR STATION
GO
IF EXISTS(SELECT 1 FROM sys.objects WHERE type='P' AND name='create_schedule') DROP PROCEDURE create_schedule

GO
CREATE PROCEDURE create_schedule 
	@station INT = 0,
	@datestart DATE,
	@dateend DATE,
	@starting_time TIME,
	@ending_time TIME,
	@exclude_weekdays INT = 1,
	@is_excluding INT = 0
AS
BEGIN
	IF @exclude_weekdays >= 1
	BEGIN
		WITH dateRange AS (
			SELECT @datestart AS d
			UNION ALL
			SELECT DATEADD(day, 1, d)
			FROM dateRange
			WHERE DATEADD(day, 1, d) <= @dateend
		)
		INSERT INTO schedule
		SELECT @station,
			   (CAST(d AS DATETIME) + CAST(@starting_time AS DATETIME)) AS [startdate], 
			   (CAST(d AS DATETIME) + CAST(@ending_time AS DATETIME)) AS [enddate],
			   @is_excluding
		FROM dateRange
		WHERE DATENAME(DW, d) != 'Saturday' AND DATENAME(DW, d) != 'Sunday'
		OPTION (MAXRECURSION 0)
	END
	ELSE
	BEGIN
		WITH dateRange AS (
			SELECT @datestart AS d
			UNION ALL
			SELECT DATEADD(day, 1, d)
			FROM dateRange
			WHERE DATEADD(day, 1, d) <= @dateend
		)
		INSERT INTO schedule
		SELECT @station,
			   (CAST(d AS DATETIME) + CAST(@starting_time AS DATETIME)) AS [startdate], 
			   (CAST(d AS DATETIME) + CAST(@ending_time AS DATETIME)) AS [enddate],
			   @is_excluding
		FROM dateRange
		OPTION (MAXRECURSION 0)
	END
END
GO

BEGIN
	EXEC create_schedule 2, '20220101', '20220201', '08:30:00.00', '16:30:00.00'
END

-- 2. SCHEDULE A INSPECTION 
GO
IF EXISTS(SELECT 1 FROM sys.objects WHERE type='P' AND name='schedule_inspection') DROP PROCEDURE schedule_inspection

GO
CREATE PROCEDURE schedule_inspection 
	@workshop INT = 0,
	@datestart DATETIME,
	@vehicle INT = 0,
	@success INT OUTPUT
AS
BEGIN
	-- Check if date is not in the past
	IF @datestart < GETDATE()
	BEGIN
		SET @success = 0
		PRINT CONCAT('Inspection cannot be scheduled in the past! [', CONVERT(varchar, @datestart), ']')
		RETURN
	END

	-- Calculate length and end date
	DECLARE @vtype VARCHAR(255) = (SELECT vehicle_type FROM vehicles WHERE vehicle_id = @vehicle)
	DECLARE @length TIME = CASE @vtype
        WHEN 'Motor' THEN '00:30:00.00'
		WHEN 'Car' THEN '01:00:00.00'
		WHEN 'Taxi' THEN '01:00:00.00'
		WHEN 'Van' THEN '01:30:00.00'
		WHEN 'Special' THEN '02:00:00.00'
	END

	DECLARE @price INT = CASE @vtype
        WHEN 'Motor' THEN 50
		WHEN 'Car' THEN 100
		WHEN 'Taxi' THEN 200
		WHEN 'Van' THEN 400
		WHEN 'Special' THEN 1000
	END

	DECLARE @dateend DATETIME = @datestart + CAST(@length AS DATETIME)

	-- Check if there is available schedule for that date range (also checks if there are employees on that station)
	DECLARE @available_station INT = (SELECT TOP 1 S.station_id FROM schedule S
	JOIN stations_employees E
	ON S.station_id = E.station_id
	WHERE S.station_id IN (
		SELECT station_id FROM stations
		WHERE workshop_id = @workshop
	) 
	AND startdate <= @datestart 
	AND DATEDIFF(day, @datestart, startdate) = 0
	AND enddate >= @dateend
	AND is_excluding = 0
	AND S.station_id NOT IN (
		-- Check if there is an 'exclusion' - for example: break time
		SELECT station_id FROM schedule
		WHERE station_id = S.station_id
		AND DATEDIFF(day, @datestart, startdate) = 0
		AND is_excluding = 1
		AND (
			(startdate <= @datestart AND enddate >= @dateend) OR
			(startdate < @dateend AND enddate >= @dateend) OR
			(startdate <= @datestart AND enddate > @datestart)
		)
	)
	AND S.station_id NOT IN (
		-- Check if there is already an inspection that would collide
		SELECT station_id FROM inspections
		WHERE station_id = S.station_id
		AND DATEDIFF(day, @datestart, startdate) = 0
		AND (
			(startdate <= @datestart AND enddate >= @dateend) OR
			(startdate < @dateend AND enddate > @dateend) OR
			(startdate < @datestart AND enddate > @datestart)
		)
	)
	GROUP BY S.station_id
	HAVING COUNT(employee_id) > 0)

	IF @available_station IS NOT NULL
	BEGIN
		INSERT INTO inspections VALUES (@datestart, @dateend, @price, NULL, @available_station, @vehicle)
		SET @success = 1
		PRINT CONCAT('Inspection has been scheduled [', CONVERT(varchar, @datestart), ' - ', CONVERT(varchar, @dateend), ']')
	END
	ELSE
	BEGIN
		SET @success = 0
		PRINT CONCAT('Inspection could not be scheduled for given date and time! [', CONVERT(varchar, @datestart), ' - ', CONVERT(varchar, @dateend), ']')
	END
END
GO

BEGIN
	DECLARE @success_flag INT
	DECLARE @vehicle INT = 49

	EXEC schedule_inspection 1, '20230102 8:00:00.00 AM', @vehicle, @success_flag OUTPUT

	-- THERE IS ALREADY INSPECTION GOING ON
	EXEC schedule_inspection 1, '20230101 8:00:00.00 AM', @vehicle, @success_flag OUTPUT
	EXEC schedule_inspection 1, '20230101 9:30:00.00 AM', @vehicle, @success_flag OUTPUT

	-- EXCLUDED
	EXEC schedule_inspection 1, '20230102 8:45:00.00 AM', @vehicle, @success_flag OUTPUT
	EXEC schedule_inspection 1, '20230102 9:30:00.00 AM', @vehicle, @success_flag OUTPUT

	-- IN PAST
	EXEC schedule_inspection 1, '20200103 8:45:00.00 AM', @vehicle, @success_flag OUTPUT
END

-- TODO: one more procedure

---- More triggers ----

-- 3. TRIGGER INSTEAD OF UPDATING A INSPECTION TO USE schedule_inspection PROCEDURE
IF object_id('inspection_update', 'TR') IS NOT NULL  
   DROP TRIGGER inspection_update;
GO

GO
CREATE TRIGGER inspection_update ON inspections INSTEAD OF UPDATE
AS
BEGIN
	-- Success flag
	DECLARE @inspection_success_flag INT

	-- Cursor init
	DECLARE ins_cursor CURSOR FOR
	SELECT inspection_id, startdate, enddate, station_id, vehicle_id FROM inserted
	DECLARE @workshop_id INT, @inspection_id INT, @startdate DATETIME, @enddate DATETIME, @station_id INT, @vehicle_id INT


	OPEN ins_cursor
	FETCH NEXT FROM ins_cursor INTO @inspection_id, @startdate, @enddate, @station_id, @vehicle_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRANSACTION
		-- Remove old schedule so it does not intervene with 'schedule_inspection' procedure
		DELETE FROM inspections WHERE inspection_id = @inspection_id

		-- Try to schedule new date
		SET @workshop_id = (SELECT workshop_id FROM stations WHERE station_id = @station_id)
		EXEC schedule_inspection @workshop_id, @startdate, @vehicle_id, @inspection_success_flag OUTPUT

		-- Check if new date has been scheduled...
		IF @inspection_success_flag >= 1
		BEGIN
			-- ... if yes, commit changes
			COMMIT
			PRINT CONCAT('Successfully rescheduled inspection [', CONVERT(varchar, @startdate), ']')
		END
		ELSE
		BEGIN
			-- ... if not, rollback to previous date
			ROLLBACK
			PRINT CONCAT('Inspection could not be rescheduled to target date! [', CONVERT(varchar, @startdate), ']')
		END

		FETCH NEXT FROM ins_cursor INTO @inspection_id, @startdate, @enddate, @station_id, @vehicle_id
	END

	-- Cleanup
	CLOSE ins_cursor
	DEALLOCATE ins_cursor
END
GO

BEGIN
	-- Rollback
	UPDATE inspections SET startdate = '20210101 10:00:00.000 AM' WHERE inspection_id = 1

	-- Success
	UPDATE inspections SET startdate = '20230102 2:00:00.000 PM' WHERE inspection_id = 1
END

SELECT * FROM inspections

USE master;