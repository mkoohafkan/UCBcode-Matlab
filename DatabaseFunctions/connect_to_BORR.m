function c = connect_to_BORR
%%initialize database connection and field names
dbName = 'borrdata' ;
dbUser ='postgres' ;
dbPassword = 'borr' ;
c = database(dbName, dbUser, dbPassword, ...
             'Vendor', 'PostGreSQL', ...
             'Server', 'LocalHost') ;
end