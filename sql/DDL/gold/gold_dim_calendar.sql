CREATE TABLE IF NOT EXISTS gold_dim_calendar (
    date_sk BIGINT,
    date_key DATE NOT NULL,
    year NUMBER(4,0),
    quarter NUMBER(1,0),
    month NUMBER(2,0),
    day NUMBER(2,0),
    month_name VARCHAR(10),
    day_name VARCHAR(10),
    week_number NUMBER(2,0),
    is_weekend BOOLEAN
);

