

CREATE TABLE Dim_Author (
    Author_SK INT PRIMARY KEY IDENTITY(1,1),
    Author_BK INT,
    SSC INT
);

CREATE TABLE Dim_Book (
    Book_SK INT PRIMARY KEY IDENTITY(1,1),
    Book_BK INT,
    Title VARCHAR(255),
    isbn13 VARCHAR(20),
    Language_BK INT,
    Num_Pages INT,
    Publication_date DATE,
    Publisher_BK INT,
    Publisher_name VARCHAR(255),
    Language_code VARCHAR(10),
    Language_name VARCHAR(50),
    SSC INT
);

-- Bridge Table for Books and Authors
CREATE TABLE Dim_BookAuthor (
    BookAuthor_SK INT PRIMARY KEY IDENTITY(1,1),
    Book_BK INT,
    Author_BK INT,
    SSC INT
);

CREATE TABLE Dim_Address (
    Address_SK INT PRIMARY KEY IDENTITY(1,1),
    Address_BK INT,
    Street_Number VARCHAR(20),
    Street_Name VARCHAR(255),
    City VARCHAR(100),
    Country_BK INT,
    Country_Name VARCHAR(100),
    SSC INT
);

CREATE TABLE Dim_Customer (
    Customer_SK INT PRIMARY KEY IDENTITY(1,1),
    Customer_BK INT,
    First_Name VARCHAR(100),
    Last_Name VARCHAR(100),
    Email VARCHAR(255),
    ST_Date DATETIME,
    End_Date DATETIME,
    Is_Current BIT,
    SSC INT
);

-- Bridge Table for Customers and Addresses
CREATE TABLE Dim_Customer_Address (
    Customer_Address_SK INT PRIMARY KEY IDENTITY(1,1),
    Customer_BK INT,
    Address_BK INT,
    Status_BK INT,
    Address_Status VARCHAR(50),
    ST_Date DATETIME,
    End_Date DATETIME,
    Is_Current BIT,
    SSC INT
);

CREATE TABLE Dim_Order_History (
    History_SK INT PRIMARY KEY IDENTITY(1,1),
    History_BK INT,
    Order_BK INT,
    Status_BK INT,
    Status_Date DATETIME,
    Status_Value VARCHAR(50),
    Start_Date DATETIME,
    End_Date DATETIME,
    Is_Current BIT,
    SSC INT
);

CREATE TABLE Dim_Customer_Order (
    Order_SK INT PRIMARY KEY IDENTITY(1,1),
    Order_id INT,
    Order_date DATETIME,
    Customer_BK INT,
    Shipping_Method_BK INT,
    Method_Name VARCHAR(100),
    Dest_Address_BK INT,
    SSC INT
);

---

-- 2. Create Fact Table (Last one)

CREATE TABLE Fact_Sales (
    Fact_Sales_ID INT PRIMARY KEY IDENTITY(1,1),
    Book_SK_FK INT,
    Date_SK_FK INT,
    Time_SK_FK INT,
    Customer_SK_FK INT,
    History_SK_FK INT,
    Order_SK_FK INT,
    Line_BK INT,
    Price DECIMAL(18, 2),
    
    -- Foreign Key Constraints
    CONSTRAINT FK_Fact_Book FOREIGN KEY (Book_SK_FK) REFERENCES Dim_Book(Book_SK),
    CONSTRAINT FK_Fact_Date FOREIGN KEY (Date_SK_FK) REFERENCES DimDate(DateSK),
    CONSTRAINT FK_Fact_Time FOREIGN KEY (Time_SK_FK) REFERENCES DimTime(TimeSK),
    CONSTRAINT FK_Fact_Customer FOREIGN KEY (Customer_SK_FK) REFERENCES Dim_Customer(Customer_SK),
    CONSTRAINT FK_Fact_History FOREIGN KEY (History_SK_FK) REFERENCES Dim_Order_History(History_SK),
    CONSTRAINT FK_Fact_Order FOREIGN KEY (Order_SK_FK) REFERENCES Dim_Customer_Order(Order_SK)
);