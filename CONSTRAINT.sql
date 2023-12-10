ALTER TABLE Airport 
ADD CONSTRAINT distanceFromSplit_non_negative CHECK (DistanceFromSplit >= 0),
ADD CONSTRAINT runWayCapacity_positive CHECK (RunWayCapacity > 0),
ADD CONSTRAINT warehouseCapacity_positive CHECK (WarehouseCapacity > 0);


ALTER TABLE Pilot 
ADD CONSTRAINT age_in_range CHECK (Age BETWEEN 20 AND 60),
ADD CONSTRAINT totalFlights_non_negative CHECK (TotalFlights >= 0),
ADD CONSTRAINT wage_non_negative CHECK (Wage >= 0);


ALTER TABLE Passenger 
ADD CONSTRAINT totalPurchasedTickets_non_negative CHECK (TotalPurchasedTickets >= 0);


ALTER TABLE Airplane 
ADD CONSTRAINT capacity_positive CHECK (Capacity > 0);


ALTER TABLE Flight 
ADD CONSTRAINT arrivalTime_after_departureTime CHECK (ArrivalTime > DepartureTime),
ADD CONSTRAINT rating_valid_range CHECK (Rating BETWEEN 1 AND 5);


ALTER TABLE Staff 
ADD CONSTRAINT age_adult CHECK (Age >= 18),
ADD CONSTRAINT totalFlights_non_negative CHECK (TotalFlights >= 0);


ALTER TABLE Ticket 
ADD CONSTRAINT price_non_negative CHECK (Price >= 0);

