


CREATE DATABASE proyecto_MYSQL;

USE proyecto_MYSQL;


CREATE TABLE IF NOT EXISTS countries(
    isocode VARCHAR(6) PRIMARY KEY,
    name VARCHAR(50),
    alfaisotwo VARCHAR(2),
    alfaisothree VARCHAR(4)

)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS subdivisioncategories(
id INT AUTO_INCREMENT PRIMARY KEY,
description VARCHAR(40)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS stateorregions(
code VARCHAR(6) PRIMARY KEY,
name VARCHAR(60),
country_id VARCHAR(6),
code3166 VARCHAR(10), 
subdivision_id INT(11)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS citiesormunicipalities(
    code VARCHAR(6) PRIMARY KEY,
    name VARCHAR(60),
    statereg_id VARCHAR(6)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS typesidentifications(
    id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(60),
    sufix VARCHAR(5)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS categories(
    id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(60)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS memberships(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50),
description TEXT
)ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS periods(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS companies(
    id VARCHAR(20) PRIMARY KEY ,
    type_id INT,
    name VARCHAR(80),
    category_id INT(11),
    city_id VARCHAR(6),
    audience_id INT,
    cellphone VARCHAR(15),
    email VARCHAR(80),

)ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS companyproducts(
company_id VARCHAR(20),
product_id INT,
price DOUBLE,
unimeasure_id INT,
PRIMARY KEY (company_id,product_id)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS membershipperiods(
    membership_id INT(11),
    period_id INT(11),
    price DOUBLE,
    PRIMARY KEY (membership_id,period_id)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS benefits(
id INT AUTO_INCREMENT PRIMARY KEY,
description VARCHAR(80),
detail TEXT
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS membershipbenefits(
  membership_id INT(11),
  period_id INT(11),
  audience_id INT(11),
  benefit_id INT(11),
  PRIMARY KEY (membership_id,period_id,audience_id,benefit_id)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS audiencebenefits(
    audience_id INT(11),
    benefit_id INT(11),
    PRIMARY KEY(audience_id,benefit_id)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS audiences(
id INT AUTO_INCREMENT PRIMARY KEY,
description VARCHAR(60)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS unitofmeasure(
id INT PRIMARY KEY,
description VARCHAR(60)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS rates(
customer_id INT,
company_id VARCHAR(20),
poll_id INT,
daterating DATETIME,
rating DOUBLE,
PRIMARY KEY(customer_id,company_id,poll_id)
)ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS customers(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(80),
city_id VARCHAR(6),
audience_id INT,
cellphone VARCHAR(20),
email VARCHAR(100),
address VARCHAR(120)
)ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS favorites(
id INT AUTO_INCREMENT PRIMARY KEY,
customer_id INT,
company_id VARCHAR(20),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
UNIQUE key(customer_id,company_id)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS details_favorites(
id INT PRIMARY KEY,
favorite_id INT,
product_id INT,
UNIQUE KEY (favorite_id, product_id)
)ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS products(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(60),
detail TEXT,
price DOUBLE,
category_id INT(11),
image VARCHAR(80)
)ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS polls(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80),
    description TEXT,
    isactive BOOLEAN,
    categorypoll_id INT
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS categories_polls(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(80)
)ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS quality_products(
    product_id INT,
    customer_id INT,
    poll_id INT,
    company_id VARCHAR(20),
    daterating DATETIME,
    rating DOUBLE,
    PRIMARY KEY(product_id, customer_id, poll_id,company_id)
)ENGINE = INNODB;



ALTER TABLE products
ADD COLUMN average_rating DECIMAL(3,2) DEFAULT NULL COMMENT 'Promedio de calificaciones del producto';

ALTER TABLE companies
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE stateorregions
ADD CONSTRAINT fk_stateorregions_country FOREIGN KEY (country_id) REFERENCES countries(isocode),
ADD CONSTRAINT fk_stateorregions_subdivision FOREIGN KEY (subdivision_id) REFERENCES subdivisioncategories(id);


ALTER TABLE citiesormunicipalities
ADD CONSTRAINT fk_cities_state FOREIGN KEY(statereg_id) REFERENCES stateorregions(code);



ALTER TABLE companies
ADD CONSTRAINT fk_companies_type FOREIGN KEY (type_id) REFERENCES typesidentifications(id);

ALTER TABLE companies
ADD CONSTRAINT fk_companies_category FOREIGN KEY (category_id) REFERENCES categories(id);

ALTER TABLE companies
ADD CONSTRAINT fk_companies_city FOREIGN KEY (city_id) REFERENCES citiesormunicipalities(code);

ALTER TABLE companies
ADD CONSTRAINT fk_companies_audience FOREIGN KEY (audience_id) REFERENCES audiences(id);


ALTER TABLE companyproducts
ADD CONSTRAINT fk_companyproducts_company FOREIGN KEY (company_id) REFERENCES companies(id), 
ADD CONSTRAINT fk_companyproducts_product FOREIGN KEY (product_id) REFERENCES products(id),
ADD CONSTRAINT fk_companyproducts_unit FOREIGN KEY (unimeasure_id) REFERENCES unitofmeasure(id);


ALTER TABLE customers
ADD CONSTRAINT fk_customers_city FOREIGN KEY (city_id) REFERENCES citiesormunicipalities(code);

ALTER TABLE customers
ADD CONSTRAINT fk_customers_audience FOREIGN KEY (audience_id) REFERENCES audiences(id);


ALTER TABLE favorites
ADD CONSTRAINT fk_favorites_customers FOREIGN KEY (customer_id) REFERENCES customers(id),
ADD CONSTRAINT fk_favorites_company FOREIGN KEY (company_id) REFERENCES companies(id);

ALTER TABLE details_favorites
ADD CONSTRAINT fk_details_favorite FOREIGN KEY (favorite_id) REFERENCES favorites(id),
ADD CONSTRAINT fk_details_product FOREIGN KEY (product_id) REFERENCES products(id);

ALTER TABLE membershipperiods
ADD CONSTRAINT fk_membershipperiods_membership FOREIGN KEY (membership_id) REFERENCES memberships(id),
ADD CONSTRAINT fk_membershipperiods_period FOREIGN KEY (period_id) REFERENCES periods(id);


ALTER TABLE membershipbenefits
ADD CONSTRAINT fk_membenefit_combo FOREIGN KEY (membership_id, period_id) REFERENCES membershipperiods(membership_id, period_id),
ADD CONSTRAINT fk_membenefit_audience FOREIGN KEY (audience_id) REFERENCES audiences(id),
ADD CONSTRAINT fk_membenefit_benefit FOREIGN KEY (benefit_id) REFERENCES benefits(id);


ALTER TABLE audiencebenefits
ADD CONSTRAINT fk_audiencebenefits_audience FOREIGN KEY (audience_id) REFERENCES audiences(id),
ADD CONSTRAINT fk_audiencebenefits_benefit FOREIGN KEY (benefit_id) REFERENCES benefits(id);


ALTER TABLE products
ADD CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(id);


ALTER TABLE polls
ADD CONSTRAINT fk_polls_category FOREIGN KEY (categorypoll_id) REFERENCES categories_polls(id);

ALTER TABLE quality_products
ADD CONSTRAINT fk_quality_product FOREIGN KEY (product_id) REFERENCES products(id),
ADD CONSTRAINT fk_quality_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
ADD CONSTRAINT fk_quality_poll FOREIGN KEY (poll_id) REFERENCES polls(id),
ADD CONSTRAINT fk_quality_company FOREIGN KEY (company_id) REFERENCES companies(id);

ALTER TABLE rates
ADD CONSTRAINT fk_rates_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

ALTER TABLE rates
ADD CONSTRAINT fk_rates_company FOREIGN KEY (company_id) REFERENCES companies(id);

ALTER TABLE rates
ADD CONSTRAINT fk_rates_poll FOREIGN KEY (poll_id) REFERENCES polls(id);