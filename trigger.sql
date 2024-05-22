--creating tables
CREATE TABLE Customer(
	UserID INT PRIMARY KEY IDENTITY,
    UserName VARCHAR(255),
    Email VARCHAR(255) UNIQUE
);


CREATE TABLE EmailChannel (
    CompanyID INT PRIMARY KEY IDENTITY,
    CompanyName VARCHAR(255)
);


CREATE TABLE Subscription (
    SubscriptionID INT PRIMARY KEY IDENTITY,
    UserID INT,
    CompanyID INT,
	IsActive BIT DEFAULT 1, 
    FOREIGN KEY (UserID) REFERENCES Customer(UserID),
    FOREIGN KEY (CompanyID) REFERENCES EmailChannel(CompanyID)
);

--trigger 1
CREATE TRIGGER InsertCustomer
ON	Customer
AFTER INSERT
AS
BEGIN
    INSERT INTO Subscription(UserID, CompanyID, IsActive)
    SELECT i.UserID,e.CompanyID, 1
    FROM INSERTED i
	CROSS JOIN EmailChannel e;
END;

INSERT INTO EmailChannel(CompanyName) VALUES ('Company #1');
INSERT INTO EmailChannel (CompanyName) VALUES ('Company #2');


--	trigger deneme
INSERT INTO Customer (UserName,Email) VALUES ('Ali Tas','ali@example.com');
INSERT INTO Customer (UserName,Email) VALUES ('Merve Bal','merve@example.com');
SELECT * FROM Subscription;

--trigger 2

CREATE TRIGGER DeleteCustomer
ON Customer
AFTER DELETE 
AS
BEGIN 
	DELETE FROM Subscription WHERE UserID IN (SELECT UserID FROM DELETED);
END;

--trigger deneme 
DELETE FROM Customer WHERE UserID = 1;


--trigger 3

-- Abonelik Log Tablosu Oluþturma
CREATE TABLE Logs (
    LogID INT PRIMARY KEY IDENTITY,
    UserID INT,
    CompanyID INT,
    OldSubs BIT,
    NewSubs BIT,
    ChangeTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Customer(UserID),
    FOREIGN KEY (CompanyID) REFERENCES EmailChannel (CompanyID)
);
CREATE TRIGGER SaveLog
ON Subscription
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	IF EXISTS (SELECT*FROM inserted)
	BEGIN
		INSERT INTO Logs (UserID,CompanyID,OldSubs,NewSubs)
		SELECT i.UserID,i.CompanyID,NULL,i.IsActive
		FROM inserted i;
	END;
	IF EXISTS (SELECT*FROM inserted) AND EXISTS (SELECT*FROM deleted)
	BEGIN
		INSERT INTO Logs (UserID,CompanyID,OldSubs,NewSubs)
		SELECT i.UserID,i.CompanyID,d.IsActive,i.IsActive
		FROM inserted i
		INNER JOIN deleted d ON i.CompanyID=d.CompanyID;
	END;
	IF EXISTS (SELECT*FROM deleted)
	BEGIN
		INSERT INTO Logs (UserID,CompanyID,OldSubs,NewSubs)
		SELECT d.UserID,d.CompanyID,d.IsActive,NULL
		FROM deleted d;
	END;
END;

--trigger 3 deneme
INSERT INTO EmailChannel (CompanyName) VALUES ('Company #3');
INSERT INTO EmailChannel (CompanyName) VALUES ('Company #4');
INSERT INTO Customer (UserName,Email) VALUES ('Narmin Aliyeva','narmin@example.com');
INSERT INTO Customer (UserName,Email) VALUES ('Melisa Tas','melisa@example.com');
INSERT INTO Customer (UserName,Email) VALUES ('Sare Tulumen','sare@example.com');
INSERT INTO Customer (UserName,Email) VALUES ('Melek Akkoyunlu','melek@example.com');
DELETE FROM Customer WHERE UserName='Merve Bal';

UPDATE Subscription SET IsActive=0 WHERE UserID=5 AND CompanyID=3;



