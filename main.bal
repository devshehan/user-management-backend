import ballerina/http;
import ballerina/time;
import ballerinax/postgresql;
import ballerina/sql;

type User record {|
    readonly int id;
    string userName;
    string email;
    string mobileNumber;
|};

type NewUser record {|
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

service /mesaki on new http:Listener(8080) {

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

    resource function post users(NewUser newUser) returns http:Created|error {

        sql:ParameterizedQuery query = `INSERT INTO users(username, email, mobilenumber) VALUES 
                                                        (${newUser.userName}, ${newUser.email}, ${newUser.mobileNumber})`;
        _ = check dbClient->execute(query);
        return http:CREATED;
    }
}
