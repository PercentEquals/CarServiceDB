-- Simple data selects
SELECT * FROM adresses

SELECT W.workshop_id, A.street, A.city, A.zip FROM workshops W
JOIN adresses A
ON A.adress_id = W.adress_id

