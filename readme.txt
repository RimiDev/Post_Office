Philippe Langlois-Pedroso 1542705 and Maxime Lacasse

**Users are not created at the start, within the test app there is commented data
that is used to populate the users table. In order to use the application this must be done.**

Running the application will present the user with the option of wither logging on or creating
a new account associated with their employee id. Depending on their role, they will
be presented with different actions. THe user will be provided a menu of options to take.
The source zip file will also contain a test class to test methods directly.

schema.sql -- Contains the SQL DDL statements.
data.sql -- Contains the SQL DML statements.
prcs -- The procs folder contains the sql files for procedures and triggers.
source.zip -- Contains the application code.


*There seems to be a bug in teh application when carriers try to see mail by building.
works when testing in oracle and the test app.*