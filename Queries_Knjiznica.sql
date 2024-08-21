--kreiranje baze podataka

CREATE DATABASE Knjiznica

use Knjiznica

-- Kreiranje tablica

CREATE TABLE Clan (
	 clanski_broj INT NOT NULL 
				  PRIMARY KEY
				  CHECK (clanski_broj between 1 and 999999)
	,ime_clan NVARCHAR(50) NOT NULL
	,prezime_clan NVARCHAR(50) NOT NULL
	,adresa NVARCHAR (50)
	,mjesto NVARCHAR (50)
	,dat_rod DATE
	,dat_uclanjenja DATE
	)

CREATE TABLE Knjiga (
	ISBN CHAR(13) NOT NULL 
				  PRIMARY KEY
	,naslov NVARCHAR(100) NOT NULL
	,godina_izdanja DATE NOT NULL
	,ime_pisca NVARCHAR(50)
	,prezime_pisca NVARCHAR(50)
	)

CREATE TABLE Posudba (
	ID_posudbe INT NOT NULL
	,knjiga_isbn CHAR(13) FOREIGN KEY REFERENCES Knjiga(ISBN)
	,Clan_ID int FOREIGN KEY REFERENCES Clan(clanski_broj)
	,dat_posudbe DATE DEFAULT GETDATE()
	,dat_povratka DATE
	)

--Unošenje atributa u tablice--

INSERT INTO Clan (clanski_broj, ime_clan, prezime_clan, adresa, mjesto, dat_rod, dat_uclanjenja)
VALUES 
  (1, 'Ana', 'Anić', 'Franje Tuđmana 1', 'Zagreb', '2000-01-01', '2022-03-15'),
  (2, 'Ivan', 'Ivanić', 'Nikola Tesla 12', 'Split', '1995-05-10', '2020-11-25'),
  (3, 'Marko', 'Marković', 'Ruđer Bošković 8', 'Rijeka', '1988-12-20', '2019-08-17'),
  (4, 'Petra', 'Petrić', 'Josip Jelačić 5', 'Osijek', '1992-09-05', '2017-06-09'),
  (5, 'Luka', 'Lukić', 'Andrija Štampar 20', 'Zadar', '2005-04-15', '2021-12-30'),
  (6, 'Maja', 'Majić', 'Marija Jurić Zagorka 3', 'Pula', '1998-11-12', '2018-09-21'),
  (7, 'Ante', 'Antić', 'Tin Ujević 9', 'Dubrovnik', '2001-07-25', '2023-02-18'),
  (8, 'Iva', 'Ivić', 'Ivan Gundulić 15', 'Šibenik', '1990-03-30', '2016-04-12'),
  (9, 'Filip', 'Filipović', 'Faust Vrančić 17', 'Slavonski Brod', '2004-08-20', '2020-10-03'),
  (10, 'Lana', 'Lanić', 'Stjepan Radić 4', 'Karlovac', '1997-06-08', '2015-07-14');


INSERT INTO Knjiga (ISBN, naslov, godina_izdanja, ime_pisca, prezime_pisca)
VALUES 
  ('9789538095179', 'Alisa u zemlji čudesa', '2000-11-26', 'Lewis', 'Carroll'),
  ('9789532207819', 'Romeo i Julija', '1990-01-01', 'William', 'Shakespeare'),
  ('9789536850041', 'Igra prijestolja', '1996-08-01', 'G.R.R.', 'Martin'),
  ('9789537992040', '1984', '1992-06-08', 'George', 'Orwell'),
  ('9789532430586', 'Rat i mir', '1991-01-01', 'Lav', 'Tolstoj'),
  ('9789532209080', 'Ubiti pticu rugalicu', '1994-07-11', 'Harper', 'Lee'),
  ('9789536373839', 'Veliki Gatsby', '1999-04-10', 'F. Scott', 'Fitzgerald'),
  ('9789532092251', 'Dina', '2019-12-01', 'Frank', 'Herbert'),
  ('9789532226636', 'Mali princ', '1996-04-06', 'Antoine de', 'Saint-Exupéry'),
  ('9789539613313', 'Gospodar prstenova: Prstenova družina', '1994-07-29', 'J.R.R.', 'Tolkien');


 INSERT INTO Posudba ([ID_posudbe], [knjiga_isbn], [Clan_ID], [dat_posudbe], [dat_povratka]) 
 VALUES
 (1, '9789537992040', 10, '2023-03-16', '2023-03-25'),
 (2, '9789536850041', 7, '2023-03-18', '2023-04-25'),
 (3, '9789539613313', 5, '2023-04-18', null),
 (4, '9789536850041', 6, '2023-04-26', '2023-05-08'),
 (5, '9789536373839', 10, '2023-06-14', null),
 (6, '9789532430586', 3, '2023-06-15', '2023-06-23'),
 (7, '9789532092251', 6, '2023-06-17', '2023-06-28'),
 (8, '9789532226636', 1, '2023-06-23', null),
 (9, '9789537992040', 2, '2023-07-18', null),
 (10, '9789532207819', 4, '2023-07-20', null)


 -- kreiranje pogleda koji pokazuje knjige koje su slobodne za posudbu --

CREATE VIEW SlobodneKnjige 
AS
SELECT DISTINCT naslov AS naziv_knjige
FROM Knjiga k
LEFT OUTER JOIN Posudba p ON ISBN = knjiga_isbn
WHERE dat_povratka <= GETDATE() or dat_posudbe is null

SELECT *
FROM SlobodneKnjige

-- kreiranje okidača koji sprječava brisanje podataka iz tablice Posudba --

CREATE TRIGGER TR_PreventDeletePosudbeKnjiga
ON Posudba
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR ('Brisanje podataka iz tablice Posudba nije dopušteno.', 16, 1);
    ROLLBACK TRANSACTION;
END;

-- kreiranje korisnika ivica i dodavanje role db_datawriter

CREATE LOGIN ivica WITH PASSWORD = 'Pa$$w0rd';

USE Knjiznica;
CREATE USER Ivica FOR LOGIN ivica;

USE Knjiznica;
EXEC sp_addrolemember 'db_datawriter', 'ivica';




-- kreiranje pohranjene procedure koja kreira tablicu NEAKTIVNI i u nju kopira 
-- sve članove koji nisu nikada posudili nijednu knjigu, zatim iz tablice Članovi te iste članove briše

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
	WHERE ID_posudbe IS NULL
END

EXEC ObrisiNeaktivne

-- kreiranje rezervene kopije (backup) baze s nazivom knjiznica_bkp.bak

BACKUP DATABASE Knjiznica
TO DISK = 'D:\DBA\Seminar\Backup\knjiznica_bkp.bak'
