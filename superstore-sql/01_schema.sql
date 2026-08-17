-- ============================================================
-- Superstore Sales Analysis — Schema DDL
-- Database: PostgreSQL
-- ============================================================

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    row_id          INTEGER PRIMARY KEY,
    order_id        VARCHAR(20)     NOT NULL,
    order_date      DATE            NOT NULL,
    ship_date       DATE            NOT NULL,
    ship_mode       VARCHAR(20)     NOT NULL,
    customer_id     VARCHAR(20)     NOT NULL,
    customer_name   VARCHAR(100)    NOT NULL,
    segment         VARCHAR(20)     NOT NULL,
    country         VARCHAR(50)     NOT NULL,
    city            VARCHAR(50)     NOT NULL,
    state           VARCHAR(50)     NOT NULL,
    postal_code     INTEGER,
    region          VARCHAR(20)     NOT NULL,
    product_id      VARCHAR(20)     NOT NULL,
    category        VARCHAR(30)     NOT NULL,
    sub_category    VARCHAR(30)     NOT NULL,
    product_name    VARCHAR(255)    NOT NULL,
    sales           NUMERIC(12,4)   NOT NULL,
    quantity        INTEGER         NOT NULL,
    discount        NUMERIC(4,2)    NOT NULL,
    profit          NUMERIC(12,4)   NOT NULL,
    shipping_days   INTEGER,
    order_year      INTEGER,
    order_month     VARCHAR(7),
    profit_margin   NUMERIC(6,4),
    is_loss         BOOLEAN
);

-- Indexes to speed up common analytical filters/joins
CREATE INDEX idx_orders_order_date   ON orders (order_date);
CREATE INDEX idx_orders_customer_id  ON orders (customer_id);
CREATE INDEX idx_orders_region       ON orders (region);
CREATE INDEX idx_orders_category     ON orders (category, sub_category);
CREATE INDEX idx_orders_order_id     ON orders (order_id);

COMMENT ON TABLE orders IS 'One row per order line-item, sourced from Sample Superstore dataset (2014-2017)';