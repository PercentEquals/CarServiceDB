USE CarService;

-- Simple data selects
SELECT * FROM adresses

SELECT W.*, A.street, A.city, A.zip FROM workshops W
JOIN adresses A
ON A.adress_id = W.adress_id

SELECT E.*, A.street, A.city, A.zip FROM employees E
JOIN adresses A 
ON A.adress_id = E.adress_id

SELECT S.*, A.city AS [workshop_city] FROM stations S
RIGHT JOIN workshops W
ON S.workshop_id = W.workshop_id
LEFT JOIN adresses A
ON A.adress_id = W.adress_id

