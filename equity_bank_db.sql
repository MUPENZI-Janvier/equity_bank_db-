-- Equity Bank Database
CREATE Database equity_bank_db;
\c equity_bank_db;

-- 1. Table of customers
CREATE TABLE customer (
    customer_id        SERIAL PRIMARY KEY,
    national_id        VARCHAR(20)  NOT NULL UNIQUE,
    customer_name       VARCHAR(100) NOT NULL,
    customer_type       VARCHAR(20)  NOT NULL
                         CHECK (customer_type IN ('Individual', 'Company')),
    registration_date   DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 2. Table of bank branch
CREATE TABLE bank_branch (
    branch_id       SERIAL PRIMARY KEY,
    branch_name     VARCHAR(100) NOT NULL UNIQUE,
    district_name   VARCHAR(100) NOT NULL,
    branch_manager  VARCHAR(100) NOT NULL,
    opening_date    DATE NOT NULL
);

--3. Table of account type
CREATE TABLE account_type (
    account_type_id     SERIAL PRIMARY KEY,
    account_type_name   VARCHAR(50) NOT NULL UNIQUE,
    minimum_balance     NUMERIC(15,2) NOT NULL DEFAULT 0
                         CHECK (minimum_balance >= 0),
    interest_rate       NUMERIC(5,2) NOT NULL
                         CHECK (interest_rate >= 0),
    effective_date      DATE NOT NULL
);

--4. Table of currency
CREATE TABLE currency (
    currency_id     SERIAL PRIMARY KEY,
    currency_code   VARCHAR(3)  NOT NULL UNIQUE,   
    currency_name   VARCHAR(50) NOT NULL,
    exchange_rate   NUMERIC(10,4) NOT NULL CHECK (exchange_rate > 0),
    effective_date  DATE NOT NULL
);

--5. Table of loan type
CREATE TABLE loan_type (
    loan_type_id            SERIAL PRIMARY KEY,
    loan_type_name          VARCHAR(50) NOT NULL UNIQUE,
    interest_rate           NUMERIC(5,2) NOT NULL CHECK (interest_rate >= 0),
    maximum_period_months   INT NOT NULL CHECK (maximum_period_months > 0),
    effective_date          DATE NOT NULL
);

--6. Table of bank employee
CREATE TABLE bank_employee (
    employee_id         SERIAL PRIMARY KEY,
    branch_id           INT NOT NULL,
    employee_name       VARCHAR(100) NOT NULL,
    employee_position   VARCHAR(50) NOT NULL,
    employment_date     DATE NOT NULL,
    CONSTRAINT fk_employee_branch
        FOREIGN KEY (branch_id) REFERENCES bank_branch(branch_id)
);

--7. Table of bank account
CREATE TABLE bank_account (
    account_id       SERIAL PRIMARY KEY,
    customer_id      INT NOT NULL,
    account_type_id  INT NOT NULL,
    branch_id        INT NOT NULL,
    opening_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_account_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_account_type
        FOREIGN KEY (account_type_id) REFERENCES account_type(account_type_id),
    CONSTRAINT fk_account_branch
        FOREIGN KEY (branch_id) REFERENCES bank_branch(branch_id)
);

--8. Table of deposit
CREATE TABLE deposit (
    deposit_id       SERIAL PRIMARY KEY,
    account_id       INT NOT NULL,
    currency_id      INT NOT NULL,
    deposit_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    deposit_amount   NUMERIC(15,2) NOT NULL CHECK (deposit_amount > 0),
    CONSTRAINT fk_deposit_account
        FOREIGN KEY (account_id) REFERENCES bank_account(account_id),
    CONSTRAINT fk_deposit_currency
        FOREIGN KEY (currency_id) REFERENCES currency(currency_id)
);

--9. Table Withdrawal
CREATE TABLE withdrawal (
    withdrawal_id       SERIAL PRIMARY KEY,
    account_id          INT NOT NULL,
    employee_id         INT NOT NULL,
    withdrawal_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    withdrawal_amount   NUMERIC(15,2) NOT NULL CHECK (withdrawal_amount > 0),
    CONSTRAINT fk_withdrawal_account
        FOREIGN KEY (account_id) REFERENCES bank_account(account_id),
    CONSTRAINT fk_withdrawal_employee
        FOREIGN KEY (employee_id) REFERENCES bank_employee(employee_id)
);

--10. Table loan
CREATE TABLE loan (
    loan_id         SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL,
    loan_type_id    INT NOT NULL,
    employee_id     INT NOT NULL,
    loan_amount     NUMERIC(15,2) NOT NULL CHECK (loan_amount > 0),
    CONSTRAINT fk_loan_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_loan_type
        FOREIGN KEY (loan_type_id) REFERENCES loan_type(loan_type_id),
    CONSTRAINT fk_loan_employee
        FOREIGN KEY (employee_id) REFERENCES bank_employee(employee_id)
);

--11. Table loan_repayment
CREATE TABLE loan_repayment (
    repayment_id       SERIAL PRIMARY KEY,
    loan_id            INT NOT NULL,
    account_id         INT NOT NULL,
    repayment_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    repayment_amount   NUMERIC(15,2) NOT NULL CHECK (repayment_amount > 0),
    CONSTRAINT fk_repayment_loan
        FOREIGN KEY (loan_id) REFERENCES loan(loan_id),
    CONSTRAINT fk_repayment_account
        FOREIGN KEY (account_id) REFERENCES bank_account(account_id)
);

--12. Table guarantor
CREATE TABLE guarantor (
    guarantor_id        SERIAL PRIMARY KEY,
    loan_id             INT NOT NULL,
    guarantor_name      VARCHAR(100) NOT NULL,
    guarantor_phone     VARCHAR(15) NOT NULL,
    guaranteed_amount   NUMERIC(15,2) NOT NULL CHECK (guaranteed_amount > 0),
    CONSTRAINT fk_guarantor_loan
        FOREIGN KEY (loan_id) REFERENCES loan(loan_id)
);

--13. Table collateral
CREATE TABLE collateral (
    collateral_id       SERIAL PRIMARY KEY,
    loan_id             INT NOT NULL,
    collateral_type     VARCHAR(50) NOT NULL,
    collateral_value    NUMERIC(15,2) NOT NULL CHECK (collateral_value > 0),
    registration_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_collateral_loan
        FOREIGN KEY (loan_id) REFERENCES loan(loan_id)
);

--14. Table bank card
CREATE TABLE bank_card (
    card_id       SERIAL PRIMARY KEY,
    account_id    INT NOT NULL,
    card_number   VARCHAR(20) NOT NULL UNIQUE,
    card_type     VARCHAR(20) NOT NULL
                  CHECK (card_type IN ('Debit', 'Credit')),
    issue_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_card_account
        FOREIGN KEY (account_id) REFERENCES bank_account(account_id)
);

--15. Table mobile_banking
CREATE TABLE mobile_banking (
    mobile_banking_id   SERIAL PRIMARY KEY,
    customer_id         INT NOT NULL,
    account_id          INT NOT NULL,
    phone_number        VARCHAR(15) NOT NULL UNIQUE,
    registration_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_mobile_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_mobile_account
        FOREIGN KEY (account_id) REFERENCES bank_account(account_id)
);

--16. Table beneficiary
CREATE TABLE beneficiary (
    beneficiary_id       SERIAL PRIMARY KEY,
    customer_id          INT NOT NULL,
    beneficiary_name     VARCHAR(100) NOT NULL,
    beneficiary_account  VARCHAR(30) NOT NULL,
    registration_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_beneficiary_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

--17. Table fixed_deposit
CREATE TABLE fixed_deposit (
    fixed_deposit_id   SERIAL PRIMARY KEY,
    account_id         INT NOT NULL,
    currency_id        INT NOT NULL,
    principal_amount   NUMERIC(15,2) NOT NULL CHECK (principal_amount > 0),
    maturity_date      DATE NOT NULL,
    CONSTRAINT fk_fixeddeposit_account
        FOREIGN KEY (account_id) REFERENCES bank_account(account_id),
    CONSTRAINT fk_fixeddeposit_currency
        FOREIGN KEY (currency_id) REFERENCES currency(currency_id)
);

--18. Table insurance_policy
CREATE TABLE insurance_policy (
    policy_id         SERIAL PRIMARY KEY,
    customer_id       INT NOT NULL,
    loan_id           INT,                 
    policy_type       VARCHAR(50) NOT NULL,
    premium_amount    NUMERIC(15,2) NOT NULL CHECK (premium_amount > 0),
    CONSTRAINT fk_policy_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_policy_loan
        FOREIGN KEY (loan_id) REFERENCES loan(loan_id)
);

--19. Table Customer_complaint
CREATE TABLE customer_complaint (
    complaint_id       SERIAL PRIMARY KEY,
    customer_id        INT NOT NULL,
    employee_id        INT NOT NULL,
    complaint_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    complaint_status   VARCHAR(20) NOT NULL DEFAULT 'Pending'
                       CHECK (complaint_status IN
                              ('Pending', 'In Progress', 'Resolved', 'Rejected')),
    CONSTRAINT fk_complaint_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_complaint_employee
        FOREIGN KEY (employee_id) REFERENCES bank_employee(employee_id)
);

--20. Table branch_target
CREATE TABLE branch_target (
    target_id         SERIAL PRIMARY KEY,
    branch_id         INT NOT NULL,
    account_type_id   INT NOT NULL,
    target_year       INT NOT NULL CHECK (target_year >= 2000),
    target_amount     NUMERIC(15,2) NOT NULL CHECK (target_amount > 0),
    CONSTRAINT fk_target_branch
        FOREIGN KEY (branch_id) REFERENCES bank_branch(branch_id),
    CONSTRAINT fk_target_accounttype
        FOREIGN KEY (account_type_id) REFERENCES account_type(account_type_id),
    CONSTRAINT uq_target_branch_type_year
        UNIQUE (branch_id, account_type_id, target_year)
);


-- ====================================================================================================================
INSERT INTO bank_branch (branch_name, district_name, branch_manager, opening_date)
SELECT
    'Equity Branch ' || generate_series,
    CASE (generate_series % 8)
        WHEN 0 THEN 'Nyarugenge'
        WHEN 1 THEN 'Gasabo'
        WHEN 2 THEN 'Kicukiro'
        WHEN 3 THEN 'Musanze'
        WHEN 4 THEN 'Rubavu'
        WHEN 5 THEN 'Huye'
        WHEN 6 THEN 'Muhanga'
        WHEN 7 THEN 'Rwamagana'
    END,
    CASE (random() * 4)::INT
        WHEN 0 THEN 'Jean Baptiste Mugisha'
        WHEN 1 THEN 'Marie Claire Uwase'
        WHEN 2 THEN 'Eric Niyonzima'
        WHEN 3 THEN 'Diane Mukamana'
        WHEN 4 THEN 'Claude Habimana'
    END,
    CURRENT_DATE - (random() * 3650)::INT
FROM generate_series(1, 100);

-- 2. ACCOUNT_TYPE 
INSERT INTO account_type (account_type_name, minimum_balance, interest_rate, effective_date)
VALUES
    ('Savings Account', 5000, 4.50, '2020-01-01'),
    ('Current Account', 20000, 0.50, '2020-01-01'),
    ('Fixed Deposit Account', 100000, 7.00, '2020-01-01'),
    ('Salary Account', 0, 2.00, '2020-01-01'),
    ('Diaspora Account', 50000, 3.50, '2020-01-01');

-- 3. CURRENCY 
INSERT INTO currency (currency_code, currency_name, exchange_rate, effective_date)
VALUES
    ('RWF', 'Rwandan Franc', 1.0000, CURRENT_DATE),
    ('USD', 'US Dollar', 1310.5000, CURRENT_DATE),
    ('EUR', 'Euro', 1420.7500, CURRENT_DATE),
    ('GBP', 'British Pound', 1660.2000, CURRENT_DATE),
    ('KES', 'Kenyan Shilling', 10.1500, CURRENT_DATE);

-- 4. Loan_type
INSERT INTO loan_type (loan_type_name, interest_rate, maximum_period_months, effective_date)
VALUES
    ('Personal Loan', 16.50, 36, '2020-01-01'),
    ('Mortgage Loan', 14.00, 240, '2020-01-01'),
    ('Business Loan', 18.00, 60, '2020-01-01'),
    ('Education Loan', 12.00, 48, '2020-01-01'),
    ('Agriculture Loan', 10.50, 36, '2020-01-01');

-- 5. CUSTOMER 
INSERT INTO customer (national_id, customer_name, customer_type, registration_date)
SELECT
    '119' || LPAD(generate_series::TEXT, 13, '0'),
    CASE (random() * 4)::INT
        WHEN 0 THEN 'Jean'
        WHEN 1 THEN 'Marie'
        WHEN 2 THEN 'Eric'
        WHEN 3 THEN 'Diane'
        WHEN 4 THEN 'Claude'
    END || ' ' ||
    CASE (random() * 4)::INT
        WHEN 0 THEN 'Mugabo'
        WHEN 1 THEN 'Uwimana'
        WHEN 2 THEN 'Niyonzima'
        WHEN 3 THEN 'Mukamana'
        WHEN 4 THEN 'Rwema'
    END || generate_series,
    CASE WHEN random() > 0.8 THEN 'Company' ELSE 'Individual' END,
    CURRENT_DATE - (random() * 1500)::INT
FROM generate_series(1, 100);

-- 6. BANK_EMPLOYEE 
INSERT INTO bank_employee (branch_id, employee_name, employee_position, employment_date)
SELECT
    (random() * 99 + 1)::INT,
    CASE (random() * 4)::INT
        WHEN 0 THEN 'John'
        WHEN 1 THEN 'Alice'
        WHEN 2 THEN 'Peter'
        WHEN 3 THEN 'Sarah'
        WHEN 4 THEN 'David'
    END || ' ' ||
    CASE (random() * 4)::INT
        WHEN 0 THEN 'Mugisha'
        WHEN 1 THEN 'Uwase'
        WHEN 2 THEN 'Hakizimana'
        WHEN 3 THEN 'Ishimwe'
        WHEN 4 THEN 'Manzi'
    END,
    CASE (random() * 5)::INT
        WHEN 0 THEN 'Teller'
        WHEN 1 THEN 'Senior Teller'
        WHEN 2 THEN 'Accountant'
        WHEN 3 THEN 'Branch Manager'
        WHEN 4 THEN 'Loan Officer'
        WHEN 5 THEN 'Customer Service Agent'
    END,
    CURRENT_DATE - (random() * 2500 + 200)::INT
FROM generate_series(1, 100);

-- 7. BANK_ACCOUNT 
INSERT INTO bank_account (customer_id, account_type_id, branch_id, opening_date)
SELECT
    (random() * 99 + 1)::INT,
    (random() * 4 + 1)::INT,
    (random() * 99 + 1)::INT,
    CURRENT_DATE - (random() * 1200)::INT
FROM generate_series(1, 100);

-- 8. DEPOSIT 
INSERT INTO deposit (account_id, currency_id, deposit_date, deposit_amount)
SELECT
    (random() * 99 + 1)::INT,
    (random() * 4 + 1)::INT,
    CURRENT_DATE - (random() * 900)::INT,
    (random() * 2000000 + 5000)::NUMERIC(15,2)
FROM generate_series(1, 100);

-- 9. WITHDRAWAL 
INSERT INTO withdrawal (account_id, employee_id, withdrawal_date, withdrawal_amount)
SELECT
    (random() * 99 + 1)::INT,
    (random() * 99 + 1)::INT,
    CURRENT_DATE - (random() * 900)::INT,
    (random() * 800000 + 5000)::NUMERIC(15,2)
FROM generate_series(1, 100);

-- 10. LOAN
INSERT INTO loan (customer_id, loan_type_id, employee_id, loan_amount)
SELECT
    (random() * 99 + 1)::INT,
    (random() * 4 + 1)::INT,
    (random() * 99 + 1)::INT,
    (random() * 15000000 + 200000)::NUMERIC(15,2)
FROM generate_series(1, 100);

-- 11. LOAN_REPAYMENT 
INSERT INTO loan_repayment (loan_id, account_id, repayment_date, repayment_amount)
SELECT
    (random() * 99 + 1)::INT,
    (random() * 99 + 1)::INT,
    CURRENT_DATE - (random() * 600)::INT,
    (random() * 500000 + 10000)::NUMERIC(15,2)
FROM generate_series(1, 100);

-- 12. GUARANTOR (
INSERT INTO guarantor (loan_id, guarantor_name, guarantor_phone, guaranteed_amount)
SELECT
    (random() * 99 + 1)::INT,
    CASE (random() * 4)::INT
        WHEN 0 THEN 'Emmanuel'
        WHEN 1 THEN 'Beatrice'
        WHEN 2 THEN 'Vincent'
        WHEN 3 THEN 'Solange'
        WHEN 4 THEN 'Aline'
    END || ' ' ||
    CASE (random() * 4)::INT
        WHEN 0 THEN 'Habimana'
        WHEN 1 THEN 'Uwamahoro'
        WHEN 2 THEN 'Ndayisenga'
        WHEN 3 THEN 'Mukeshimana'
        WHEN 4 THEN 'Bizimana'
    END,
    '07' || (2 + (random() * 7)::INT)::TEXT || LPAD((random() * 9999999)::INT::TEXT, 7, '0'),
    (random() * 5000000 + 100000)::NUMERIC(15,2)
FROM generate_series(1, 100);

-- 13. COLLATERAL 
INSERT INTO collateral (loan_id, collateral_type, collateral_value, registration_date)
SELECT
    (random() * 99 + 1)::INT,
    CASE (random() * 4)::INT
        WHEN 0 THEN 'Land Title'
        WHEN 1 THEN 'Vehicle'
        WHEN 2 THEN 'House'
        WHEN 3 THEN 'Business Equipment'
        WHEN 4 THEN 'Fixed Deposit Certificate'
    END,
    (random() * 20000000 + 500000)::NUMERIC(15,2),
    CURRENT_DATE - (random() * 1000)::INT
FROM generate_series(1, 100);

-- 14. BANK_CARD 
INSERT INTO bank_card (account_id, card_number, card_type, issue_date)
SELECT
    (random() * 99 + 1)::INT,
    '4' || LPAD(generate_series::TEXT, 15, '0'),
    CASE WHEN random() > 0.5 THEN 'Debit' ELSE 'Credit' END,
    CURRENT_DATE - (random() * 700)::INT
FROM generate_series(1, 100);

-- 15. MOBILE_BANKING 
INSERT INTO mobile_banking (customer_id, account_id, phone_number, registration_date)
SELECT
    (random() * 99 + 1)::INT,
    (random() * 99 + 1)::INT,
    '07' || (2 + (random() * 7)::INT)::TEXT || LPAD(generate_series::TEXT, 7, '0'),
    CURRENT_DATE - (random() * 800)::INT
FROM generate_series(1, 100);

-- 16. BENEFICIARY 
INSERT INTO beneficiary (customer_id, beneficiary_name, beneficiary_account, registration_date)
SELECT
    (random() * 99 + 1)::INT,
    CASE (random() * 4)::INT
        WHEN 0 THEN 'Patrick'
        WHEN 1 THEN 'Immaculee'
        WHEN 2 THEN 'Fabrice'
        WHEN 3 THEN 'Josiane'
        WHEN 4 THEN 'Olivier'
    END || ' ' ||
    CASE (random() * 4)::INT
        WHEN 0 THEN 'Nkurunziza'
        WHEN 1 THEN 'Mukandayisenga'
        WHEN 2 THEN 'Twagirayezu'
        WHEN 3 THEN 'Kayitesi'
        WHEN 4 THEN 'Ntawuruhunga'
    END,
    'ACC' || TO_CHAR(generate_series, 'FM0000000000'),
    CURRENT_DATE - (random() * 700)::INT
FROM generate_series(1, 100);

-- 17. FIXED_DEPOSIT 
INSERT INTO fixed_deposit (account_id, currency_id, principal_amount, maturity_date)
SELECT
    (random() * 99 + 1)::INT,
    (random() * 4 + 1)::INT,
    (random() * 10000000 + 100000)::NUMERIC(15,2),
    CURRENT_DATE + (random() * 730 + 90)::INT
FROM generate_series(1, 100);

-- 18. INSURANCE_POLICY 
INSERT INTO insurance_policy (customer_id, loan_id, policy_type, premium_amount)
SELECT
    (random() * 99 + 1)::INT,
    CASE WHEN random() > 0.4 THEN (random() * 99 + 1)::INT ELSE NULL END,
    CASE (random() * 3)::INT
        WHEN 0 THEN 'Life Insurance'
        WHEN 1 THEN 'Loan Protection Insurance'
        WHEN 2 THEN 'Property Insurance'
        WHEN 3 THEN 'Health Insurance'
    END,
    (random() * 200000 + 5000)::NUMERIC(15,2)
FROM generate_series(1, 100);

-- 19. CUSTOMER_COMPLAINT 
INSERT INTO customer_complaint (customer_id, employee_id, complaint_date, complaint_status)
SELECT
    (random() * 99 + 1)::INT,
    (random() * 99 + 1)::INT,
    CURRENT_DATE - (random() * 500)::INT,
    CASE (random() * 3)::INT
        WHEN 0 THEN 'Pending'
        WHEN 1 THEN 'In Progress'
        WHEN 2 THEN 'Resolved'
        WHEN 3 THEN 'Rejected'
    END
FROM generate_series(1, 100);

-- 20. BRANCH_TARGET 
INSERT INTO branch_target (branch_id, account_type_id, target_year, target_amount)
SELECT
    generate_series,
    (random() * 4 + 1)::INT,
    2024,
    (random() * 50000000 + 1000000)::NUMERIC(15,2)
FROM generate_series(1, 100);

-- Queries
--Query 1.
select c.national_id, c.customer_name, c.customer_type, at.account_type_name, bb.branch_name, 
bb.district_name, d.deposit_amount, w.withdrawal_amount, sum(lr.repayment_amount) as 
total_repayment_amount, sum(l.loan_amount) as total_loan from customer as c inner join 
bank_account as ba on c.customer_id = ba.customer_id inner join account_type as at on 
ba.account_type_id = at.account_type_id inner join bank_branch as bb on 
bb.branch_id = ba.branch_id inner join deposit as d on d.account_id = ba.account_id inner join 
withdrawal as w on w.account_id = ba.account_id inner join loan_repayment as lr on 
ba.account_id = lr.account_id inner join loan as l on l.loan_id = lr.loan_id group by 
c.national_id, c.customer_name, c.customer_type, at.account_type_name, bb.branch_name, 
bb.district_name, d.deposit_amount, w.withdrawal_amount having sum(l.loan_amount) > 1000000;


--Query 2.
select c.national_id, c.customer_name, c.registration_date, at.account_type_name, ba.opening_date, 
bb.branch_name, count(d.deposit_id) as number_of_deposit, sum(d.deposit_amount) as 
total_deposited_amount from customer as c left join bank_account as ba on 
ba.customer_id = c.customer_id left join account_type as at on at.account_type_id = ba.account_type_id 
left join bank_branch as bb on bb.branch_id = ba.branch_id left join deposit as d on 
d.account_id = ba.account_id group by c.national_id, c.customer_name, 
c.registration_date, ba.opening_date, at.account_type_name, bb.branch_name having 
count(d.deposit_id) < 3;

--Query 3.
select at.account_type_id, at.account_type_name, at.minimum_balance, at.interest_rate, count(ba.account_id) 
as number_of_customer_account, sum(d.deposit_amount) as total_deposited_amount, sum(w.withdrawal_amount) as 
total_withdrawn_amount from account_type as at right join bank_account as ba on 
at.account_type_id = ba.account_type_id right join deposit as d on 
d.account_id = ba.account_id right join withdrawal as w on w.account_id = ba.account_id 
group by at.account_type_id, at.account_type_name, at.minimum_balance, at.interest_rate 
having sum(d.deposit_amount) < 5000000;

--Query 4.
select c.national_id, c.customer_name, at.account_type_name, bb.branch_name, lt.loan_type_name, 
sum(l.loan_amount) as total_loan_amount, sum(lr.repayment_amount) as total_repayment_amount, 
sum(g.guaranteed_amount) as total_guranteed_amount, sum(co.collateral_value) as 
total_collateral_value from customer as c inner join bank_account as ba on 
ba.customer_id = c.customer_id inner join account_type as at on 
at.account_type_id = ba.account_type_id inner join bank_branch as bb on 
ba.branch_id = bb.branch_id inner join loan_repayment as lr on 
lr.account_id = ba.account_id  inner join loan as l on 
l.loan_id = lr.loan_id inner join guarantor as g on g.loan_id = l.loan_id inner join 
loan_type as lt on lt.loan_type_id = l.loan_type_id inner join collateral as co on 
co.loan_id = l.loan_id group by c.national_id, c.customer_name, at.account_type_name, 
bb.branch_name, lt.loan_type_name having sum(l.loan_amount) > 10000000;

--Query 5.
select c.national_id, c.customer_name, ba.opening_date, at.account_type_name, count(d.deposit_id) 
as number_of_deposit, sum(d.deposit_amount) as total_deposited_amount, sum(w.withdrawal_amount) as 
total_withdrawn_amount from customer as c left join bank_account as ba on ba.customer_id = c.customer_id 
left join  account_type as at on at.account_type_id = ba.account_type_id left join deposit as d on 
d.account_id = ba.account_id left join withdrawal as w on w.account_id = ba.account_id group by 
c.national_id, c.customer_name, ba.opening_date, at.account_type_name having 
sum(w.withdrawal_amount) > sum(d.deposit_amount);

--Query 6.
select c.national_id, c.customer_name, bc.card_number, bc.card_type, at.account_type_name, 
count(d.deposit_id) as number_of_deposits, sum(d.deposit_amount) as total_deposited_amount, 
sum(w.withdrawal_amount) as total_withdrawn_amount from customer as c right join bank_account as 
ba on ba.customer_id = c.customer_id right join bank_card as bc on bc.account_id = ba.account_id 
right join account_type as at on at.account_type_id = ba.account_type_id right join deposit as d 
on d.account_id = ba.account_id right join withdrawal as w on w.account_id = ba.account_id group by 
c.national_id, c.customer_name, bc.card_number, bc.card_type, at.account_type_name having 
sum(d.deposit_amount) > 1000000;
