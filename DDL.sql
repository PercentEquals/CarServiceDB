GO
USE master
DROP DATABASE IF EXISTS CarService;

GO
CREATE DATABASE CarService;

GO
USE CarService;

CREATE TABLE addresses (
	address_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	street VARCHAR(255) NOT NULL,
	city VARCHAR(255) NOT NULL,
	zip VARCHAR(255) NOT NULL,

	CONSTRAINT chk_zip CHECK (zip like '[0-9][0-9]-[0-9][0-9][0-9]') 
);

CREATE TABLE workshops (
	workshop_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	address_id INT NOT NULL FOREIGN KEY REFERENCES addresses(address_id),
);

CREATE TABLE employees (
	employee_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	pesel VARCHAR(11) NOT NULL,
	firstname VARCHAR(255) NOT NULL,
	lastname VARCHAR(255) NOT NULL,
	birthdate DATE NOT NULL,
	phone VARCHAR(255) NOT NULL,
	salary INT NOT NULL CHECK(salary >= 0),
	address_id INT NOT NULL FOREIGN KEY REFERENCES addresses(address_id),

	CONSTRAINT e_pesel CHECK (pesel NOT LIKE '%[^0-9]%'),
	CONSTRAINT e_u_pesel UNIQUE(pesel),
);

CREATE TABLE stations (
	station_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	station_number VARCHAR(16) UNIQUE NOT NULL,
	workshop_id INT NOT NULL FOREIGN KEY REFERENCES workshops(workshop_id),
);

CREATE TABLE stations_employees (
	stations_employees_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	station_id INT NOT NULL FOREIGN KEY REFERENCES stations(station_id),
	employee_id INT NOT NULL FOREIGN KEY REFERENCES employees(employee_id),
);

CREATE TABLE schedule (
	schedule_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	station_id INT NOT NULL FOREIGN KEY REFERENCES stations(station_id),
	startdate DATETIME NOT NULL,
	enddate DATETIME NOT NULL,
	is_excluding INT NOT NULL,
);

CREATE TABLE clients (
	client_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	pesel VARCHAR(11) NOT NULL,
	firstname VARCHAR(255) NOT NULL,
	lastname VARCHAR(255) NOT NULL,
	phone VARCHAR(255) NOT NULL,

	CONSTRAINT c_pesel CHECK (pesel NOT LIKE '%[^0-9]%'),
	CONSTRAINT c_u_pesel UNIQUE(pesel),
);

CREATE TABLE vehicles (
	vehicle_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	client_id INT FOREIGN KEY REFERENCES clients(client_id),
	vehicle_type VARCHAR(255) NOT NULL,
	plate VARCHAR(255) NOT NULL,
	mileage INT NOT NULL CHECK(mileage >= 0),

	CONSTRAINT u_plate UNIQUE(plate),
);

CREATE TABLE inspections (
	inspection_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	startdate DATETIME NOT NULL,
	enddate DATETIME NOT NULL,
	price FLOAT NOT NULL CHECK(price >= 0),
	vehicle_mileage INT CHECK(vehicle_mileage >= 0),
	station_id INT NOT NULL FOREIGN KEY REFERENCES stations(station_id),
	vehicle_id INT NOT NULL FOREIGN KEY REFERENCES vehicles(vehicle_id),
);

CREATE TABLE inspections_archive (
	inspection_archive_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	startdate DATETIME NOT NULL,
	enddate DATETIME NOT NULL,
	price FLOAT NOT NULL CHECK(price >= 0),
	vehicle_mileage INT NOT NULL CHECK(vehicle_mileage >= 0),
	station_number VARCHAR(16) NOT NULL,
	workshop_city VARCHAR(255) NOT NULL,
	workshop_street VARCHAR(255) NOT NULL,
	client_pesel VARCHAR(255) NOT NULL,
	vehicle_id INT NOT NULL REFERENCES vehicles(vehicle_id),
);

USE master;