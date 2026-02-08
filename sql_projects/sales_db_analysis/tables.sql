CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name TEXT,
    country TEXT,
    signup_date DATE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_amount NUMERIC,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);




