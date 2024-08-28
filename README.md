
This project involves the creation of a library management database named **Knjiznica**. The database includes the necessary tables, views, triggers, stored procedures, and a backup system to manage library members, books, and borrowings effectively.

## Database Structure

### 1. **Database Creation**
The database named **Knjiznica** is created using the following command:

```sql
CREATE DATABASE Knjiznica;
USE Knjiznica;
```

### 2. **Tables**

#### a. **Clan** (Members)
This table stores information about the library members.

- `clanski_broj`: INT, Primary Key, Member's ID, constrained between 1 and 999999.
- `ime_clan`: NVARCHAR(50), Member's first name.
- `prezime_clan`: NVARCHAR(50), Member's last name.
- `adresa`: NVARCHAR(50), Member's address.
- `mjesto`: NVARCHAR(50), Member's city.
- `dat_rod`: DATE, Member's birthdate.
- `dat_uclanjenja`: DATE, Membership date.

#### b. **Knjiga** (Books)
This table stores information about the books available in the library.

- `ISBN`: CHAR(13), Primary Key, Unique book identifier.
- `naslov`: NVARCHAR(100), Book title.
- `godina_izdanja`: DATE, Publication year.
- `ime_pisca`: NVARCHAR(50), Author's first name.
- `prezime_pisca`: NVARCHAR(50), Author's last name.

#### c. **Posudba** (Borrowings)
This table stores records of book borrowings by members.

- `ID_posudbe`: INT, Primary Key, Unique borrowing ID.
- `knjiga_isbn`: CHAR(13), Foreign Key referencing `Knjiga(ISBN)`.
- `Clan_ID`: INT, Foreign Key referencing `Clan(clanski_broj)`.
- `dat_posudbe`: DATE, Default to current date, Borrowing date.
- `dat_povratka`: DATE, Return date.

### 3. **Data Insertion**
Sample data is inserted into the **Clan**, **Knjiga**, and **Posudba** tables.

### 4. **Views**

#### a. **SlobodneKnjige**
A view that displays books available for borrowing, determined by checking if the return date is either null or past the current date.

```sql
CREATE VIEW SlobodneKnjige AS
SELECT DISTINCT naslov AS naziv_knjige
FROM Knjiga k
LEFT OUTER JOIN Posudba p ON ISBN = knjiga_isbn
WHERE dat_povratka <= GETDATE() or dat_posudbe is null;
```

### 5. **Triggers**

#### a. **TR_PreventDeletePosudbeKnjiga**
This trigger prevents the deletion of records from the **Posudba** table to maintain data integrity.

```sql
CREATE TRIGGER TR_PreventDeletePosudbeKnjiga
ON Posudba
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR ('Brisanje podataka iz tablice Posudba nije dopušteno.', 16, 1);
    ROLLBACK TRANSACTION;
END;
```

### 6. **Stored Procedures**

#### a. **ObrisiNeaktivne**
This stored procedure creates a new table called **Neaktivni** containing members who have never borrowed a book and then deletes these members from the **Clan** table.

```sql
CREATE PROCEDURE ObrisiNeaktivne AS
BEGIN
	SELECT Clan.*
	INTO Neaktivni
	FROM Clan
	LEFT JOIN Posudba ON clanski_broj = Clan_ID
	WHERE ID_posudbe IS NULL;
END

BEGIN
DELETE C
FROM Clan C
LEFT JOIN Posudba  ON Clan_ID = clanski_broj
	WHERE ID_posudbe IS NULL;
END;
```

### 7. **User and Roles**

A user `ivica` is created with the role `db_datawriter`, allowing the user to insert and modify data within the database.

```sql
CREATE LOGIN ivica WITH PASSWORD = 'Pa$$w0rd';

USE Knjiznica;
CREATE USER Ivica FOR LOGIN ivica;

USE Knjiznica;
EXEC sp_addrolemember 'db_datawriter', 'ivica';
```

### 8. **Database Backup**

A backup of the **Knjiznica** database is created and stored as `knjiznica_bkp.bak`.

```sql
BACKUP DATABASE Knjiznica
TO DISK = 'D:\DBA\Seminar\Backup\knjiznica_bkp.bak';
```

## Usage

To use this database, run the provided SQL script in your SQL Server environment. The script will create the database, tables, views, triggers, stored procedures, and insert initial data. It also creates a user and takes a backup of the database.

Ensure you have the necessary permissions to execute these commands.

## Author
This database schema was designed for managing a library's operations effectively, including member management, book cataloging, and borrowing processes.
