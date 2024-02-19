
--создание необходимых таблиц
CREATE TABLE users(
user_id INT PRIMARY KEY,
user_name VARCHAR(50),
user_age INT,
city VARCHAR(30)
);

CREATE TABLE transactions(
transaction_id INT PRIMARY KEY,
user_id INT REFERENCES users(user_id),
transaction_amount DOUBLE PRECISION,
transaction_date DATE
);

CREATE TABLE orders(
order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
order_amount DECIMAL(10,2)
);

--вставка тестовых данных в таблицы
INSERT INTO users(user_id, user_name, user_age, city)
VALUES
(1,'Иван',19,'Москва'),
(2,'Дмитрий',21,'Москва'),
(3,'Олег',23,'Санкт-Петербург'),
(4,'Сергей',22,'Уфа'),
(5,'Анатолий',35,'Кемерово'),
(6,'Владимир',44,'Калиниград'),
(7,'Вячеслав',33,'Хьюстон'),
(8,'Антон',41,'Нью-Йорк'),
(9,'Михаил',24,'Таллин'),
(10,'Алексей',31,'Хабаровск');

INSERT INTO transactions(transaction_id, user_id, transaction_amount, transaction_date)
VALUES
(1, 1, 60.50, '2024-01-15'),
(2, 1, 75.25, '2024-02-02'),
(3, 2, 45.00, '2024-01-20'),
(4, 3, 50.75, '2023-04-10'),
(5, 3, 90.30, '2023-06-13'),
(6, 3, 100.75, '2023-07-25'),
(7, 4, 80.20, '2023-08-12'),
(8, 4, 40.58, '2023-06-18'),
(9, 5, 70.00, '2023-05-20'),
(10, 5, 68.80, '2023-08-28'),
(11, 6, 91.25, '2023-09-05'),
(12, 7, 89.40, '2023-10-15'),
(13, 7, 50.50, '2023-11-27'),
(14, 8, 85.60, '2024-02-05'),
(15, 8, 95.75, '2023-12-10'),
(16, 8, 35.30, '2023-12-20'),
(17, 8, 123.25, '2023-05-22'),
(18, 9, 45.75, '2023-04-18'),
(19, 10, 90.00, '2023-03-12'),
(20, 10, 65.20, '2023-08-28');

INSERT INTO orders (order_id, customer_id, order_date, order_amount)
VALUES
(1, 1, '2023-12-30', 150.00),
(2, 1, '2023-01-05', 75.50),
(3, 1, '2023-02-10', 100.25),
(4, 2, '2023-03-15', 200.00),
(5, 2, '2023-04-20', 125.75),
(6, 3, '2023-05-25', 180.50),
(7, 3, '2023-06-30', 95.25),
(8, 4, '2023-07-05', 150.75),
(9, 5, '2023-08-10', 250.50),
(10, 5, '2023-09-15', 300.00),
(11, 6, '2023-10-20', 125.50),
(12, 6, '2023-11-25', 175.75),
(13, 6, '2023-12-30', 90.00),
(14, 7, '2023-01-05', 120.25),
(15, 7, '2023-02-10', 250.50),
(16, 8, '2023-03-15', 180.00),
(17, 8, '2023-04-20', 95.25),
(18, 9, '2023-05-25', 150.75),
(19, 9, '2023-06-30', 200.50),
(20, 10, '2023-07-05', 300.00),
(21, 10, '2023-08-10', 125.50),
(22, 11, '2023-09-15', 175.75),
(23, 11, '2023-10-20', 90.00),
(24, 11, '2023-11-25', 120.25),
(25 ,12, '2023-12-30', 250.50),
(26 ,12, '2023-01-05', 180.00),
(27 ,13, '2023-02-10', 95.25),
(28 ,13, '2023-03-15', 150.75),
(29 ,14, '2023-04-20', 200.50),
(30 ,14, '2023-05-25', 300.00),
(31, 1, '2024-12-30', 200.00);

--создание витрины VIP-клиентов
CREATE VIEW "VIP-клиенты" AS (
WITH avg_transactions AS (
    SELECT AVG(transaction_amount) AS avg_amount
    FROM transactions
    WHERE transaction_date >= CURRENT_DATE - INTERVAL '1 year'
),
user_total_transactions AS (
    SELECT user_id, SUM(transaction_amount) AS total_amount
    FROM transactions
    WHERE transaction_date >= CURRENT_DATE - INTERVAL '1 year'
    GROUP BY user_id
    ORDER BY user_id
)
SELECT u.*
FROM users u
JOIN user_total_transactions ut ON u.user_id = ut.user_id
JOIN avg_transactions at ON TRUE
WHERE ut.total_amount > at.avg_amount
);

--создание витрины траты клиентов
--считаем за каждый месяц отдельного года, можно так же посчитать за каждый месяц независимо от года
--чтобы посчитать за каждый месяц независимо от года нужно в функциях to_char и to_date прокинуть не 'Month YYYY', а просто 'Month'
CREATE VIEW "Траты клиентов" AS
(
WITH customer_monthly_amount AS (
    SELECT 
        customer_id,
        TO_CHAR(order_date, 'Month YYYY') AS "month",
        SUM(order_amount) AS total_order_amount
    FROM orders
    GROUP BY customer_id, TO_CHAR(order_date, 'Month YYYY')
),
total_monthly_amount AS (
    SELECT 
        "month",
        SUM(total_order_amount) AS amount
    FROM customer_monthly_amount
    GROUP BY "month"
)
SELECT 
    cma.customer_id AS "Идентификатор клиента",
    cma."month" AS "Месяц",
    cma.total_order_amount AS "Сумма заказов клиента в месяце",
    tma.amount AS "Общая сумма заказов в месяце",
    ROUND((cma.total_order_amount / tma.amount) * 100, 2) AS "Процент от общей суммы заказов"
FROM customer_monthly_amount cma
JOIN total_monthly_amount tma ON cma."month" = tma."month"
ORDER BY cma.customer_id, TO_DATE(cma."month", 'Month YYYY')
);

--Просмотр информации
SELECT * FROM "VIP-клиенты";
SELECT * FROM "Траты клиентов";