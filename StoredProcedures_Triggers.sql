SET SEARCH_PATH TO "OnlineMovieBookingPortal"; 

--stored procedure to see seat availabity for a particular show
DROP TYPE IF EXISTS availability;
DROP FUNCTION IF EXISTS seat_aval(integer);

CREATE TYPE availability AS( 
seatno smallint,
seattype char );
  
CREATE OR REPLACE FUNCTION seat_aval(showid integer) 
RETURNS setof availability AS 
$$ 
DECLARE
	cus1 refcursor; 
	cus2 refcursor; 
	rec1 availability%rowtype;
	rec2 availability%rowtype;
	x integer;
BEGIN 
	  x:=1;
	  FOR rec1 in SELECT "SeatNo.","SeatType" FROM (SELECT "ShowID", "TheatreID", "ScreenNo." FROM "Shows" WHERE "ShowID" = showid) as e NATURAL JOIN "Seat" 
	  LOOP  
		x:=1;
		FOR rec2 in SELECT "SeatNo.", "SeatType" FROM (SELECT "ShowID" FROM "Shows" WHERE "ShowID" = showid) as showID NATURAL JOIN "Ticket"
		LOOP 
			IF rec1=rec2 THEN
				x:=0; 
			END IF; 
		END LOOP; 
		IF x=1 THEN
		RETURN NEXT rec1;
		END IF;
	  END LOOP;
RETURN; 
END $$ LANGUAGE plpgsql;





--Trigger To impose constraint on IMDBRating(NULL for upcoming movies and between 0 to 10 for released movies) in "Movies" Table when a new entry is done.

set search_path to "OnlineMovieBookingPortal";
CREATE  OR REPLACE FUNCTION process_update_ticketSoldAndEarnings()
	RETURNS TRIGGER AS $update_ticketsSoldAndEarnings$
DECLARE 
    rate integer;
    rdate date;
    
BEGIN
    IF(TG_OP = 'INSERT') THEN 
        IF(current_date >= NEW."ReleaseDate") THEN 
            IF(NEW."IMDBRating"<0.0 OR NEW."IMDBRating">10.0) THEN
            		Raise Notice '%','Invalid Rating';
                RETURN NULL;
		END IF;
            END IF;
    END IF;
    RETURN NEW;
END $update_ticketsSoldAndEarnings$ LANGUAGE 'plpgsql';


CREATE TRIGGER update_IMDBRating
BEFORE INSERT ON "Movies"
	FOR EACH ROW EXECUTE PROCEDURE update_ticketsSoldAndEarnings();



--Trigger for calculating total tickets sold and earnings for movie

set search_path to "OnlineMovieBookingPortal";
CREATE  OR REPLACE FUNCTION process_update_ticketSoldAndEarnings()
	RETURNS TRIGGER AS $BODY$
DECLARE 
    n integer;
    movieID "Movies"."MovieID"%type;
    rec "Movies"%rowtype;
BEGIN
    IF (TG_OP = 'INSERT') THEN
    
        SELECT "Price" FROM (SELECT "ShowID", "SeatType" FROM "Ticket" WHERE "ShowID" = NEW."ShowID" AND "SeatType" = NEW."SeatType") as x NATURAL JOIN "Price" INTO n;
        SELECT "MovieID" FROM (SELECT "ShowID" FROM "Ticket" WHERE "ShowID" = NEW."ShowID") as y NATURAL JOIN "Shows" INTO movieID;
        FOR rec IN SELECT * FROM "Movies"
        LOOP
            IF (rec."MovieID" = movieID) THEN 
                UPDATE "Movies" SET "TicketsSold" = ("TicketsSold" + 1) WHERE rec."MovieID" = movieID;
            
                UPDATE "Movies" SET "TotalEarnings" = ("TotalEarnings" + n) WHERE rec."MovieID" = movieID;
            END IF;
        END LOOP;
        
    END IF;
    RETURN NEW;
END $BODY$ LANGUAGE 'plpgsql';


CREATE TRIGGER update_movies
AFTER INSERT OR UPDATE OR DELETE ON "Ticket"
	FOR EACH ROW EXECUTE PROCEDURE process_update_ticketSoldAndEarnings();



	
	
	
--Trigger to update user rating
CREATE  OR REPLACE FUNCTION process_update_user_rating()
	RETURNS TRIGGER AS $update_user_rating$
DECLARE 
    n float;
BEGIN
    
    IF (TG_OP = 'INSERT') THEN
        SELECT count("UserID") FROM "UserRating" WHERE "MovieID" = NEW."MovieID" INTO n;
        n=n-1;
        IF n=0 THEN
            n=1;
        END IF;
        UPDATE "Movies" SET "UserRating" = ("UserRating"*n + NEW."Rating")/(n+1) WHERE "Movies"."MovieID" = NEW."MovieID" ;
    ELSEIF (TG_OP = 'UPDATE') THEN            
        UPDATE "Movies" SET "UserRating" = ("UserRating") + (NEW."Rating"-OLD."Rating")/n WHERE "Movies"."MovieID" = NEW."MovieID";
        End IF;
    RETURN NEW;
 
END $update_user_rating$ LANGUAGE 'plpgsql';

CREATE TRIGGER update_user_rating
AFTER INSERT OR UPDATE OR DELETE ON "UserRating"
	FOR EACH ROW EXECUTE PROCEDURE process_update_user_rating();
	
	
	
	
