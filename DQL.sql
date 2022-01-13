USE CarService;

-- Data selects

-- 1. SELECT WORKSHOPS WITH THEIR ADRESSES
SELECT W.workshop_id, A.street, A.city, A.zip FROM workshops W
JOIN adresses A
ON A.adress_id = W.adress_id

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
SELECT E.pesel, CONCAT(E.firstname, ' ', lastname) AS [Firstname and lastname], E.birthdate, E.phone, E.salary, A.city AS [Lives in], WA.city AS [Works in] FROM employees E
JOIN adresses A 
ON A.adress_id = E.adress_id
JOIN stations_employees SE
ON SE.employee_id = E.employee_id
JOIN stations S
ON S.station_id = SE.station_id
JOIN workshops W
ON W.workshop_id = S.workshop_id
JOIN adresses WA
ON WA.adress_id = W.adress_id

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


USE master;