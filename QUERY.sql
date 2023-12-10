-- Output all the airplane names and models with capacity higher than 100
SELECT Name, Model, Capacity
FROM Airplane
WHERE Capacity > 100;

-- Output all the tickets with value between 100 and 200 euro
SELECT *
FROM Ticket
WHERE Price BETWEEN 100 AND 200;


-- Output all the female pilots with more than 20 completed flights
SELECT * 
FROM Pilot
WHERE gender = 'Female'
AND TotalFlights > 20;

-- Output all the crew members that are currently in the air
SELECT 
    Staff.StaffId, 
    Staff.Name, 
    Staff.Role, 
    Staff.Age, 
    Staff.TotalFlights
FROM 
    Staff
WHERE 
    Staff.StaffId IN (
        SELECT 
            FlightsStaff.StaffId
        FROM 
            FlightsStaff
        WHERE 
            FlightsStaff.FlightId IN (
                SELECT 
                    Flight.FlightId
                FROM 
                    Flight
                WHERE 
                    Flight.DepartureTime <= CURRENT_TIMESTAMP 
                    AND Flight.ArrivalTime > CURRENT_TIMESTAMP
            )
    );

	
-- Output the number of flights in Split/from Split in 2023
SELECT COUNT(*)
FROM Flight
WHERE EXTRACT(YEAR FROM DepartureTime) = 2023
    AND (DepartureAirport IN (SELECT Name FROM Airport WHERE City = 'Split') OR
         DestinationAirport IN (SELECT Name FROM Airport WHERE City = 'Split'));


-- Output all the flights for Vienna in December 2023
SELECT * 
FROM Flight
WHERE EXTRACT(YEAR FROM DepartureTime) = 2023
AND EXTRACT(MONTH FROM DepartureTime) = 12
AND DestinationAirport IN (SELECT Name FROM Airport WHERE City = 'Vienna');

-- Output the number of sold ecenomy flights by AirDUMP company in 2021
SELECT COUNT(*)
FROM Ticket
WHERE 
    Ticket.FlightId IN (
        SELECT 
            Flight.FlightId
        FROM 
            Flight
        WHERE 
            Flight.FlightId IN (
                SELECT 
                    AirplaneFlight.FlightId
                FROM 
                    AirplaneFlight
                WHERE 
                    AirplaneFlight.AirplaneId IN (
                        SELECT 
                            Airplane.AirplaneId
                        FROM 
                            Airplane
                        WHERE 
                            Airplane.Company = 'AirDUMP'
                    )
            )
    )
    AND Ticket.SeatClass = 'economy'
    AND Ticket.Sold = 'true'
    AND EXTRACT(YEAR FROM Ticket.PurchaseTime) = 2021;


-- Output the average rating of AirDUMP flights
SELECT AVG(Flight.Rating) AS AverageRating
FROM Flight
WHERE Flight.FlightId IN (
    SELECT FlightId
    FROM AirplaneFlight, Airplane
    WHERE AirplaneFlight.AirplaneId = Airplane.AirplaneId
      AND Airplane.Company = 'AirDUMP');

-- Output all the airports in London, sorted by number of Airbus airplanes currently on their runways
SELECT 
    Airport.AirportId,
    Airport.Name AS AirportName,
    (
        SELECT COUNT(DISTINCT AirplaneId)
        FROM AirplaneFlight
        WHERE AirplaneFlight.FlightId IN (
            SELECT Flight.FlightId
            FROM Flight
            WHERE (Flight.DepartureAirport = Airport.Name OR Flight.DestinationAirport = Airport.Name)
            AND (
                (Flight.DepartureTime BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '30 minutes')
                OR (Flight.ArrivalTime BETWEEN CURRENT_TIMESTAMP - INTERVAL '30 minutes' AND CURRENT_TIMESTAMP)
            )
            AND AirplaneFlight.AirplaneId IN (
                SELECT Airplane.AirplaneId
                FROM Airplane
                WHERE Airplane.Model = 'Airbus'
            )
        )
    ) AS AirbusCount
FROM 
    Airport
WHERE 
    Airport.City = 'London'
ORDER BY 
    AirbusCount DESC;


-- Output all the airports distanced from Split less than 1500km
SELECT
    AirportId,
    Name AS AirportName,
    City,
    DistanceFromSplit
FROM
    Airport
WHERE
    City = 'Split' OR DistanceFromSplit < 1500;

	
--Cut the price of all the tickets for 20% that have less than 20 passengers on it
--(As I have 500 flights and 1500 tickets there are max 10 passengers per flight so this updates all the tickets)

UPDATE Ticket
SET Price = Price * 0.8
WHERE FlightId IN (
    SELECT FlightId
    FROM (
        SELECT FlightId, COUNT(*) AS NumPassengers
        FROM Ticket
        GROUP BY FlightId
    ) AS FlightPassengerCount
    WHERE NumPassengers < 20
);





-- Increase the wage for 100e to all the pilots who had more than 10 flights longer than 10 hours this year
UPDATE Pilot
SET Wage = Wage + 100
WHERE PilotId IN (
    SELECT PilotId
    FROM FlightPilots
    WHERE (
        SELECT COUNT(*)
        FROM Flight
        WHERE Flight.FlightId = FlightPilots.FlightId
        AND EXTRACT(YEAR FROM Flight.DepartureTime) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) > 10
    AND (
        SELECT SUM(EXTRACT(EPOCH FROM Flight.ArrivalTime - Flight.DepartureTime) / 3600)
        FROM Flight
        WHERE Flight.FlightId = FlightPilots.FlightId
        AND EXTRACT(YEAR FROM Flight.DepartureTime) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) > 10
    GROUP BY PilotId
);



-- Demont all the planes older than 20 years who don't have arranged flights in the future
DELETE FROM Airplane
WHERE 
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM ManufactureDate) > 20
    AND AirplaneId NOT IN (
        SELECT AirplaneId
        FROM AirplaneFlight
        WHERE FlightId IN (
            SELECT FlightId
            FROM Flight
            WHERE ArrivalTime > CURRENT_TIMESTAMP
        )
    );

	
-- Delete all the flights who don't have single sold ticket
DELETE FROM Flight
WHERE FlightId NOT IN (
    SELECT DISTINCT Ticket.FlightId
    FROM Ticket
    WHERE Ticket.Sold = true
);


-- Delete all the loyalty cards of passengers who's last name ends at 'ov'/'a'/'in'/'a'
UPDATE Passenger
SET LoyaltyCardExpiry = CURRENT_DATE - INTERVAL '1 day'
WHERE LOWER(RIGHT(Name, 2)) LIKE ANY(ARRAY['%ov', '%a', '%in']);

