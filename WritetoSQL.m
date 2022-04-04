function WritetoSQL(maxpower,distance_output,flight_data_filename)

%Database Inputs
db_username = '';
db_password = '';
db_DataSource = 'MS SQL Server';

%Connect to the server
db_connection = database(db_DataSource, db_username, db_password);

%Obtain current time
t=datetime;

C={t, flight_data_filename,maxpower,distance_output};


%Create a numeric array
data=cell2table(C,"VariableNames",...
    ["Date_and_Time", "Flight_Data_File_Name","Max_Power","Distance_Output"]);

%Insert ModelCenter analysis Outputs to database table
tablename='Battery_Analyses';
sqlwrite(db_connection,tablename,data)

close(db_connection)