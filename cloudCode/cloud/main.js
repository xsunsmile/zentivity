
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
//Get sessionToken
//Input: email
//Output: session token
Parse.Cloud.define("getUserSessionToken", function(request, response) {
    Parse.Cloud.useMasterKey();

    var email = request.params.email;

    var query = new Parse.Query(Parse.User);
    query.equalTo("email", email);
    query.limit(1);
    query.find({
        success: function(user) {
            response.success(user[0].getSessionToken());
        },
        error: function(error) {
            response.error(error.description);
        }
    });
});