-- Создание табличного пространства
CREATE TABLESPACE hotel_tablespace 
LOCATION 'D:\postgres\hotel';


-- Создание базы данных в табличном пространстве
CREATE DATABASE hotel_database 
WITH TABLESPACE = hotel_tablespace;

-- Создание схемы
CREATE SCHEMA hotel_schema;

-- Домены для ограничения данных
CREATE DOMAIN hotel_schema.PassportDataDomain AS VARCHAR(20)
    CHECK (LENGTH(VALUE) = 20);  -- Ограничение на длину паспортных данных

CREATE DOMAIN hotel_schema.ComfortLevelDomain AS VARCHAR(8)
    CHECK (VALUE IN ('Basic', 'Standard', 'Deluxe', 'Suite'));  -- Доступные уровни комфорта

CREATE DOMAIN hotel_schema.PriceDomain AS DECIMAL(10, 2)
    CHECK (VALUE > 0);  -- Цена должна быть больше 0

CREATE DOMAIN hotel_schema.BedCountDomain AS INT
    CHECK (VALUE >= 1 AND VALUE <= 4);  -- Количество кроватей от 1 до 4

CREATE DOMAIN hotel_schema.DiscountPercentageDomain AS DECIMAL(3, 2)
    CHECK (VALUE >= 0 AND VALUE <= 100);  -- Процент скидки от 0 до 100


-- Table Clients
CREATE TABLE hotel_schema.Clients (
    client_id INT PRIMARY KEY AUTO_INCREMENT,  -- Primary key
    last_name VARCHAR(30),
    first_name VARCHAR(30),
    patronimyc VARCHAR(30),
    passport_data PassportDataDomain,
    comment TEXT
);

-- Table Rooms
CREATE TABLE hotel_schema.Rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,  -- Primary key
    room_type_id INT,  -- References Room_Types
    FOREIGN KEY (room_type_id) REFERENCES Room_Types(room_type_id)
);

-- Table Room_Types
CREATE TABLE hotel_schema.Room_Types (
    room_type_id INT PRIMARY KEY AUTO_INCREMENT,  -- Primary key
    comfort_level ComfortLevelDomain,
    price PriceDomain,
    bed_count BedCountDomain
);

-- Table Settlements
CREATE TABLE hotel_schema.Settlements (
    settlement_id INT PRIMARY KEY AUTO_INCREMENT,  -- Primary key
    client_id INT,  -- References Clients
    room_id INT,    -- References Rooms
    check_in_date DATE,
    check_out_date DATE,
    note TEXT,
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    CHECK (check_out_date > check_in_date)  -- Проверка, что дата выезда больше даты заселения
);

-- Table Bookings
CREATE TABLE hotel_schema.Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,  -- Primary key
    client_id INT,  -- References Clients
    room_id INT,    -- References Rooms
    expected_check_in_date DATE,
    expected_check_out_date DATE,
    room_type_id INT,  -- References Room_Types
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (room_type_id) REFERENCES Room_Types(room_type_id),
    CHECK (expected_check_out_date > expected_check_in_date)  -- Дата выезда позже даты заселения
);

-- Table Discounts
CREATE TABLE hotel_schema.Discounts (
    discount_id INT PRIMARY KEY AUTO_INCREMENT,  -- Primary key
    discount_type VARCHAR(50),
    percentage DiscountPercentageDomain
);

-- Table ClientDiscounts
CREATE TABLE hotel_schema.ClientDiscounts (
    unique_id INT PRIMARY KEY AUTO_INCREMENT,  -- Primary key
    client_id INT,  -- References Clients
    discount_id INT,  -- References Discounts
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (discount_id) REFERENCES Discounts(discount_id)
);
