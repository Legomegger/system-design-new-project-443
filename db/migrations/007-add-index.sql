CREATE INDEX IF NOT EXISTS trips_passenger_created
ON trips (passenger_id, created_at DESC);
