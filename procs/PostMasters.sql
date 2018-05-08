-- Logging in: List of all (non-empty) routes that don't have a carrier/vehicle assigned
-- for today or tomorrow
CREATE OR REPLACE PROCEDURE viewNonOccupiedRoutes(routeCursorToday OUT sys_refcursor)
AS
BEGIN

OPEN routeCursorToday FOR
SELECT route_id FROM route r 
JOIN schedule s using (schedule_id) 
WHERE s.emp_id is not null;

END;

DECLARE

BEGIN
  dbms_output.put_line(to_date(SYSDATE, 'dd-mm-yy'));
END;

--Create a new empty mail route
CREATE OR REPLACE PROCEDURE createEmptyRoute(
nameIn IN VARCHAR2)
AS

lastRouteId VARCHAR2(5);

BEGIN

SELECT COUNT(route_id) INTO lastRouteId FROM route;

INSERT INTO route (route_id, name, last_delivery, status)
VALUES (lastRouteId+1, nameIn, NULL, 'not started');

END;

DECLARE
name VARCHAR2(50) := 'test';
BEGIN
  createEmptyRoute(name);
END;

CREATE OR REPLACE PROCEDURE addPostalCodeFromRoute (routeId IN VARCHAR2, postalCode IN VARCHAR2)
AS
BEGIN
  UPDATE postal_code
  SET route_id = routeId
  WHERE code = postalCode;
END;

DECLARE
rid VARCHAR2(5) := '2';
postal VARCHAR2(7) := 'H8N 3E1';
BEGIN
  addPostalCodeFromRoute(rid, postal);
END;

CREATE OR REPLACE PROCEDURE removePostalCodeFromRoute(postalCode IN VARCHAR2)
AS
BEGIN
  UPDATE postal_code
  SET route_id = NULL
  WHERE code = postalCode;
END;

DECLARE
rid VARCHAR2(7) := 'L4T 4I5';
BEGIN
  removePostalCodeFromRoute(rid);
END;

--Add new employees and associated accounts
CREATE OR REPLACE PROCEDURE addEmployee(empId IN VARCHAR2, firstName IN VARCHAR2, lastName IN VARCHAR2,
role IN VARCHAR2, phoneNumber IN VARCHAR2, email IN VARCHAR2)
AS

BEGIN

INSERT INTO post_employee (emp_id, first_name, last_name, role, dayoff, phone_number, email)
VALUES (empId, firstName, lastName, role, NULL, phoneNumber, email);

END;

DECLARE
eid VARCHAR2(5) := '69';
firstName VARCHAR2(30) := 'Jimmy';
lastName VARCHAR2(30) := 'Brown';
role VARCHAR2(30) := 'clerk';
phoneNumber VARCHAR2(15) := '819-822-1069';
email VARCHAR2(50) := 'jimmybrown@hotmail.com';
BEGIN
  addEmployee(eid,firstName,lastName,role,phoneNumber,email);
END;

--Remove employees, --> carriers should be removed from all routes
CREATE OR REPLACE PROCEDURE removeEmployee(empid IN VARCHAR2)
AS
empSchedule VARCHAR2(5);
BEGIN

  DELETE FROM post_employee
  WHERE emp_id = empid;

END;

DECLARE
eid VARCHAR(5) := '69';
BEGIN
  removeEmployee(eid);
END;

CREATE OR REPLACE PROCEDURE setUpRoute(empId IN VARCHAR2, vehicleId IN VARCHAR2,
routeId IN VARCHAR2)
AS

vehicleStatus VARCHAR2(15);
dayoff date;
vehicleNonUsable EXCEPTION;
employeeNotAvailable EXCEPTION;

BEGIN

SELECT status into vehicleStatus FROM vehicle
WHERE vehicle_id = vehicleId;

IF(vehicleStatus != 'available')
    THEN
        RAISE vehicleNonUsable;
END IF;

SELECT dayoff into dayoff FROM post_employee
WHERE emp_id = empId;

IF(dayoff = SYSDATE)
  THEN
    RAISE employeeNotAvailable;
END IF;




EXCEPTION
WHEN vehicleNonUsable
    THEN   
        dbms_output.put_line('The vehicle is not available for use!');
WHEN employeeNotAvailable
  THEN
    dbms_output.put_line('The employee is not available!');
END;

DECLARE
eid VARCHAR(5) := '5';
vid VARCHAR(5) := '1';
BEGIN
  setUpRoute(eid, vid);
END;

CREATE OR REPLACE PROCEDURE modifyVehicleStatus (vehicleId IN VARCHAR2, statusIn IN VARCHAR2)
AS

BEGIN

UPDATE vehicle
SET status = statusIn
WHERE vehicle_id = vehicleId;

END;

DECLARE
vid VARCHAR2(5) := '3';
st VARCHAR2(30) := 'available';
BEGIN
  modifyVehicleStatus(vid, st);
END;




