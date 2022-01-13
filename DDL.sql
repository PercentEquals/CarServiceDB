GO
USE master
DROP DATABASE IF EXISTS CarService;

GO
CREATE DATABASE CarService;

GO
USE CarService;

CREATE TABLE adresses (
	adress_id INT NOT NULL PRIMARY KEY,
	street VARCHAR(255) NOT NULL,
	city VARCHAR(255) NOT NULL,
	zip VARCHAR(255) NOT NULL,
);

CREATE TABLE workshops (
	workshop_id INT NOT NULL PRIMARY KEY,
	adress_id INT NOT NULL FOREIGN KEY REFERENCES adresses(adress_id),
);

CREATE TABLE employees (
	employee_id INT NOT NULL PRIMARY KEY,
	firstname VARCHAR(255) NOT NULL,
	lastname VARCHAR(255) NOT NULL,
	phone VARCHAR(255) NOT NULL,
	salary INT NOT NULL CHECK(salary >= 0),
	adress_id INT NOT NULL FOREIGN KEY REFERENCES adresses(adress_id),
);

CREATE TABLE stations (
	station_id INT NOT NULL PRIMARY KEY,
	station_number VARCHAR(16) NOT NULL,
	workshop_id INT NOT NULL FOREIGN KEY REFERENCES workshops(workshop_id),
	employee_id INT FOREIGN KEY REFERENCES employees(employee_id),
);

CREATE TABLE schedule (
	schedule_id INT NOT NULL PRIMARY KEY,
	station_id INT NOT NULL FOREIGN KEY REFERENCES stations(station_id),
	startdate DATE NOT NULL,
	enddate DATE NOT NULL,
	is_excluding INT NOT NULL,
);

CREATE TABLE clients (
	client_id INT NOT NULL PRIMARY KEY,
	firstname VARCHAR(255) NOT NULL,
	lastname VARCHAR(255) NOT NULL,
	phone VARCHAR(255) NOT NULL,
);

CREATE TABLE vehicles (
	vehicle_id INT NOT NULL PRIMARY KEY,
	client_id INT NOT NULL FOREIGN KEY REFERENCES clients(client_id),
	vehicle_type VARCHAR(255) NOT NULL,
	plate VARCHAR(255) NOT NULL,
	mileage INT NOT NULL CHECK(mileage >= 0),
);

CREATE TABLE inspections (
	startdate DATE NOT NULL,
	enddate DATE NOT NULL,
	price FLOAT NOT NULL CHECK(price >= 0),
	vehicle_mileage INT NOT NULL CHECK(vehicle_mileage >= 0),
	station_id INT NOT NULL FOREIGN KEY REFERENCES stations(station_id),
	vehicle_id INT NOT NULL FOREIGN KEY REFERENCES vehicles(vehicle_id),
);

CREATE TABLE inspections_archive (
	inspection_archive_id INT NOT NULL PRIMARY KEY,
	startdate DATE NOT NULL,
	enddate DATE NOT NULL,
	station_number VARCHAR(16) NOT NULL,
	workshop_city VARCHAR(255) NOT NULL,
	workshop_street VARCHAR(255) NOT NULL,
	client_firstname VARCHAR(255) NOT NULL,
	client_lastname VARCHAR(255) NOT NULL,
	vehicle_id INT NOT NULL REFERENCES vehicles(vehicle_id),
	vehicle_mileage INT NOT NULL CHECK(vehicle_mileage >= 0),
);
