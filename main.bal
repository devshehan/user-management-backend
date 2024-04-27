import ballerina/http;
import ballerina/time;
import ballerinax/postgresql;
import ballerina/sql;

type User record {|
    readonly int id;

    @sql:Column {name: "name"}
    string name;

    @sql:Column {name: "user_name"}
    string userName;
    
    @sql:Column {name: "email"}
    string email;

    @sql:Column {name: "mobile_number"}
    string mobileNumber;
|};

type NewUser record {|
    string name;
    string userName;
    string email;
    string mobileNumber;
|};

type ErrorDetails record {
    string message;
    string details;
    time:Utc timeStamp;
};

type UserNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

// DATABASE CONNECTION
postgresql:Client dbClient = check new ("localhost", "postgres", "1111", "userdb", 5432);

@http:ServiceConfig{
    cors: {
        allowOrigins: ["http://localhost:3000"]
    }
}
service / on new http:Listener(8080) {

    resource function get users() returns User[]|error {
        stream<User, sql:Error?> userStream = dbClient->query(`SELECT * FROM users`);
        return from var user in userStream select user;
    }

    resource function get users/[int id]() returns User|UserNotFound|error {

        User|sql:Error user = dbClient->queryRow(`SELECT * FROM users WHERE id: ${id}`);
        
        if user is sql:NoRowsError {
            UserNotFound userNotFound = {
                body: {
                    message: string `id ${id}`,
                    details: string `mesaki/users/${id}`,
                    timeStamp: time:utcNow()
                }
            };
            return userNotFound;
        }
        return user;
    }

    resource function post user(NewUser newUser) returns http:Created|error {

        sql:ParameterizedQuery query = `INSERT INTO users(name, user_name, email, mobile_number) VALUES 
                                                        (${newUser.name}, ${newUser.userName}, ${newUser.email}, ${newUser.mobileNumber})`;
        _ = check dbClient->execute(query);
        return http:CREATED;
    }
}
