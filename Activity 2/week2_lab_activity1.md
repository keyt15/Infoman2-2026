# Week 2: Calculate Flight Duration (Function)
Goal: Create a SQL function that calculates the duration of a flight.

# Task: Write a PL/pgSQL function called get_flight_duration that accepts a flight ID and returns the flight's duration as an INTERVAL.

# Activity 1
```sql
CREATE OR REPLACE FUNCTION get_flight_duration(p_flight_id INT)
RETURNS INTERVAL AS $$
DECLARE
    v_departure TIMESTAMP;
    v_arrival TIMESTAMP;
BEGIN
    SELECT departure_time, arrival_time
    INTO v_departure, v_arrival
    FROM flights
    WHERE flight_id = p_flight_id;
    RETURN v_arrival - v_departure;
END;
$$ LANGUAGE plpgsql;
```

# Activity 2
```sql
CREATE OR REPLACE FUNCTION get_price_category(p_flight_id INT)
RETURNS VARCHAR AS $$
DECLARE
    v_price NUMERIC;
BEGIN
    SELECT base_price INTO v_price
    FROM flights
    WHERE flight_id = p_flight_id;
    IF v_price < 100 THEN
        RETURN 'Budget';
    ELSIF v_price >= 100 AND v_price < 300 THEN
        RETURN 'Standard';
    ELSE
        RETURN 'Premium';
    END IF;
END;
$$ LANGUAGE plpgsql;
```

# Activity 3
```sql
CREATE OR REPLACE PROCEDURE book_flight(
    p_passenger_id INT,
    p_flight_id INT,
    p_seat_number VARCHAR
)
AS $$
BEGIN
    INSERT INTO bookings (passenger_id, flight_id, seat_number, status, booking_date)
    VALUES (p_passenger_id, p_flight_id, p_seat_number, 'Confirmed', CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;
```

# Activity 4
```sql
CREATE OR REPLACE PROCEDURE increase_prices_for_airline(
    p_airline_id INT,
    p_percentage_increase NUMERIC
)
AS $$
BEGIN
    UPDATE flights
    SET base_price = base_price * (1 + p_percentage_increase / 100)
    WHERE airline_id = p_airline_id;
END;
$$ LANGUAGE plpgsql;
```