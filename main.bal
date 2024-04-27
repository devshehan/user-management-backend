import ballerina/http;
import ballerina/time;

type User record {|
    readonly int id;
    string userName;
    string email;
    string mobileNumber;
|};

table<User> key(id) users = table[
    { "id": 1, "userName": "Shehan", "email": "hello@gmai.com", "mobileNumber": "1234" },
    { "id": 2, "userName": "John", "email": "john@example.com", "mobileNumber": "5678" },
    { "id": 3, "userName": "Jane", "email": "jane@example.com", "mobileNumber": "9101" },
    { "id": 4, "userName": "Alice", "email": "alice@example.com", "mobileNumber": "1121" },
    { "id": 5, "userName": "Bob", "email": "bob@example.com", "mobileNumber": "3141" }
]
;

type ErrorDetails record {
    string message;
    string details;
    time:Utc timeStamp;
};

type UserNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

type NewUser record {|
    string userName;
    string email;
    string mobileNumber;
|};

service /mesaki on new http:Listener(8080) {

    // mesaki/users
    resource function get users() returns User[]|error {
        return users.toArray();
    }

    resource function get users/[int id]() returns User|UserNotFound|error {
        User? user = users[id];

        if user is () {
            UserNotFound userNotFound = {
                body: {
                    message: string `id: ${id}`,
                    details: string `/users/${id}`,
                    timeStamp: time:utcNow()
                }
            };
            return userNotFound;
        }
        return user;
    }

    resource function post users(NewUser newUser) returns http:Created|error {
        users.add({id: users.length()+1, ...newUser});
        return http:CREATED;
    }
}
