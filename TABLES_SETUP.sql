-- Airport Table
CREATE TABLE IF NOT EXISTS Airport (
    AirportId SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,
    DistanceFromSplit INT,
	RunWayCapacity INT,
	WarehouseCapacity INT
);
ALTER TABLE Airport
ALTER COLUMN Name TYPE VARCHAR(100);

-- Pilot Table
CREATE TABLE IF NOT EXISTS Pilot (
    PilotId SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Age INT NOT NULL,
    TotalFlights INT DEFAULT 0
);

ALTER TABLE Pilot 
ADD COLUMN IF NOT EXISTS gender VARCHAR(10);
ALTER TABLE Pilot
ADD COLUMN IF NOT EXISTS Wage INT;

-- Passenger Table
CREATE TABLE IF NOT EXISTS Passenger (
    UserId SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    LoyaltyCardExpiry DATE,
    LoyaltyCardCreationTime TIMESTAMP,
    TotalPurchasedTickets INT DEFAULT 0
);
UPDATE Passenger
SET 
    LoyaltyCardExpiry = CASE 
                            WHEN TotalPurchasedTickets < 10 THEN NULL 
                            ELSE LoyaltyCardExpiry 
                        END,
    LoyaltyCardCreationTime = CASE 
                                  WHEN TotalPurchasedTickets < 10 THEN NULL 
                                  ELSE LoyaltyCardCreationTime 
                              END;


-- Airplane Table
CREATE TABLE IF NOT EXISTS Airplane (
    AirplaneId SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,	
    Model VARCHAR(50) NOT NULL,
    Capacity INT NOT NULL,
    Status VARCHAR(20) NOT NULL
);
ALTER TABLE Airplane
ADD COLUMN IF NOT EXISTS Company VARCHAR(20);
ALTER TABLE Airplane
ADD COLUMN IF NOT EXISTS ManufactureDate TIMESTAMP;
ALTER TABLE Airplane
ADD COLUMN IF NOT EXISTS Name VARCHAR(80);

-- Alter existing columns to drop NOT NULL constraints
ALTER TABLE Airplane
ALTER COLUMN Name DROP NOT NULL,
ALTER COLUMN Model DROP NOT NULL,
ALTER COLUMN Capacity DROP NOT NULL,
ALTER COLUMN Status DROP NOT NULL;


-- Flight Table
CREATE TABLE IF NOT EXISTS Flight (
    FlightId SERIAL PRIMARY KEY,
    DepartureAirport INT REFERENCES Airport(AirportId),
    DestinationAirport INT REFERENCES Airport(AirportId),
    DepartureTime TIMESTAMP NOT NULL,
    ArrivalTime TIMESTAMP NOT NULL,
    PilotId INT REFERENCES Pilot(PilotId),
    Rating INT,
    Comment TEXT
);
ALTER TABLE Flight
DROP COLUMN IF EXISTS DepartureAirport,
DROP COLUMN IF EXISTS DestinationAirport;

ALTER TABLE Flight
ADD COLUMN DepartureAirport VARCHAR(80),
ADD COLUMN DestinationAirport VARCHAR(80);


-- AirplaneFlight
CREATE TABLE IF NOT EXISTS AirplaneFlight (
	AirplaneId INT REFERENCES Airplane(AirplaneId),
	FlightId INT REFERENCES FLight(FlightId),
	PRIMARY KEY(AirplaneId, FlightId)
);

-- FlightPilots Table
CREATE TABLE IF NOT EXISTS FlightPilots (
    FlightId INT REFERENCES Flight(FlightId),
    PilotId INT REFERENCES Pilot(PilotId),
    PRIMARY KEY (FlightId, PilotId)
);

-- Staff Table
CREATE TABLE IF NOT EXISTS Staff (
    StaffId SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Age INT NOT NULL,
    TotalFlights INT DEFAULT 0
);

--FlightsStaff
CREATE TABLE IF NOT EXISTS FlightsStaff (
	FlightId INT REFERENCES Flight(FlightId),
	StaffId INT REFERENCES Staff(StaffId),
	PRIMARY KEY (FlightId, StaffId)
);


-- Ticket Table
CREATE TABLE IF NOT EXISTS Ticket (
    TicketId SERIAL PRIMARY KEY,
    FlightId INT REFERENCES Flight(FlightId),
    UserId INT REFERENCES Passenger(UserId),
	SeatClass VARCHAR(10) NOT NULL,
    SeatNumber VARCHAR(5) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    PurchaseTime TIMESTAMP NOT NULL
);

ALTER TABLE Ticket
ALTER COLUMN PurchaseTime DROP NOT NULL;
ALTER TABLE Ticket
ADD COLUMN IF NOT EXISTS Sold BOOLEAN NOT NULL;
	
