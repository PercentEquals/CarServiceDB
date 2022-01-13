USE CarService;

SET IDENTITY_INSERT adresses ON;
INSERT INTO adresses (adress_id, street, city, zip) VALUES
(1, 'Okopowa 88A/67', 'Sieradz', '69-933'),
(2, 'Gdyńska 23', 'Żyrardów', '87-223'),
(3, 'Turkusowa 15A/64', 'Pruszcz Gdański', '00-670'),
(4, 'Górnośląska 78A', 'Kraśnik', '93-074'),
(5, 'Franciszkańska 54A/82', 'Pisz', '56-422'),
(6, 'Kossaka Juliusza 80/41', 'Luboń', '85-891'),
(7, 'Poprzeczna 15', 'Starachowice', '25-410'),
(8, 'Pułaskiego Kazimierza 19A', 'Lubartów', '20-806'),
(9, 'Grota-Roweckiego Stefana 13A', 'Radom', '17-760'),
(10, 'Bieszczadzka 48A/10', 'Częstochowa', '56-353'),
(11, 'Piłsudskiego Józefa 52', 'Będzin', '29-908'),
(12, 'Skośna 99A', 'Pabianice', '64-510'),
(13, 'Krzywa 75/68', 'Jastarnia', '52-867'),
(14, 'Pocztowa 62A', 'Rybnik', '30-345'),
(15, 'Solna 31A', 'Białystok', '66-090'),
(16, 'Bytomska 74A/99', 'Piotrków Trybunalski', '09-360'),
(17, 'Srebrna 45A/01', 'Ostrołęka', '65-623'),
(18, 'Broniewskiego Władysława 08A/22', 'Studzienice', '02-588'),
(19, 'Stwosza Wita 40A/16', 'Skierniewice', '51-986'),
(20, 'Nowowiejskiego Feliksa 42/16', 'Łódź', '97-643'),
(21, 'Rynek 33', 'Skarżysko-Kamienna', '24-272'),
(22, 'Norwida Cypriana Kamila 78/71', 'Piła', '21-431'),
(23, 'Legnicka 22/04', 'Kraśnik', '35-473'),
(24, 'Rzeczna 62/38', 'Piotrków Trybunalski', '73-085'),
(25, 'Wolności Pl. 88A/80', 'Czarna Woda', '03-471'),
(26, 'Barlickiego Norberta 04A', 'Świecie', '58-908'),
(27, 'Myśliwska 65A', 'Wałbrzych', '75-204'),
(28, 'Sosnowa 00A', 'Lębork', '74-404'),
(29, 'Prosta 91', 'Elbląg', '97-595'),
(30, 'Nowy Świat 11A', 'Mokrzyska', '71-605'),
(31, 'Lisia 59A', 'Kołobrzeg', '20-852'),
(32, 'Pułaskiego Kazimierza 63/98', 'Marylka', '80-400'),
(33, 'Rybna 22/17', 'Lublin', '88-414'),
(34, 'Olchowa 06', 'Jasło', '44-175'),
(35, 'Białostocka 35A/76', 'Łęczna', '28-997'),
(36, 'Brzozowa 30A/57', 'Żory', '04-966'),
(37, 'Leśmiana Bolesława 45/54', 'Knurów', '18-233'),
(38, 'Oświęcimska 58/52', 'Kłodzko', '76-328'),
(39, 'Gminna 88A/25', 'Otwock', '42-489'),
(40, 'Patriotów 81/79', 'Kamieniec Ząbkowicki', '13-890'),
(41, 'Szczecińska 47A', 'Bieruń', '32-578'),
(42, 'Krańcowa 90A', 'Zawiercie', '05-145'),
(43, 'Szarych Szeregów 43', 'Boguszów-Gorce', '01-425'),
(44, 'Podchorążych 34A/99', 'Legnica', '32-619'),
(45, 'Pola Wincentego 60', 'Żory', '93-487'),
(46, 'Kilińskiego Jana 47/28', 'Racibórz', '65-668'),
(47, 'Słowackiego Juliusza 37', 'Piła', '21-091'),
(48, 'Granitowa 04A', 'Leszno', '77-284'),
(49, 'Warmińska 67', 'Bartoszyce', '82-131'),
(50, 'Kusocińskiego Janusza 45A/08', 'Starogard Gdański', '11-719');
SET IDENTITY_INSERT adresses OFF;

SET IDENTITY_INSERT workshops ON;
INSERT INTO workshops (workshop_id, adress_id) VALUES 
(1, 41),
(2, 42),
(3, 43),
(4, 44),
(5, 45),
(6, 46),
(7, 47),
(8, 48),
(9, 49),
(10, 50);
SET IDENTITY_INSERT workshops OFF;

SET IDENTITY_INSERT employees ON;
INSERT INTO employees (employee_id, firstname, lastname, birthdate, phone, salary, adress_id) VALUES
(1, 'Adam', 'Kwiatkowski', '19801220 01:00:00 PM', '+48678801751', 4200, 23),
(2, 'Tomek', 'Nowak', '19760127 01:00:00 PM', '+48389120930', 4900, 27),
(3, 'Piotr', 'Wójcik', '19771216 01:00:00 PM', '+48334192294', 4700, 36),
(4, 'Katarzyna', 'Kamińska', '19721126 01:00:00 PM', '+48001320395', 4700, 18),
(5, 'Krzysztof', 'Szymański', '19730112 01:00:00 PM', '+48739757140', 3500, 27),
(6, 'Katarzyna', 'Kaczmarek', '19910814 01:00:00 PM', '+48093425285', 3700, 8),
(7, 'Grażyna', 'Szymańska', '19891016 01:00:00 PM', '+48565441140', 4100, 40),
(8, 'Piotr', 'Grabowski', '19890510 01:00:00 PM', '+48995319731', 3500, 32),
(9, 'Patryk', 'Grabowski', '19920422 01:00:00 PM', '+48780294130', 3300, 8),
(10, 'Krzysztof', 'Mazur', '19791207 01:00:00 PM', '+48476755957', 4200, 8),
(11, 'Jan', 'Mazur', '19900813 01:00:00 PM', '+48013478791', 4000, 11),
(12, 'Grażyna', 'Kowalska', '19940409 01:00:00 PM', '+48678795869', 2900, 25),
(13, 'Grażyna', 'Grabowska', '19940617 01:00:00 PM', '+48440135769', 4500, 23),
(14, 'Klaudia', 'Kowalczyk', '19851224 01:00:00 PM', '+48824247788', 2700, 24),
(15, 'Jan', 'Wójcik', '19711210 01:00:00 PM', '+48748569496', 4000, 37),
(16, 'Tomek', 'Kozłowski', '19760913 01:00:00 PM', '+48388375955', 3500, 10),
(17, 'Tomek', 'Kucharski', '19711226 01:00:00 PM', '+48557983155', 3400, 24),
(18, 'Krystyna', 'Nowak', '19730604 01:00:00 PM', '+48586146504', 4300, 20),
(19, 'Jan', 'Krawczyk', '19790805 01:00:00 PM', '+48505738391', 2700, 17),
(20, 'Alicja', 'Kucharska', '19740615 01:00:00 PM', '+48985038130', 2800, 32);
SET IDENTITY_INSERT employees OFF;

SET IDENTITY_INSERT stations ON;
INSERT INTO stations (station_id, station_number, workshop_id) VALUES 
(1, 'ST-1', 1),
(2, 'ST-2', 1),
(3, 'ST-1', 2),
(4, 'ST-2', 2),
(5, 'ST-1', 3),
(6, 'ST-2', 3),
(7, 'ST-1', 4),
(8, 'ST-2', 4),
(9, 'ST-1', 5),
(10, 'ST-2', 5),
(11, 'ST-1', 6),
(12, 'ST-2', 6),
(13, 'ST-1', 7),
(14, 'ST-2', 7),
(15, 'ST-1', 8),
(16, 'STAT-1', 8),
(17, 'STAT-3', 8),
(18, 'STAT-2', 8),
(19, 'STAT-4', 8),
(20, 'ST-1', 10),
(21, 'ST-2', 10);
SET IDENTITY_INSERT stations OFF;

SET IDENTITY_INSERT stations_employees ON;
INSERT INTO stations_employees (stations_employees_id, station_id, employee_id) VALUES
(1, 1, 10),
(2, 1, 11),
(3, 2, 12),
(4, 2, 13),
(5, 3, 1),
(6, 4, 1),
(7, 5, 3),
(8, 6, 3),
(9, 7, 4),
(10, 8, 5),
(11, 9, 6),
(12, 10, 7),
(13, 11, 8),
(14, 12, 9),
(15, 13, 20),
(16, 14, 19),
(17, 15, 18),
(18, 16, 17),
(19, 17, 16),
(20, 18, 15),
(21, 19, 14);
SET IDENTITY_INSERT stations_employees OFF;

--SET IDENTITY_INSERT schedule ON;
--SET IDENTITY_INSERT clients ON;
--SET IDENTITY_INSERT vehicles ON;
--SET IDENTITY_INSERT inspections ON;
--SET IDENTITY_INSERT inspections_archive ON;

--SET IDENTITY_INSERT schedule OFF;
--SET IDENTITY_INSERT clients OFF;
--SET IDENTITY_INSERT vehicles OFF;
--SET IDENTITY_INSERT inspections OFF;
--SET IDENTITY_INSERT inspections_archive OFF;