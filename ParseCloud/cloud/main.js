
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:


Parse.Cloud.define("Pricealert", function(request, response) {
                   
                   var query = new Parse.Query("Watchlist");
                   query.equalTo("Stockcode", request.params.Stockcode);
                   query.first({
                              success: function(result)
                              
                              {
                              var queryPush = new Parse.Query(Parse.Installation);
                              
                              Parse.Push.send({
                                              where: queryPush, // Set our Installation query
                                              data: {
                                              alert: request.params.Stkname + " has reached the Price " + result.get("Price")
                                              }
                                              },{
                                              success: function() {
                                                response.success();
                                              // Push was successful
                                              },
                                              error: function(err) {
                                              response.error(err);
                                              }
                                              });
                              }});
                   });