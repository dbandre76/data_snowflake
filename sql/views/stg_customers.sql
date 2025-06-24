CREATE VIEW STG_CUSTOMERS AS 
select 
    UPPER(customer_id) AS CUSTOMER_ID,
    UPPER(company_name) AS COMPANY_NAME,
    UPPER(contact_name) AS CONTACT_NAME,
    UPPER(contact_title) AS CONTACT_TITLE,
    UPPER(address) ADDRESS,
    UPPER(city) AS CITY,
    UPPER(postal_code) AS POSTAL_CODE,
    UPPER(country) AS COUNTRY,
    UPPER(phone) AS PHONE,
    UPPER(fax) AS FAX
from public.customers