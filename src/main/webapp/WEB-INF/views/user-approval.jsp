<%@ page import="java.lang.System" %>
<html>
<%
String consumerKey = System.getenv("CANVAS_CONSUMER_KEY");
%>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Approve application</title>
    <script type="text/javascript" src="/resources/json2.js"></script>
    <script type="text/javascript" src="/resources/canvas-all.js"></script>
    <script type="text/javascript">

function clickHandler(e) {
            var loginUrl,
                consumerKey = "<%=consumerKey%>";
            if (!Sfdc.canvas.oauth.loggedin()) {
                // First, we retrieve the login url that is passed to the app in 
                // the query string of the app.
                loginUrl = Sfdc.canvas.oauth.loginUrl();
                if (Sfdc.canvas.isNil(loginUrl)){
                    alert("Unable to retrieve login url passed by the canvas framework.");
                    return false;
                }
                
                // We need the consumer key to perform the oauth flow.
                if (Sfdc.canvas.isNil(consumerKey)){
                    alert("Consumer key not specified in request.  Please provide the consumer key before trying to approve this application.");
                    return false;
                }
                
                // This uri is the outer parent window.
                Sfdc.canvas.oauth.login(
                        {uri : loginUrl,
                        params: {
                            response_type : "token",
                            client_id : consumerKey,
                            redirect_uri : encodeURIComponent("/callback.html")
                        }});
            }
            return false;
        }

        Sfdc.canvas(function() {
            if (!Sfdc.canvas.oauth.loggedin()) {
                var login    = Sfdc.canvas.byId("login");
                login.onclick=clickHandler;
            }
            else{
                Sfdc.canvas.client.repost(true);
            }
        });
    </script>
</head>
<body>
You must first approve this app<br/>
<a id="login" href="#">Approve</a>
</body>
</html>