CREATE DATABASE telecom_db;
USE telecom_db;

CREATE TABLE Manager (
    ManagerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    HireDate DATE
);

CREATE TABLE Region (
    RegionID INT IDENTITY(1,1) PRIMARY KEY,
    RegionName NVARCHAR(100) NOT NULL UNIQUE,
    ManagerID INT,
    FOREIGN KEY (ManagerID) REFERENCES Manager(ManagerID) ON DELETE SET NULL
);

CREATE TABLE Manufacturer (
    ManufacturerID INT IDENTITY(1,1) PRIMARY KEY,
    ManufacturerName NVARCHAR(50) NOT NULL UNIQUE,
    Country NVARCHAR(50),
    ContactEmail NVARCHAR(100)
);

CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Role NVARCHAR(50) NOT NULL,
    HireDate DATE
);

CREATE TABLE EmployeeRegion (
    EmployeeID INT NOT NULL,
    RegionID INT NOT NULL,
    StartDate DATE,
    EndDate DATE,
    PRIMARY KEY (EmployeeID, RegionID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE,
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID) ON DELETE CASCADE
);

CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20) UNIQUE,
    DOB DATE,
    SignupDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    RegionID INT,
    Status NVARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active','Suspended','Cancelled')),
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);

CREATE TABLE Device (
    DeviceID INT IDENTITY(1,1) PRIMARY KEY,
    IMEI NVARCHAR(20) UNIQUE,
    Model NVARCHAR(100),
    ManufacturerID INT,
    PurchaseDate DATE,
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturer(ManufacturerID)
);

CREATE TABLE CustomerDevice (
    CustomerID INT NOT NULL,
    DeviceID INT NOT NULL,
    AssignedDate DATE,
    ReturnedDate DATE,
    PRIMARY KEY (CustomerID, DeviceID, AssignedDate),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (DeviceID) REFERENCES Device(DeviceID) ON DELETE CASCADE
);

CREATE TABLE [Plan] (
    PlanID INT IDENTITY(1,1) PRIMARY KEY,
    PlanName NVARCHAR(100) NOT NULL,
    PlanType NVARCHAR(20) NOT NULL CHECK (PlanType IN ('Prepaid','Postpaid','Hybrid')),
    MonthlyPrice DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    DataGB DECIMAL(6,2) DEFAULT 0.00,
    VoiceMinutes INT DEFAULT 0,
    SMS INT DEFAULT 0
);

CREATE TABLE Subscription (
    SubscriptionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    PlanID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    Status NVARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active','Paused','Cancelled')),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (PlanID) REFERENCES [Plan](PlanID) ON DELETE CASCADE
);

CREATE TABLE Promotion (
    PromotionID INT IDENTITY(1,1) PRIMARY KEY,
    PromoCode NVARCHAR(50) UNIQUE NOT NULL,
    Description NVARCHAR(255),
    DiscountPercent DECIMAL(5,2) DEFAULT 0.00,
    StartDate DATE,
    EndDate DATE
);

CREATE TABLE CustomerPromotion (
    CustomerID INT NOT NULL,
    PromotionID INT NOT NULL,
    AppliedDate DATE,
    PRIMARY KEY (CustomerID, PromotionID, AppliedDate),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (PromotionID) REFERENCES Promotion(PromotionID) ON DELETE CASCADE
);

CREATE TABLE Invoice (
    InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    SubscriptionID INT,
    InvoiceDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(20) DEFAULT 'Unpaid' CHECK (Status IN ('Unpaid','Paid','Partially Paid','Overdue')),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID) ON DELETE SET NULL
);

CREATE TABLE Payment (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Method NVARCHAR(20) DEFAULT 'Credit Card' CHECK (Method IN ('Credit Card','Bank Transfer','Cash','MobilePay')),
    FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID) ON DELETE CASCADE
);

CREATE TABLE Usage (
    UsageID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    SubscriptionID INT,
    UsageDate DATETIME NOT NULL,
    UsageType NVARCHAR(20) NOT NULL CHECK (UsageType IN ('Voice','SMS','Data')),
    Units DECIMAL(10,3) NOT NULL,
    Charge DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID) ON DELETE SET NULL
);

CREATE TABLE SupportTicket (
    TicketID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    EmployeeID INT,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Open' CHECK (Status IN ('Open','In Progress','Resolved','Closed')),
    Priority NVARCHAR(20) DEFAULT 'Medium' CHECK (Priority IN ('Low','Medium','High')),
    Subject NVARCHAR(255),
    Description NVARCHAR(MAX),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE SET NULL
);


CREATE INDEX idx_customer_region ON Customer(RegionID);
CREATE INDEX idx_device_manufacturer ON Device(ManufacturerID);
CREATE INDEX idx_region_manager ON Region(ManagerID);
CREATE INDEX idx_usage_customer_date ON Usage(CustomerID, UsageDate);
CREATE INDEX idx_invoice_date ON Invoice(InvoiceDate);
CREATE INDEX idx_payment_invoice ON Payment(InvoiceID);
CREATE INDEX idx_subscription_customer ON Subscription(CustomerID);
CREATE INDEX idx_invoice_customer_date ON Invoice(CustomerID, InvoiceDate);

-- DATA INSERTION FOR SCHEMA

INSERT INTO Manager (FirstName, LastName, Email, HireDate) VALUES
('John', 'Smith', 'j.smith@telecom.com', '2020-01-15'),
('Maria', 'Garcia', 'm.garcia@telecom.com', '2019-03-10'),
('David', 'Chen', 'd.chen@telecom.com', '2018-07-22'),
('Carlos', 'Rodriguez', 'c.rodriguez@telecom.com', '2019-06-15'),
('Sarah', 'Al-Mansouri', 's.almansouri@telecom.com', '2020-04-20'),
('Anna', 'Kowalski', 'a.kowalski@telecom.com', '2018-11-08'),
('Raj', 'Patel', 'r.patel@telecom.com', '2019-09-12'),
('Lars', 'Andersen', 'l.andersen@telecom.com', '2020-02-28');

INSERT INTO Region (RegionName, ManagerID) VALUES
('North America', 1),
('Europe', 2),
('Asia Pacific', 3),
('Latin America', 4),
('Middle East Africa', 5),
('Central Europe', 6),
('Southeast Asia', 7),
('Nordic Region', 8);

INSERT INTO Manufacturer (ManufacturerName, Country, ContactEmail) VALUES
('Apple', 'USA', 'business@apple.com'),
('Samsung', 'South Korea', 'business@samsung.com'),
('Google', 'USA', 'enterprise@google.com'),
('OnePlus', 'China', 'business@oneplus.com'),
('Xiaomi', 'China', 'global@xiaomi.com'),
('Motorola', 'USA', 'business@motorola.com'),
('Nokia', 'Finland', 'enterprise@nokia.com');

INSERT INTO Employee (FirstName, LastName, Email, Role, HireDate) VALUES
('John', 'Smith', 'j.smith@telecom.com', 'Regional Manager', '2020-01-15'),
('Maria', 'Garcia', 'm.garcia@telecom.com', 'Regional Manager', '2019-03-10'),
('David', 'Chen', 'd.chen@telecom.com', 'Regional Manager', '2018-07-22'),
('Sarah', 'Johnson', 's.johnson@telecom.com', 'Customer Service', '2021-02-20'),
('Mike', 'Williams', 'm.williams@telecom.com', 'Customer Service', '2020-11-05'),
('Lisa', 'Brown', 'l.brown@telecom.com', 'Customer Service', '2021-06-18'),
('Tom', 'Davis', 't.davis@telecom.com', 'Customer Service', '2022-01-10'),
('Emma', 'Wilson', 'e.wilson@telecom.com', 'Technical Support', '2020-08-12'),
('Alex', 'Moore', 'a.moore@telecom.com', 'Technical Support', '2021-04-03'),
('Sophia', 'Taylor', 's.taylor@telecom.com', 'Technical Support', '2021-09-15'),
('James', 'Anderson', 'j.anderson@telecom.com', 'Sales Representative', '2019-12-01'),
('Jennifer', 'Thomas', 'j.thomas@telecom.com', 'Sales Representative', '2020-05-20'),
('Robert', 'Jackson', 'r.jackson@telecom.com', 'Sales Representative', '2021-01-25'),
('Michelle', 'White', 'm.white@telecom.com', 'Billing Specialist', '2020-10-08'),
('Kevin', 'Harris', 'k.harris@telecom.com', 'Billing Specialist', '2021-03-12');

INSERT INTO EmployeeRegion (EmployeeID, RegionID, StartDate, EndDate) VALUES
(1, 1, '2020-01-15', NULL),
(2, 2, '2019-03-10', NULL),
(3, 3, '2018-07-22', NULL),
(4, 1, '2021-02-20', NULL),
(5, 1, '2020-11-05', NULL),
(6, 2, '2021-06-18', NULL),
(7, 2, '2022-01-10', NULL),
(8, 3, '2020-08-12', NULL),
(9, 3, '2021-04-03', NULL),
(10, 1, '2021-09-15', NULL),
(11, 2, '2019-12-01', NULL),
(12, 3, '2020-05-20', NULL),
(13, 1, '2021-01-25', NULL),
(14, 1, '2020-10-08', NULL),
(14, 2, '2021-06-01', NULL),
(15, 2, '2021-03-12', NULL),
(15, 3, '2021-08-01', NULL);

INSERT INTO [Plan] (PlanName, PlanType, MonthlyPrice, DataGB, VoiceMinutes, SMS) VALUES
('Basic Prepaid', 'Prepaid', 15.00, 1.00, 100, 100),
('Standard Prepaid', 'Prepaid', 25.00, 3.00, 300, 300),
('Premium Prepaid', 'Prepaid', 35.00, 8.00, 500, 500),
('Starter Postpaid', 'Postpaid', 30.00, 5.00, 500, 1000),
('Family Postpaid', 'Postpaid', 60.00, 20.00, 1000, 2000),
('Business Postpaid', 'Postpaid', 80.00, 50.00, 1500, 3000),
('Unlimited Postpaid', 'Postpaid', 90.00, 999.99, 9999, 9999),
('Flex Hybrid', 'Hybrid', 40.00, 10.00, 800, 1500),
('Smart Hybrid', 'Hybrid', 55.00, 25.00, 1200, 2500);

INSERT INTO Device (IMEI, Model, ManufacturerID, PurchaseDate) VALUES
('123456789012345', 'iPhone 14', 1, '2023-01-15'),
('123456789012346', 'iPhone 13', 1, '2022-10-20'),
('123456789012347', 'iPhone 14 Pro', 1, '2023-02-10'),
('123456789012348', 'iPhone 12', 1, '2022-08-05'),
('223456789012345', 'Galaxy S23', 2, '2023-03-12'),
('223456789012346', 'Galaxy S22', 2, '2022-11-18'),
('223456789012347', 'Galaxy Note 20', 2, '2022-07-25'),
('223456789012348', 'Galaxy A54', 2, '2023-04-08'),
('323456789012345', 'Pixel 7', 3, '2022-12-03'),
('323456789012346', 'Pixel 6a', 3, '2022-09-15'),
('423456789012345', 'OnePlus 11', 4, '2023-01-20'),
('423456789012346', 'OnePlus 10T', 4, '2022-08-30'),
('523456789012345', 'Mi 13', 5, '2023-02-28'),
('523456789012346', 'Redmi Note 12', 5, '2022-12-10'),
('623456789012345', 'Moto G Power', 6, '2022-06-12'),
('623456789012346', 'Nokia G50', 7, '2022-05-20');


INSERT INTO Customer (FirstName, LastName, Email, Phone, DOB, SignupDate, RegionID, Status) VALUES
('Alice', 'Cooper', 'alice.cooper@email.com', '+1-555-0001', '1985-03-15', '2022-01-10', 1, 'Active'),
('Bob', 'Dylan', 'bob.dylan@email.com', '+1-555-0002', '1978-12-22', '2021-11-20', 1, 'Active'),
('Charlie', 'Parker', 'charlie.parker@email.com', '+1-555-0003', '1992-07-08', '2022-03-05', 1, 'Active'),
('Diana', 'Ross', 'diana.ross@email.com', '+1-555-0004', '1988-09-14', '2021-08-15', 1, 'Suspended'),
('Frank', 'Sinatra', 'frank.sinatra@email.com', '+1-555-0005', '1995-01-30', '2022-06-12', 1, 'Active'),

('George', 'Harrison', 'george.harrison@email.com', '+44-555-0001', '1987-11-25', '2021-09-18', 2, 'Active'),
('Helen', 'Mirren', 'helen.mirren@email.com', '+44-555-0002', '1983-04-12', '2022-02-28', 2, 'Active'),
('Ivan', 'Petrov', 'ivan.petrov@email.com', '+49-555-0001', '1990-06-03', '2021-12-08', 2, 'Active'),
('Julia', 'Schmidt', 'julia.schmidt@email.com', '+49-555-0002', '1986-10-17', '2022-04-22', 2, 'Cancelled'),
('Klaus', 'Mueller', 'klaus.mueller@email.com', '+49-555-0003', '1991-02-09', '2022-01-15', 2, 'Active'),

('Li', 'Wei', 'li.wei@email.com', '+86-555-0001', '1989-08-20', '2021-10-10', 3, 'Active'),
('Yuki', 'Tanaka', 'yuki.tanaka@email.com', '+81-555-0001', '1993-12-05', '2022-03-18', 3, 'Active'),
('Raj', 'Sharma', 'raj.sharma@email.com', '+91-555-0001', '1984-05-28', '2021-07-25', 3, 'Active'),
('Priya', 'Patel', 'priya.patel@email.com', '+91-555-0002', '1990-09-12', '2022-05-08', 3, 'Active'),
('Chen', 'Ming', 'chen.ming@email.com', '+86-555-0002', '1987-01-18', '2021-11-30', 3, 'Suspended'),

('Mark', 'Johnson', 'mark.johnson@email.com', '+1-555-0006', '1982-04-25', '2020-12-15', 1, 'Active'),
('Emma', 'Davis', 'emma.davis@email.com', '+1-555-0007', '1994-08-10', '2023-01-20', 1, 'Active'),
('Lucas', 'Miller', 'lucas.miller@email.com', '+44-555-0003', '1989-11-07', '2021-05-12', 2, 'Active'),
('Sofia', 'Lopez', 'sofia.lopez@email.com', '+34-555-0001', '1991-03-22', '2022-07-18', 2, 'Active'),
('Ahmed', 'Hassan', 'ahmed.hassan@email.com', '+20-555-0001', '1986-09-15', '2021-08-05', 5, 'Active');

INSERT INTO Customer (FirstName, LastName, Email, Phone, DOB, SignupDate, RegionID, Status)
VALUES
('Ali', 'Hassan', 'ali.hassan@email.com', '1111111', '1990-05-12', '2024-01-10', NULL, 'Active'),
('Sara', 'Khan', 'sara.khan@email.com', '2222222', '1995-08-25', '2024-02-15', NULL, 'Active'),
('Omar', 'Saleh', 'omar.saleh@email.com', '3333333', '1987-12-02', '2024-03-20', NULL, 'Active');


INSERT INTO CustomerDevice (CustomerID, DeviceID, AssignedDate, ReturnedDate) VALUES
(1, 1, '2023-01-15', NULL),
(2, 5, '2023-03-12', NULL),
(3, 9, '2022-12-03', NULL),
(4, 2, '2022-10-20', NULL),
(5, 11, '2023-01-20', NULL),

(6, 3, '2023-02-10', NULL),
(7, 6, '2022-11-18', NULL),
(8, 13, '2023-02-28', NULL),
(10, 8, '2023-04-08', NULL),

(11, 4, '2022-08-05', NULL),
(12, 7, '2022-07-25', NULL),
(13, 10, '2022-09-15', NULL),
(14, 12, '2022-08-30', NULL),
(15, 14, '2022-12-10', NULL),

(1, 15, '2022-06-12', '2023-01-14'),
(2, 16, '2022-05-20', '2023-03-11'),
(16, 15, '2022-06-12', NULL),
(17, 16, '2022-05-20', NULL);


INSERT INTO Subscription (CustomerID, PlanID, StartDate, EndDate, Status) VALUES
(1, 7, '2022-01-10', NULL, 'Active'), 
(2, 6, '2021-11-20', NULL, 'Active'), 
(3, 5, '2022-03-05', NULL, 'Active'),
(4, 4, '2021-08-15', '2023-02-15', 'Cancelled'),
(5, 8, '2022-06-12', NULL, 'Active'), 

(6, 9, '2021-09-18', NULL, 'Active'), 
(7, 5, '2022-02-28', NULL, 'Active'), 
(8, 4, '2021-12-08', NULL, 'Active'), 
(9, 2, '2022-04-22', '2022-10-22', 'Cancelled'), 
(10, 6, '2022-01-15', NULL, 'Active'),

(11, 7, '2021-10-10', NULL, 'Active'),
(12, 3, '2022-03-18', NULL, 'Active'), 
(13, 4, '2021-07-25', NULL, 'Active'), 
(14, 8, '2022-05-08', NULL, 'Active'), 
(15, 1, '2021-11-30', '2022-05-30', 'Paused'), 

(16, 5, '2020-12-15', NULL, 'Active'), 
(17, 2, '2023-01-20', NULL, 'Active'), 
(18, 6, '2021-05-12', NULL, 'Active'), 
(19, 4, '2022-07-18', NULL, 'Active'), 
(20, 7, '2021-08-05', NULL, 'Active');

INSERT INTO Subscription (CustomerID, PlanID, StartDate, EndDate, Status) VALUES
(1, 4, '2022-01-10', '2022-06-10', 'Cancelled'), 
(5, 1, '2022-06-12', '2022-12-12', 'Cancelled'); 


INSERT INTO Promotion (PromoCode, Description, DiscountPercent, StartDate, EndDate) VALUES
('WELCOME20', '20% off first 3 months for new customers', 20.00, '2022-01-01', '2022-12-31'),
('STUDENT15', '15% discount for students', 15.00, '2021-09-01', '2023-08-31'),
('FAMILY25', '25% off Family plans', 25.00, '2022-06-01', '2022-12-31'),
('BLACKFRI30', 'Black Friday 30% off all plans', 30.00, '2022-11-25', '2022-11-28'),
('SUMMER10', 'Summer promotion 10% off', 10.00, '2022-06-21', '2022-09-21'),
('LOYALTY12', '12% loyalty discount for 2+ year customers', 12.00, '2022-01-01', '2023-12-31'),
('NEWPLAN20', '20% off when switching to postpaid', 20.00, '2022-03-01', '2022-09-30'),
('REFER15', '15% referral bonus', 15.00, '2022-01-01', '2023-12-31');


INSERT INTO CustomerPromotion (CustomerID, PromotionID, AppliedDate) VALUES
(1, 1, '2022-01-10'), 
(16, 1, '2020-12-15'), 
(17, 1, '2023-01-20'), 

(3, 2, '2022-03-05'), 
(12, 2, '2022-03-18'),

(2, 3, '2021-11-20'),
(7, 3, '2022-02-28'), 
(16, 3, '2020-12-15'), 

(5, 4, '2022-11-25'), 
(6, 4, '2022-11-25'), 
(10, 4, '2022-11-25'), 

(11, 5, '2022-06-21'),
(13, 5, '2022-06-21'), 

(2, 6, '2022-01-01'),
(16, 6, '2022-01-01'), 

(1, 7, '2022-06-10'), 
(18, 7, '2021-05-12'); 


INSERT INTO Invoice (CustomerID, SubscriptionID, InvoiceDate, DueDate, Amount, Status) VALUES
(1, 1, '2023-01-01', '2023-01-31', 90.00, 'Paid'),
(2, 2, '2023-01-01', '2023-01-31', 80.00, 'Paid'),
(3, 3, '2023-01-05', '2023-02-04', 60.00, 'Paid'),
(5, 5, '2023-01-12', '2023-02-11', 40.00, 'Overdue'),

(1, 1, '2023-02-01', '2023-03-03', 90.00, 'Paid'),
(2, 2, '2023-02-01', '2023-03-03', 80.00, 'Partially Paid'),
(3, 3, '2023-02-05', '2023-03-07', 60.00, 'Unpaid'),

(6, 6, '2023-01-18', '2023-02-17', 55.00, 'Paid'),
(7, 7, '2023-02-28', '2023-03-30', 60.00, 'Paid'),
(8, 8, '2023-01-08', '2023-02-07', 30.00, 'Paid'),
(10, 10, '2023-01-15', '2023-02-14', 80.00, 'Paid'),
(11, 11, '2023-01-10', '2023-02-09', 90.00, 'Paid'),
(13, 13, '2023-01-25', '2023-02-24', 30.00, 'Paid'),
(14, 14, '2023-01-08', '2023-02-07', 40.00, 'Overdue');

INSERT INTO Invoice (CustomerID, SubscriptionID, InvoiceDate, DueDate, Amount, Status)
VALUES
(1, NULL, '2024-09-05', '2024-09-20', 100.00, 'Paid'),
(1, NULL, '2024-10-05', '2024-10-20', 120.00, 'Overdue'),
(1, NULL, '2024-11-05', '2024-11-20', 110.00, 'Paid'),
(2, NULL, '2024-09-10', '2024-09-25', 150.00, 'Paid'),
(2, NULL, '2024-11-12', '2024-11-27', 160.00, 'Unpaid'),
(3, NULL, '2024-12-01', '2024-12-15', 90.00, 'Paid'),
(3, NULL, '2025-01-05', '2025-01-20', 200.00, 'Paid'),
(3, NULL, '2025-02-07', '2025-02-22', 180.00, 'Paid'),
(2, NULL, '2025-03-10', '2025-03-25', 210.00, 'Paid'),
(1, NULL, '2025-04-15', '2025-04-30', 130.00, 'Unpaid'),
(2, NULL, '2025-05-18', '2025-06-02', 175.00, 'Paid'),
(3, NULL, '2025-06-20', '2025-07-05', 220.00, 'Paid'),
(1, NULL, '2025-07-08', '2025-07-23', 140.00, 'Paid'),
(2, NULL, '2025-08-15', '2025-08-30', 190.00, 'Overdue'),
(3, NULL, '2025-09-02', '2025-09-17', 160.00, 'Paid');



INSERT INTO Payment (InvoiceID, PaymentDate, Amount, Method) VALUES
(1, '2023-01-28', 90.00, 'Credit Card'),
(2, '2023-01-30', 80.00, 'Bank Transfer'),
(3, '2023-01-31', 60.00, 'Credit Card'),
(5, '2023-02-25', 90.00, 'Credit Card'),
(6, '2023-03-01', 40.00, 'Bank Transfer'), 

(8, '2023-02-15', 55.00, 'Credit Card'),
(9, '2023-03-25', 60.00, 'MobilePay'),
(10, '2023-02-05', 30.00, 'Credit Card'),
(11, '2023-02-12', 80.00, 'Bank Transfer'),
(12, '2023-02-08', 90.00, 'Credit Card'),
(13, '2023-02-22', 30.00, 'MobilePay'),

(6, '2023-02-15', 20.00, 'Credit Card'),
(6, '2023-02-20', 20.00, 'Cash');


INSERT INTO Usage (CustomerID, SubscriptionID, UsageDate, UsageType, Units, Charge) VALUES
(1, 1, '2023-01-05 09:15:00', 'Voice', 45.5, 0.00),
(1, 1, '2023-01-05 14:30:00', 'Data', 1.2, 0.00),
(1, 1, '2023-01-05 18:45:00', 'SMS', 15, 0.00),

(2, 2, '2023-01-03 08:30:00', 'Voice', 25.5, 0.00),
(2, 2, '2023-01-03 11:45:00', 'Data', 2.1, 0.00),
(2, 2, '2023-01-08 09:15:00', 'SMS', 45, 0.00),

(5, 5, '2023-01-06 10:30:00', 'Voice', 65.5, 0.00),
(5, 5, '2023-01-12 14:15:00', 'Voice', 125.8, 2.15), 
(5, 5, '2023-01-18 11:20:00', 'Data', 3.5, 1.25), 

(12, 12, '2023-01-07 13:20:00', 'Voice', 25.5, 2.55),
(12, 12, '2023-01-07 17:35:00', 'Data', 0.5, 0.50),
(12, 12, '2023-01-12 09:45:00', 'SMS', 20, 0.40),

(11, 11, '2023-01-12 05:20:00', 'Voice', 65.8, 0.00),
(13, 13, '2023-01-15 12:40:00', 'Voice', 45.2, 0.00),
(14, 14, '2023-01-20 14:25:00', 'Voice', 55.7, 0.00);

INSERT INTO Usage (CustomerID, SubscriptionID, UsageDate, UsageType, Units, Charge)
VALUES
(1, NULL, '2024-09-06', 'Data', 5.5, 20.00),
(1, NULL, '2024-09-07', 'Voice', 30, 10.00),
(1, NULL, '2024-10-10', 'Data', 6.0, 25.00),
(2, NULL, '2024-09-12', 'SMS', 50, 5.00),
(2, NULL, '2024-11-15', 'Data', 8.0, 30.00),
(3, NULL, '2024-12-03', 'Voice', 45, 15.00),
(3, NULL, '2025-01-08', 'Data', 10.0, 40.00),
(3, NULL, '2025-02-09', 'Data', 12.0, 50.00),
(2, NULL, '2025-03-14', 'Voice', 60, 20.00),
(1, NULL, '2025-04-16', 'Data', 7.0, 28.00),
(2, NULL, '2025-05-20', 'SMS', 80, 8.00),
(3, NULL, '2025-06-22', 'Data', 15.0, 60.00),
(1, NULL, '2025-07-10', 'Voice', 35, 12.00),
(2, NULL, '2025-08-18', 'Data', 9.0, 36.00),
(3, NULL, '2025-09-03', 'Data', 11.0, 44.00);



INSERT INTO SupportTicket (CustomerID, EmployeeID, CreatedDate, Status, Priority, Subject, Description) VALUES

(1, 4, '2023-02-15 09:30:00', 'Resolved', 'Medium', 'Billing inquiry', 'Customer asking about charges on last invoice'),
(2, 5, '2023-02-20 14:15:00', 'Closed', 'Low', 'Plan upgrade request', 'Customer wants to upgrade to unlimited plan'),
(3, 6, '2023-02-25 11:45:00', 'Open', 'High', 'No service in area', 'Customer reports no signal in downtown area since yesterday'),

(5, 8, '2023-02-18 10:30:00', 'In Progress', 'High', 'Data connectivity issues', 'Customer cannot access mobile data for past 2 days'),
(6, 9, '2023-02-22 13:45:00', 'Open', 'Medium', 'Call quality problems', 'Experiencing dropped calls and poor voice quality'),

(8, 14, '2023-01-25 12:10:00', 'Closed', 'Medium', 'Payment not processed', 'Automatic payment failed, need to update card'),
(10, 15, '2023-02-12 09:15:00', 'Resolved', 'Low', 'Invoice clarification', 'Questions about promotion discount application'),

(11, 9, '2023-02-05 07:30:00', 'Resolved', 'Medium', 'Roaming charges', 'Unexpected charges while traveling to Europe'),
(13, 8, '2023-02-14 11:25:00', 'Open', 'High', 'Service outage', 'Complete service outage in customer area'),

(2, 8, '2023-03-01 08:15:00', 'Open', 'High', 'Business line down', 'Critical business line not functioning'),
(18, 9, '2023-02-28 17:20:00', 'In Progress', 'High', 'Security concern', 'Suspicious activity on account');


-- View 1: Revenue Summary by Region (Summary/Aggregation)
CREATE VIEW vw_RegionRevenueSummary AS
SELECT 
    r.RegionName,
    CONCAT(m.FirstName, ' ', m.LastName) as ManagerName,
    COUNT(DISTINCT c.CustomerID) as TotalCustomers,
    COUNT(DISTINCT s.SubscriptionID) as ActiveSubscriptions,
    COALESCE(SUM(i.Amount), 0) as TotalRevenue,
    COALESCE(AVG(i.Amount), 0) as AvgInvoiceAmount,
    COUNT(DISTINCT st.TicketID) as SupportTickets
FROM Region r
LEFT JOIN Manager m ON r.ManagerID = m.ManagerID
LEFT JOIN Customer c ON r.RegionID = c.RegionID AND c.Status = 'Active'
LEFT JOIN Subscription s ON c.CustomerID = s.CustomerID AND s.Status = 'Active'
LEFT JOIN Invoice i ON c.CustomerID = i.CustomerID
LEFT JOIN SupportTicket st ON c.CustomerID = st.CustomerID
GROUP BY r.RegionID, r.RegionName, m.FirstName, m.LastName;

SELECT * FROM vw_RegionRevenueSummary ORDER BY TotalRevenue DESC;


-- View 2: Monthly Usage and Revenue Trends (Performance/Trend)
CREATE VIEW vw_MonthlyTrends AS
SELECT 
    YEAR(i.InvoiceDate) as Year,
    MONTH(i.InvoiceDate) as Month,
    DATENAME(MONTH, i.InvoiceDate) as MonthName,
    COUNT(DISTINCT i.CustomerID) as UniqueCustomers,
    SUM(i.Amount) as TotalRevenue,
    AVG(i.Amount) as AvgRevenue,
    SUM(CASE WHEN i.Status = 'Paid' THEN i.Amount ELSE 0 END) as PaidRevenue,
    SUM(CASE WHEN i.Status IN ('Overdue', 'Unpaid') THEN i.Amount ELSE 0 END) as OutstandingRevenue,
    ROUND(
        SUM(CASE WHEN i.Status = 'Paid' THEN i.Amount ELSE 0 END) * 100.0 / SUM(i.Amount), 
        2
    ) as PaymentRate,
    -- Usage aggregations
    COALESCE(SUM(u.Units), 0) as TotalUsageUnits,
    COALESCE(SUM(u.Charge), 0) as UsageCharges
FROM Invoice i
LEFT JOIN Usage u ON i.CustomerID = u.CustomerID 
    AND YEAR(i.InvoiceDate) = YEAR(u.UsageDate) 
    AND MONTH(i.InvoiceDate) = MONTH(u.UsageDate)
WHERE i.InvoiceDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), DATENAME(MONTH, i.InvoiceDate);

SELECT * FROM vw_MonthlyTrends ORDER BY Year DESC, Month DESC;

-----------------------------------------------------------------------
-- Who are the top 5 customers generating the most revenue from invoices?

SELECT 
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    SUM(i.Amount) AS TotalRevenue,
    RANK() OVER (ORDER BY SUM(i.Amount) DESC) AS RevenueRank
FROM Customer c
JOIN Invoice i ON c.CustomerID = i.CustomerID
WHERE i.Status IN ('Paid','Partially Paid')
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalRevenue DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- Which regions have an average invoice amount greater than 50 EUR?

SELECT 
    r.RegionName,
    AVG(i.Amount) AS AvgInvoiceAmount
FROM Region r
JOIN Customer c ON r.RegionID = c.RegionID
JOIN Invoice i ON c.CustomerID = i.CustomerID
GROUP BY r.RegionName
HAVING AVG(i.Amount) > 50;


-- Which customers show risk of churn based on subscription status and overdue invoices?

SELECT 
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    CASE 
        WHEN c.Status = 'Cancelled' THEN 'High Risk'
        WHEN EXISTS (
            SELECT 1 
            FROM Invoice i 
            WHERE i.CustomerID = c.CustomerID 
              AND i.Status = 'Overdue'
        ) THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS ChurnRisk
FROM Customer c;

-- Which subscription plans are most popular (highest number of active customers)?

SELECT 
    p.PlanName,
    p.PlanType,
    COUNT(s.SubscriptionID) AS ActiveSubscriptions,
    DENSE_RANK() OVER (ORDER BY COUNT(s.SubscriptionID) DESC) AS PopularityRank
FROM [Plan] p
JOIN Subscription s ON p.PlanID = s.PlanID
WHERE s.Status = 'Active'
GROUP BY p.PlanName, p.PlanType
ORDER BY ActiveSubscriptions DESC;

-- What are the monthly data usage trends per customer?

SELECT 
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    FORMAT(u.UsageDate, 'yyyy-MM') AS Month,
    SUM(CASE WHEN u.UsageType = 'Data' THEN u.Units ELSE 0 END) AS TotalDataGB,
    LAG(SUM(CASE WHEN u.UsageType = 'Data' THEN u.Units ELSE 0 END)) 
        OVER (PARTITION BY c.CustomerID ORDER BY FORMAT(u.UsageDate, 'yyyy-MM')) AS PrevMonthUsage,
    (SUM(CASE WHEN u.UsageType = 'Data' THEN u.Units ELSE 0 END) -
     LAG(SUM(CASE WHEN u.UsageType = 'Data' THEN u.Units ELSE 0 END)) 
        OVER (PARTITION BY c.CustomerID ORDER BY FORMAT(u.UsageDate, 'yyyy-MM'))) AS UsageChange
FROM Customer c
JOIN Usage u ON c.CustomerID = u.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, FORMAT(u.UsageDate, 'yyyy-MM')
ORDER BY c.CustomerID, Month;


-- OPTIMIZED QUERY:
SELECT 
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    DATEFROMPARTS(YEAR(u.UsageDate), MONTH(u.UsageDate), 1) AS MonthStart,
    SUM(CASE WHEN u.UsageType = 'Data' THEN u.Units ELSE 0 END) AS TotalDataGB,
    LAG(SUM(CASE WHEN u.UsageType = 'Data' THEN u.Units ELSE 0 END)) 
        OVER (PARTITION BY c.CustomerID ORDER BY DATEFROMPARTS(YEAR(u.UsageDate), MONTH(u.UsageDate), 1)) AS PrevMonthUsage
FROM Customer c
JOIN Usage u ON c.CustomerID = u.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, DATEFROMPARTS(YEAR(u.UsageDate), MONTH(u.UsageDate), 1)
ORDER BY c.CustomerID, MonthStart;


