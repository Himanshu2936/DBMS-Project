#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>

int x;
char query[200],temp;
PGresult *result;
PGconn *conn;

void ExecuteUpdate() {
    printf("Enter Insert/Update/Delete Query: ");
    scanf("%c",&temp);
    scanf("%[^\n]s",query);
    result = PQexec(conn, query); 
    
    if (PQresultStatus(result) != PGRES_COMMAND_OK) {
	printf("\nError: %s\n",PQerrorMessage(conn));
    }
    else {
	printf("Query executed Successfully.\n");
    }
    PQclear(result);
}

void ExecuteQuery() {
	
    printf("Enter Select Query: ");
    scanf("%c",&temp);
    scanf("%[^\n]s",query);
    result = PQexec(conn, query);    
    if (PQresultStatus(result) != PGRES_TUPLES_OK) {
        printf("\nError: %s\n",PQerrorMessage(conn));       
    }    
    else {
	int r = PQntuples(result);
        int c = PQnfields(result);
        printf("\n");
    	for(int i=0; i<r; i++) {    
    	    for (int j=0;j<c;j++) {
		    printf("%s\t",PQgetvalue(result, i, j));
    		}
		printf("\n");
	}    
    }
    PQclear(result);
}

int main() {
    conn = PQconnectdb("user=postgres password=abcd dbname=postgres");
    if (PQstatus(conn) == CONNECTION_BAD) {
        fprintf(stderr, "Connection to database failed: %s\n",PQerrorMessage(conn));
	exit(1);
    }
    PQexec(conn, "set search_path to 'OnlineMovieBookingPortal';");
    printf("Select one option: \n");
    printf("1: Insert/Update/Delete query\n");
    printf("2: Select query\n");
    printf("0: Exit\n");
    while(1)
    {
	printf("\nEnter Option: ");
    	fflush(stdin);
    	scanf("%d",&x);
    	printf("\n");
	if (x==1)
	    ExecuteUpdate();
	else if(x==2)	
	    ExecuteQuery();
	else
	    break;
    }
    PQfinish(conn);
    return 0;
}
