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
-- TODO

---- Functions ----

-- 1. CALCULATE DISCOUNT
IF object_id(N'calc_discount', N'FN') IS NOT NULL
    DROP FUNCTION calc_discount
GO

GO
CREATE FUNCTION calc_discount(@price FLOAT, @vehicle INT, @station INT) RETURNS FLOAT
BEGIN
	DECLARE @new_price FLOAT = @price

	-- Reduce if regular customer in the same workshop
	DECLARE @how_many_in_same_workshop INT = (
		SELECT COUNT(*) FROM inspections WHERE vehicle_id = @vehicle AND station_id IN (
			SELECT station_id FROM stations WHERE workshop_id IN (
				SELECT workshop_id FROM stations WHERE station_id = @station
			)
		)
	)

	IF @how_many_in_same_workshop >= 3
		SET @new_price = @new_price - 20
	ELSE IF @how_many_in_same_workshop >= 2
		SET @new_price = @new_price - 10
	ELSE IF @how_many_in_same_workshop >= 1
		SET @new_price = @new_price - 5

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
	SELECT startdate, enddate, dbo.calc_discount(price, vehicle_id, station_id), vehicle_mileage, station_id, vehicle_id FROM inserted
END
GO

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
	@vehicle INT = 0
AS
BEGIN
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

		PRINT CONCAT('Inspection has been scheduled [', CONVERT(varchar, @datestart), ' - ', CONVERT(varchar, @dateend), ']')
	END
	ELSE
	BEGIN
		PRINT CONCAT('Inspection could not be scheduled for given date and time! [', CONVERT(varchar, @datestart), ' - ', CONVERT(varchar, @dateend), ']')
	END
END
GO

BEGIN
	SELECT * FROM inspections WHERE vehicle_id = 49
	EXEC schedule_inspection 1, '20220102 8:00:00.00 AM', 49
	SELECT * FROM inspections WHERE vehicle_id = 49

	-- THERE IS ALREADY INSPECTION GOING ON
	EXEC schedule_inspection 1, '20220101 8:00:00.00 AM', 49
	EXEC schedule_inspection 1, '20220101 9:30:00.00 AM', 49

	-- EXCLUDED
	EXEC schedule_inspection 1, '20220102 8:45:00.00 AM', 49
	EXEC schedule_inspection 1, '20220102 9:30:00.00 AM', 49
END

USE master;