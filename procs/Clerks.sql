-- Add new mail to the system --------------------------------------------------
-- Registered Mail
CREATE OR REPLACE PROCEDURE insertRegisteredMail(mail_id IN VARCHAR2, 
  weight IN NUMBER, postage IN NUMBER,
  deliveryAddress IN VARCHAR2, returnAddress IN VARCHAR2,
  deliveryCountry IN VARCHAR2, deliveryCode IN VARCHAR2, returnCode IN VARCHAR2)
AS 
BEGIN 
  INSERT INTO registeredmail (mail_id, weight, postage, status, delivery_address,
  return_address, delivery_country, delivery_code, return_code)
  VALUES (mail_id, weight, postage, 'waiting', deliveryAddress, returnAddress,
  deliveryCountry, deliveryCode, returnCode); 
END;

declare
  mail_id varchar2(5) := '69';
  weight number(6,2) := 100.00;
  postage number(5,2) := 1.80;
  delivery_address varchar2(50) := '69 who cares';
  return_address varchar2(50) := '100 boulevard of dreams';
  delivery_country varchar2(15) := 'canada';
  delivery_code varchar2(7) := 'H8N 3C4';
  return_code varchar2(7) := 'H8N 3E1';
begin
  insertRegisteredMail(mail_id, weight, postage, delivery_address, return_address,
    delivery_country, delivery_code, return_code);
end;


-- Unregistered Mail
CREATE OR REPLACE PROCEDURE insertUnregisteredMail(mail_id IN VARCHAR2, 
  weight IN NUMBER, postage IN NUMBER,
  deliveryAddress IN VARCHAR2, returnAddress IN VARCHAR2,
  deliveryCountry IN VARCHAR2, deliveryCode IN VARCHAR2, returnCode IN VARCHAR2)
AS
BEGIN 
  INSERT INTO unregisteredmail (mail_id, weight, postage, status, delivery_address,
  return_address, delivery_country, delivery_code, return_code)
  VALUES (mail_id, weight, postage, 'waiting', deliveryAddress, returnAddress,
  deliveryCountry, deliveryCode, returnCode);
END;

declare
  mail_id varchar2(5) := '69';
  weight number(6,2) := 100.00;
  postage number(5,2) := 1.80;
  delivery_address varchar2(50) := '69 who cares';
  return_address varchar2(50) := '100 boulevard of dreams';
  delivery_country varchar2(15) := 'canada';
  delivery_code varchar2(7) := 'H8N 3C4';
  return_code varchar2(7) := 'H8N 3E1';
begin
  insertUnregisteredMail(mail_id, weight, postage, delivery_address, return_address,
    delivery_country, delivery_code, return_code);
end;


-- obtain shipping cost based on weight and location
CREATE OR REPLACE FUNCTION postageShippingCost(weight IN NUMBER,
deliveryCountry IN VARCHAR2)
RETURN NUMBER
AS

cost NUMBER(6,2);
gramCost NUMBER(1);
rejectMail EXCEPTION;

BEGIN
-- Setting the price per gram.
IF (deliveryCountry = 'canada')
  THEN
    gramCost := 1;
ELSIF (deliveryCountry = 'usa')
  THEN
    gramCost := 2;
ELSE
    gramCost := 3;
END IF;

--Calculating the weight cost depending on location
    IF(weight > 0 AND weight <= 30)
      THEN 
        IF (gramCost = 1)
          THEN
            cost := 0.85;
        ELSIF (gramCost = 2)
          THEN
            cost := 1.20;
        ELSE
            cost := 2.50;
        END IF;
    ELSIF(weight > 30 AND weight <= 50)
      THEN
        IF (gramCost = 1)
          THEN
            cost := 1.20;
        ELSIF (gramCost = 2)
          THEN
            cost := 1.80;
        ELSE
            cost := 3.60;
        END IF;
    ELSIF(weight > 50 AND weight <= 100)
      THEN
        IF (gramCost = 1)
          THEN
            cost := 1.80;
        ELSIF (gramCost = 2)
          THEN
            cost := 2.95;
        ELSE
            cost := 5.90;
        END IF;
    ELSIF(weight > 100 AND weight <= 200)
      THEN
        IF (gramCost = 1)
          THEN
            cost := 2.95;
        ELSIF (gramCost = 2)
          THEN
            cost := 5.15;
        ELSE
            cost := 10.30;
        END IF;
    ELSIF(weight > 200 AND weight <= 500)
      THEN
        IF (gramCost = 1)
          THEN
            cost := 5.05;
        ELSIF (gramCost = 2)
          THEN
            cost := 10.30;
        ELSE
            cost := 20.60;
        END IF;
    ELSE
    -- The weight is greater than 500, in which we reject
        RAISE rejectMail;
END IF;
RETURN cost;

EXCEPTION
  WHEN rejectMail 
    THEN
      dbms_output.put_line('The mail is too heavy for our service!');

END;


declare
  weight number(6,2) := 100.00;
  country varchar2(15) := 'canada';
  cost number(5,2);
begin
  cost := postageShippingCost(weight, country);
  dbms_output.put_line(cost);
end;

-- Registered: Prepare mail's status to be either
-- 'Loaded', 'Delivered', 'Undeliverable', 'Pending'
CREATE OR REPLACE PROCEDURE mailStatusRegistered(mailid IN VARCHAR2,
  given_status IN VARCHAR2)
AS
BEGIN
  if (given_status IN ('waiting', 'delivered', 'loaded', 'undeliverable')) then
    UPDATE registeredmail 
    SET status = given_status
    WHERE mail_id = mailid;   
  end if;
END;

declare
  mid varchar2(5) := '11';
  stat varchar2(15) := 'this should not work';
begin
  mailStatusRegistered(mid, stat);
end;

-- Unregistered: Prepare mail's status to be either
-- 'Loaded', 'Delivered', 'Undeliverable', 'Pending'
CREATE OR REPLACE PROCEDURE mailStatusUnregistered(mailid IN VARCHAR2, 
  given_status IN VARCHAR2)
AS
BEGIN
  if (given_status IN ('waiting', 'delivered', 'loaded', 'undeliverable')) then
    UPDATE unregisteredmail 
    SET status = given_status
    WHERE mail_id = mailid;   
  end if;
END;

declare
  mid varchar2(5) := '11';
  stat varchar2(15) := 'loaded';
begin
  mailStatusUnregistered(mid, stat);
end;


-- Mark mail as sent to 'xxx' - REGISTERED
CREATE OR REPLACE PROCEDURE mailSentToRegistered(mailid IN VARCHAR2, officeid in varchar2)
AS
  postalDistrict VARCHAR2(7);
  officeDistrict varchar2(7);
  postalArea VARCHAR2(7);
  officeArea varchar2(7);
BEGIN
  SELECT SUBSTR(delivery_code, 1, 1) INTO postalDistrict FROM registeredmail
  WHERE mail_id = mailid;
  
  select SUBSTR(delivery_code, 2, 2) into postalArea from registeredmail
  where mail_id = mailid;
  
  select SUBSTR(forward_section_area, 1, 1) into officeDistrict from post_office
  where office_id = officeId;
  
  select SUBSTR(forward_section_area, 2, 2) into officeArea from post_office
  where office_id = officeId;
  
  if (postalDistrict = officeDistrict) then
    if (postalArea != officeArea) then
      update registeredmail set status = CONCAT(CONCAT('sent to', postalDistrict), postalArea)
      where mail_id = mailid;
    end if;
  else
    update registeredmail set status = 'sent to airport'
    where mail_id = mailid;
  end if;
END;

declare
  mid varchar2(5) := '10';
  oid varchar2(5) := '1';
begin
  mailSentToRegistered(mid, oid);
end;


-- Mark mail as sent to 'xxx' - UNREGISTERED
CREATE OR REPLACE PROCEDURE mailSentToUnregistered(mailid IN VARCHAR2, officeid in varchar2)
AS
  postalDistrict VARCHAR2(7);
  officeDistrict varchar2(7);
  postalArea VARCHAR2(7);
  officeArea varchar2(7);
BEGIN
  SELECT SUBSTR(delivery_code, 1, 1) INTO postalDistrict FROM unregisteredmail
  WHERE mail_id = mailid;
  
  select SUBSTR(delivery_code, 2, 2) into postalArea from unregisteredmail
  where mail_id = mailid;
  
  select SUBSTR(forward_section_area, 1, 1) into officeDistrict from post_office
  where office_id = officeId;
  
  select SUBSTR(forward_section_area, 2, 2) into officeArea from post_office
  where office_id = officeId;
  
  if (postalDistrict = officeDistrict) then
    if (postalArea != officeArea) then
      update unregisteredmail set status = CONCAT(CONCAT('sent to', postalDistrict), postalArea)
      where mail_id = mailid;
    end if;
  else
    update unregisteredmail set status = 'sent to airport'
    where mail_id = mailid;
  end if;
END;

declare
  mid varchar2(5) := '1';
  oid varchar2(5) := '2';
begin
  mailSentToUnregistered(mid, oid);
end;


-- view all mail by route id
create or replace procedure viewAllMailByRoute(routeid in varchar2)
as
  cursor crs1 is
    select * from registeredmail r
    join postal_code p on(r.delivery_code = p.code)
    where route_id = routeid;
    
  cursor crs2 is 
    select * from unregisteredmail u
    join postal_code p on(u.delivery_code = p.code)
    where route_id = routeid;
begin
  dbms_output.put_line('Regsistered mail:');
  for item in crs1 loop
    dbms_output.put_line('id: ' || item.mail_id);
    dbms_output.put_line('weight: ' || item.weight);
    dbms_output.put_line('postage: ' || item.postage);
    dbms_output.put_line('status: ' || item.status);
    dbms_output.put_line('delivery address: ' || item.delivery_address);
    dbms_output.put_line('return address: ' || item.return_address);
    dbms_output.put_line('delivery country: ' || item.delivery_country);
    dbms_output.put_line('delivery code: ' || item.delivery_code);
    dbms_output.put_line('return code: ' || item.return_code);
    dbms_output.put_line('');
  end loop;
  
  dbms_output.put_line('');
  
  dbms_output.put_line('Unregsistered mail:');
  for item in crs2 loop
    dbms_output.put_line('id: ' || item.mail_id);
    dbms_output.put_line('weight: ' || item.weight);
    dbms_output.put_line('postage: ' || item.postage);
    dbms_output.put_line('status: ' || item.status);
    dbms_output.put_line('delivery address: ' || item.delivery_address);
    dbms_output.put_line('return address: ' || item.return_address);
    dbms_output.put_line('delivery country: ' || item.delivery_country);
    dbms_output.put_line('delivery code: ' || item.delivery_code);
    dbms_output.put_line('return code: ' || item.return_code);
    dbms_output.put_line('');
  end loop;
end;

declare
  rid varchar2(5) := '1';
begin
  viewAllMailByRoute(rid);
end;

-- cursor for all mail by route
create or replace procedure viewAllMailByRouteCursor(routeid in varchar2, crs1 out sys_refcursor, crs2 out sys_refcursor)
as
begin
  open crs1 for
    select * from registeredmail r
    join postal_code p on(r.delivery_code = p.code)
    where route_id = routeid;
    
    open crs2 for
    select * from unregisteredmail u
    join postal_code p on(u.delivery_code = p.code)
    where route_id = routeid;
end;


-- view all mail by postal code
create or replace procedure viewAllMailByPostalCode(pc in varchar2)
as
  cursor crs1 is
    select * from registeredmail r
    where delivery_code = pc;
    
  cursor crs2 is 
    select * from unregisteredmail u
    where delivery_code = pc;
    
begin
  dbms_output.put_line('Regsistered mail:');
  for item in crs1 loop
    dbms_output.put_line('id: ' || item.mail_id);
    dbms_output.put_line('weight: ' || item.weight);
    dbms_output.put_line('postage: ' || item.postage);
    dbms_output.put_line('status: ' || item.status);
    dbms_output.put_line('delivery address: ' || item.delivery_address);
    dbms_output.put_line('return address: ' || item.return_address);
    dbms_output.put_line('delivery country: ' || item.delivery_country);
    dbms_output.put_line('delivery code: ' || item.delivery_code);
    dbms_output.put_line('return code: ' || item.return_code);
    dbms_output.put_line('');
  end loop;
  
  dbms_output.put_line('');
  
  dbms_output.put_line('Unregsistered mail:');
  for item in crs2 loop
    dbms_output.put_line('id: ' || item.mail_id);
    dbms_output.put_line('weight: ' || item.weight);
    dbms_output.put_line('postage: ' || item.postage);
    dbms_output.put_line('status: ' || item.status);
    dbms_output.put_line('delivery address: ' || item.delivery_address);
    dbms_output.put_line('return address: ' || item.return_address);
    dbms_output.put_line('delivery country: ' || item.delivery_country);
    dbms_output.put_line('delivery code: ' || item.delivery_code);
    dbms_output.put_line('return code: ' || item.return_code);
    dbms_output.put_line('');
  end loop;
end;

declare 
  pc varchar(7) := 'H8N 3C4';
begin
  ViewAllMailByPostalCode(pc);
end;

-- cursor for viewing all mail by postal code
create or replace procedure viewAllMailByPostalCodeCursor(pc in varchar2, crs1 out sys_refcursor, crs2 out sys_refcursor)
as
begin
  open crs1 for
    select * from registeredmail r
    where delivery_code = pc;
    
    open crs2 for
    select * from unregisteredmail u
    where delivery_code = pc;
end;

-- view all mail by address
create or replace procedure viewAllMailByAddress(ad in varchar2)
as
  cursor crs1 is
    select * from registeredmail r
    where delivery_address = ad;
    
  cursor crs2 is 
    select * from unregisteredmail u
    where delivery_address = ad;
    
begin
  dbms_output.put_line('Regsistered mail:');
  for item in crs1 loop
    dbms_output.put_line('id: ' || item.mail_id);
    dbms_output.put_line('weight: ' || item.weight);
    dbms_output.put_line('postage: ' || item.postage);
    dbms_output.put_line('status: ' || item.status);
    dbms_output.put_line('delivery address: ' || item.delivery_address);
    dbms_output.put_line('return address: ' || item.return_address);
    dbms_output.put_line('delivery country: ' || item.delivery_country);
    dbms_output.put_line('delivery code: ' || item.delivery_code);
    dbms_output.put_line('return code: ' || item.return_code);
    dbms_output.put_line('');
  end loop;
  
  dbms_output.put_line('');
  
  dbms_output.put_line('Unregsistered mail:');
  for item in crs2 loop
    dbms_output.put_line('id: ' || item.mail_id);
    dbms_output.put_line('weight: ' || item.weight);
    dbms_output.put_line('postage: ' || item.postage);
    dbms_output.put_line('status: ' || item.status);
    dbms_output.put_line('delivery address: ' || item.delivery_address);
    dbms_output.put_line('return address: ' || item.return_address);
    dbms_output.put_line('delivery country: ' || item.delivery_country);
    dbms_output.put_line('delivery code: ' || item.delivery_code);
    dbms_output.put_line('return code: ' || item.return_code);
    dbms_output.put_line('');
  end loop;
end;

declare
  address varchar2(50) := '3677 Elmside Avenue';
begin
  viewAllMailByAddress(address);
end;


-- cursor for viewing all mail by address
create or replace procedure viewAllMailByAddressCursor(ad in varchar2, crs1 out sys_refcursor, crs2 out sys_refcursor)
as
begin
  open crs1 for
    select * from registeredmail r
    where delivery_address = ad;
    
    open crs2 for
    select * from unregisteredmail u
    where delivery_address = ad;
end;