CREATE DATABASE UTGameNet;

USE UTGameNet;

CREATE TABLE Customer (
    cid CHAR(30) PRIMARY KEY,
    name CHAR(50),
    contact_info CHAR(225)
);

CREATE TABLE StudentCustomer (
    cid CHAR(30) PRIMARY KEY,
    sid CHAR(30),
    university_name CHAR(50),
    FOREIGN KEY (cid) REFERENCES Customer(cid)
);

CREATE TABLE VOUCHER (
    vid CHAR(30) PRIMARY KEY,
    percent FLOAT,
    limit_amount DOUBLE,
    is_used BOOLEAN
);

CREATE TABLE StudentCustomerVoucher (
    cid CHAR(30),
    vid CHAR(30),
    PRIMARY KEY (cid, vid),
    FOREIGN KEY (cid) REFERENCES StudentCustomer(cid),
    FOREIGN KEY (vid) REFERENCES VOUCHER(vid)
);

CREATE TABLE Admin (
    aid CHAR(30) PRIMARY KEY ,
    name CHAR(50),
    salary DOUBLE,
    role CHAR(50)
);

CREATE TABLE BoardGame (
    bid CHAR(30) PRIMARY KEY,
    title CHAR(50),
    publisher CHAR(50)
);

CREATE TABLE Version (
    version_id CHAR(30) PRIMARY KEY
);

CREATE TABLE BoardGamePhysical (
    bid CHAR(30),
    version_id CHAR(30),
    release_date DATE,
    price DOUBLE,
    PRIMARY KEY (bid, version_id),
    FOREIGN KEY (bid) REFERENCES BoardGame(bid),
    FOREIGN KEY (version_id) REFERENCES Version(version_id)
);

CREATE TABLE BoardGameDigital (
    bid CHAR(30),
    version_id CHAR(30),
    release_date DATE,
    price DOUBLE,
    PRIMARY KEY (bid, version_id),
    FOREIGN KEY (bid) REFERENCES BoardGame(bid),
    FOREIGN KEY (version_id) REFERENCES Version(version_id)
);

CREATE TABLE AcceptanceDigital (
    bid CHAR(30),
    version_id CHAR(30),
    aid CHAR(30),
    PRIMARY KEY (bid, version_id, aid),
    FOREIGN KEY (aid) REFERENCES Admin(aid),
    FOREIGN KEY (bid, version_id) REFERENCES BoardGameDigital(bid, version_id)
);

CREATE TABLE AcceptancePhysical (
    bid CHAR(30),
    version_id CHAR(30),
    aid CHAR(30),
    PRIMARY KEY (bid, version_id, aid),
    FOREIGN KEY (aid) REFERENCES Admin(aid),
    FOREIGN KEY (bid, version_id) REFERENCES BoardGamePhysical(bid, version_id)
);

CREATE TABLE RateDigital (
    bid CHAR(30),
    version_id CHAR(30),
    cid CHAR(30),
    PRIMARY KEY (bid, version_id, cid),
    FOREIGN KEY (bid, version_id) REFERENCES BoardGameDigital(bid, version_id),
    FOREIGN KEY (cid) REFERENCES Customer(cid)
);

CREATE TABLE RatePhysical (
    bid CHAR(30),
    version_id CHAR(30),
    cid CHAR(30),
    PRIMARY KEY (bid, version_id, cid),
    FOREIGN KEY (bid, version_id) REFERENCES BoardGamePhysical(bid, version_id),
    FOREIGN KEY (cid) REFERENCES Customer(cid)
);

CREATE table DownloadDate (
    date_time DATE,
    PRIMARY KEY (date_time)
);

CREATE TABLE Download (
    cid CHAR(30),
    bid CHAR(30),
    version_id CHAR(30),
    date_time DATE,
    PRIMARY KEY (cid, bid, version_id, date_time),
    FOREIGN KEY (cid) REFERENCES Customer(cid),
    FOREIGN KEY (bid, version_id) REFERENCES BoardGameDigital(bid, version_id),
    FOREIGN KEY (date_time) REFERENCES DownloadDate(date_time)
);

CREATE TABLE Courier (
    courier_id CHAR(30) PRIMARY KEY,
    name CHAR(50),
    contact_info CHAR(225),
    commission DOUBLE
);

CREATE TABLE `Order` (
    oid CHAR(30),
    cid CHAR(30),
    total_cost DOUBLE,
    PRIMARY KEY (oid, cid),
    FOREIGN KEY (cid) REFERENCES Customer(cid) ON DELETE CASCADE
);

CREATE TABLE OrderItem (
    oid CHAR(30),
    cid CHAR(30),
    bid CHAR(30),
    version_id CHAR(30),
    PRIMARY KEY (oid, cid, bid, version_id),
    FOREIGN KEY (oid, cid) REFERENCES `Order`(oid, cid),
    FOREIGN KEY (bid, version_id) REFERENCES BoardGamePhysical(bid, version_id)
);

CREATE TABLE Delivery (
    courier_id CHAR(30),
    oid CHAR(30),
    cid CHAR(30),
    cost DOUBLE,
    delivery_date DATE,
    PRIMARY KEY (courier_id, oid, cid),
    FOREIGN KEY (oid, cid) REFERENCES `Order`(oid, cid),
    FOREIGN KEY (courier_id) REFERENCES Courier(courier_id)
);
