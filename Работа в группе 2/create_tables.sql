-- Создание табличного пространства
CREATE TABLESPACE hotel_tablespace 
LOCATION 'D:\postgres\hotel';


-- Создание базы данных в табличном пространстве
CREATE DATABASE hotel_database 
WITH TABLESPACE = hotel_tablespace;

-- Создание схемы
CREATE SCHEMA hotel_schema;

-- Домены для ограничения данных
CREATE DOMAIN hotel_schema.PassportDataDomain AS VARCHAR(10)
    CHECK (VALUE ~ '^\d{10}');  -- Ограничение: только цифры, длина 10 символов

CREATE DOMAIN hotel_schema.ComfortLevelDomain AS VARCHAR(8)
    CHECK (VALUE IN ('Basic', 'Standard', 'Deluxe', 'Suite'));  -- Доступные уровни комфорта

CREATE DOMAIN hotel_schema.PriceDomain AS DECIMAL(10, 2)
    CHECK (VALUE > 0);  -- Цена должна быть больше 0

CREATE DOMAIN hotel_schema.BedCountDomain AS DECIMAL
    CHECK (VALUE >= 1 AND VALUE <= 4);  -- Количество кроватей от 1 до 4

CREATE DOMAIN hotel_schema.DiscountPercentageDomain AS DECIMAL(5, 2)
    CHECK (VALUE >= 0 AND VALUE <= 100);  -- Процент скидки от 0 до 100


-- Table Clients
CREATE TABLE hotel_schema.Clients (
    client_id SERIAL PRIMARY KEY,  -- Primary key
    last_name VARCHAR(30),
    first_name VARCHAR(30),
    patronimyc VARCHAR(30),
    passport_data hotel_schema.PassportDataDomain,
    comment TEXT
);

-- Table Rooms
CREATE TABLE hotel_schema.Rooms (
    room_id SERIAL PRIMARY KEY,  -- Primary key
    room_type_id INT,  -- References Room_Types
    FOREIGN KEY (room_type_id) REFERENCES hotel_schema.Room_Types(room_type_id)
        ON DELETE RESTRICT  -- Запрещает удаление типа комнаты, если есть связанные номера
        ON UPDATE CASCADE   -- Обновление room_type_id в номерах при изменении в Room_Types
);

-- Table Room_Types
CREATE TABLE hotel_schema.Room_Types (
    room_type_id SERIAL PRIMARY KEY,  -- Primary key
    comfort_level hotel_schema.ComfortLevelDomain,
    price hotel_schema.PriceDomain,
    bed_count hotel_schema.BedCountDomain
);

-- Table Settlements
CREATE TABLE hotel_schema.Settlements (
    settlement_id SERIAL PRIMARY KEY,  -- Primary key
    client_id INT,  -- References Clients
    room_id INT,    -- References Rooms
    check_in_date DATE,
    check_out_date DATE,
    note TEXT,
    FOREIGN KEY (client_id) REFERENCES hotel_schema.Clients(client_id)
        ON DELETE CASCADE  -- Удаление клиента приводит к удалению всех его записей о заселении
        ON UPDATE CASCADE,
    FOREIGN KEY (room_id) REFERENCES hotel_schema.Rooms(room_id)
        ON DELETE SET NULL  -- При удалении номера, поле room_id в этой таблице становится NULL
        ON UPDATE CASCADE,
    CHECK (check_out_date > check_in_date)  -- Проверка, что дата выезда больше даты заселения
);

-- Table Bookings
CREATE TABLE hotel_schema.Bookings (
    booking_id SERIAL PRIMARY KEY,  -- Primary key
    client_id INT,  -- References Clients
    room_id INT,    -- References Rooms
    expected_check_in_date DATE,
    expected_check_out_date DATE,
    room_type_id INT,  -- References Room_Types
    FOREIGN KEY (client_id) REFERENCES hotel_schema.Clients(client_id)
        ON DELETE CASCADE  -- Удаление клиента приводит к удалению всех его бронирований
        ON UPDATE CASCADE,
    FOREIGN KEY (room_id) REFERENCES hotel_schema.Rooms(room_id)
        ON DELETE SET NULL  -- При удалении номера, поле room_id в бронированиях становится NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (room_type_id) REFERENCES hotel_schema.Room_Types(room_type_id)
        ON DELETE RESTRICT  -- Нельзя удалить тип комнаты, если он используется в бронированиях
        ON UPDATE CASCADE,
    CHECK (expected_check_out_date > expected_check_in_date)  -- Дата выезда позже даты заселения
);

-- Table Discounts
CREATE TABLE hotel_schema.Discounts (
    discount_id SERIAL PRIMARY KEY,  -- Primary key
    discount_type VARCHAR(50),
    percentage hotel_schema.DiscountPercentageDomain
);

-- Table ClientDiscounts
CREATE TABLE hotel_schema.ClientDiscounts (
    unique_id SERIAL PRIMARY KEY,  -- Primary key
    client_id INT,  -- References Clients
    discount_id INT,  -- References Discounts
    FOREIGN KEY (client_id) REFERENCES hotel_schema.Clients(client_id)
        ON DELETE CASCADE  -- Удаление клиента приводит к удалению всех его скидок
        ON UPDATE CASCADE,
    FOREIGN KEY (discount_id) REFERENCES hotel_schema.Discounts(discount_id)
        ON DELETE SET NULL  -- При удалении скидки поле discount_id становится NULL
        ON UPDATE CASCADE
);

