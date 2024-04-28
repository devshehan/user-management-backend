import ballerina/http;
import ballerina/sql;
import ballerina/time;
import ballerinax/postgresql;

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

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"]
    }
}
service / on new http:Listener(8080) {

    resource function get users() returns User[]|error {
        stream<User, sql:Error?> userStream = dbClient->query(`SELECT * FROM users`);
        return from var user in userStream
            select user;
    }

    resource function get user/[int id]() returns User|UserNotFound|error {

        User|sql:Error user = dbClient->queryRow(`SELECT * FROM users WHERE id = ${id}`);

        if user is sql:NoRowsError {
            UserNotFound userNotFound = {
                body: {
                    message: string `id ${id}`,
                    details: string `users/${id}`,
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

    resource function delete user/[int id]() returns http:NoContent|error {
        _ = check dbClient->execute(`DELETE FROM users WHERE id = ${id};`);
        return http:NO_CONTENT;
    }


    resource function put user/[int id](NewUser newUser) returns http:Response|error {
        
        sql:ParameterizedQuery query = `UPDATE users SET name = ${newUser.name},
                                                            user_name = ${newUser.userName},
                                                            email = ${newUser.email},
                                                            mobile_number = ${newUser.mobileNumber}
                                                            WHERE id = ${id}
                                                            `;
        
        sql:ExecutionResult|sql:Error result = dbClient->execute(query);

        http:Response response = new;
        if result is sql:ExecutionResult {
            if result.affectedRowCount > 0 {
                response.statusCode = 202; 
                response.setPayload("User updated successfully");
                response.setHeader("Access-Control-Allow-Origin", "*");
                return response;
            } else {
                return error("No user found with the id: " + id.toString());
            }
        } else {
            return error("Database error: " + result.message());
        } 
    }
}
