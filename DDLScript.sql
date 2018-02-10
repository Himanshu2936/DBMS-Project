DROP SCHEMA IF EXISTS  "OnlineMovieBookingPortal" CASCADE;
CREATE SCHEMA "OnlineMovieBookingPortal";
SET SEARCH_PATH TO "OnlineMovieBookingPortal";

CREATE TABLE "Movies" (
	"MovieID" integer,
	"MovieName" text NOT NULL,
	"Duration" integer NOT NULL,
	"ReleaseDate" date NOT NULL,
	"Certificate" char(3) NOT NULL,
	"IMDBRating" numeric(3,1),
	"UserRating" numeric(3,1) NOT NULL CHECK ("UserRating">=0.0 AND "UserRating"<=10.0),
	"TicketsSold" integer,
	"TotalEarnings" integer,
	PRIMARY KEY ("MovieID")
);

CREATE TABLE "Offers" (
	"OfferID" VARCHAR(20),
	"Benefit" text NOT NULL,
	"Coupon" VARCHAR(20),
	PRIMARY KEY ("OfferID")
);

CREATE TABLE "Franchise" (
	"FranchiseID" VARCHAR(20),
	"FranchiseName" VARCHAR(20) NOT NULL,
	PRIMARY KEY ("FranchiseID")
);

CREATE TABLE "Payment" (
	"PaymentID" char(2),
	"PaymentName" VARCHAR(20) NOT NULL,
	PRIMARY KEY ("PaymentID")
);

CREATE TABLE "MovieDirector" (
	"MovieID" integer,
	"DirectorName" VARCHAR(30),
	PRIMARY KEY ("MovieID","DirectorName"),
	FOREIGN KEY ("MovieID") REFERENCES "Movies"("MovieID")
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "MovieLanguage" (
	"MovieID" integer,
	"Language" VARCHAR(20),
	PRIMARY KEY ("MovieID","Language"),
	FOREIGN KEY ("MovieID") REFERENCES "Movies"("MovieID")
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "MovieGenre" (
	"MovieID" integer,
	"Genre" VARCHAR(20),
	PRIMARY KEY ("MovieID","Genre"),
	FOREIGN KEY ("MovieID") REFERENCES "Movies"("MovieID")
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "User" (
	"UserID" integer,
	"Password" VARCHAR(40) NOT NULL,
	"UserName" VARCHAR(40) NOT NULL,
	"DefaultPaymentMethod" VARCHAR(20),
	"DefaultLocation" VARCHAR(40),
	PRIMARY KEY ("UserID"),
	FOREIGN KEY ("DefaultPaymentMethod") REFERENCES "Payment"("PaymentID")
		ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE "UserFavoriteGenre" (
	"UserID" integer,
	"Genre" VARCHAR(20),
	PRIMARY KEY ("UserID","Genre"),
	FOREIGN KEY ("UserID") REFERENCES "User"("UserID")	
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "UserOffers" (
	"UserID" integer,
	"OfferID" VARCHAR(20),
	PRIMARY KEY ("UserID","OfferID"),
	FOREIGN KEY ("UserID") REFERENCES "User"("UserID")
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ("OfferID") REFERENCES "Offers"("OfferID")
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "UserRating" (
	"UserID" integer,
	"MovieID" integer,
	"Rating" numeric(2,0) CHECK("Rating">0 AND "Rating"<10),
	PRIMARY KEY ("UserID","MovieID"),
	FOREIGN KEY ("MovieID") REFERENCES "Movies"("MovieID")
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ("UserID") REFERENCES "User"("UserID")
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "MovieOffers" (
	"MovieID" integer,
	"OfferID" VARCHAR(20),
	PRIMARY KEY ("MovieID","OfferID"),
	FOREIGN KEY ("MovieID") REFERENCES "Movies"("MovieID")
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ("OfferID") REFERENCES "Offers"("OfferID")
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "FranchiseOffers" (
	"FranchiseID" VARCHAR(20),
	"OfferID" VARCHAR(20),
	PRIMARY KEY ("FranchiseID","OfferID"),
	FOREIGN KEY ("OfferID") REFERENCES "Offers"("OfferID")
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ("FranchiseID") REFERENCES "Franchise"("FranchiseID")
		ON DELETE CASCADE ON UPDATE CASCADE

);

CREATE TABLE "Theatre" (
	"TheatreID" integer,
	"TheatreName" VARCHAR(20) NOT NULL,
	"FranchiseID" VARCHAR(20) NOT NULL,
	"LocalAddress" text NOT NULL,
	"City" VARCHAR(20) NOT NULL,
	"State" VARCHAR(20) NOT NULL,
	PRIMARY KEY ("TheatreID"),
	FOREIGN KEY ("FranchiseID") REFERENCES "Franchise"("FranchiseID")
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "Screen" (
	"TheatreID" integer,
	"ScreenNo." integer CHECK ("ScreenNo.">0),
	"ScreenName" VARCHAR(20) NOT NULL,
	PRIMARY KEY ("TheatreID","ScreenNo."),
	FOREIGN KEY ("TheatreID") REFERENCES "Theatre"("TheatreID")
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "Seat" (
	"TheatreID" integer,
	"ScreenNo." integer CHECK ("ScreenNo.">0),
	"SeatNo." integer CHECK ("SeatNo.">0),
	"SeatType" char(1) NOT NULL,
	PRIMARY KEY ("TheatreID","ScreenNo.","SeatNo."),
	FOREIGN KEY ("TheatreID","ScreenNo.") REFERENCES "Screen"("TheatreID","ScreenNo.")
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "Shows" (
	"ShowID" integer,
	"TheatreID" integer NOT NULL,
	"MovieID" integer NOT NULL,
	"ScreenNo." integer NOT NULL,
	"Date" date NOT NULL,
	"Time" time NOT NULL,
	PRIMARY KEY ("ShowID"),
	FOREIGN KEY ("TheatreID") REFERENCES "Theatre"("TheatreID")
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ("MovieID") REFERENCES "Movies"("MovieID")
		ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE "Price" (
	"ShowID" integer,
	"SeatType" char(1),
	"Price" integer NOT NULL CHECK ("Price">0),
	PRIMARY KEY ("ShowID","SeatType"),
	FOREIGN KEY ("ShowID") REFERENCES "Shows"("ShowID")
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "Ticket" (
	"TicketID" integer,
	"SeatNo." integer NOT NULL CHECK ("SeatNo.">0),
	"SeatType" char(1) NOT NULL,
	"ShowID" integer NOT NULL,
	"UserID" integer NOT NULL,
	"BookingTime" time NOT NULL,
	"BookingDate" date NOT NULL,
	"PaymentID" char(2) NOT NULL,
	PRIMARY KEY ("TicketID"),
	FOREIGN KEY ("ShowID") REFERENCES "Shows"("ShowID")
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ("PaymentID") REFERENCES "Payment"("PaymentID")
		ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY ("UserID") REFERENCES "User"("UserID")
		ON DELETE RESTRICT ON UPDATE CASCADE

);