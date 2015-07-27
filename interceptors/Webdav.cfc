/********************************************************************************
* Copyright Since 2015 eBiz UK UK LLC
* ebiz.uk
********************************************************************************
*
*/
component {
  /*
  ** Wire in the authenticator
  */
  property name="authenticator" inject="provider:authenticator@webdav";

  /*
  ** Capture the request - required for windows machines as they do
  ** an options request or propfind on the ROOT, and expect a result back.
  ** We do this and then cancel the rest of the request.
  */
  public void function onRequestCapture() {
    if (event.getHTTPMethod() == "OPTIONS" OR (event.getHTTPMethod() == "PROPFIND" AND event.getCurrentRoutedURL() == "")) {
      header name = "Accept-Ranges" value = "bytes";
      header statuscode = "207";
      header name = "DAV" value = "1,2";
      header name = "Allow" value = "PROPFIND, HEAD, DELETE, OPTIONS, PROPPATCH, OPTIONS, REPORT, HEAD, MKCOL, PUT, COPY, MOVE, LOCK, UNLOCK";
      event.noExecution();
    }
  }
  /*
  ** PreProcess interceptor - here we are merely running it when the module is called.
  */
  public void function preProcess (event) {
    var rc = event.getCollection();
    if (ListFirst(event.getCurrentEvent(),":") == "webdav") {

      // fix trailing slashes
      rc.webDavPath = reReplace(urlDecode(event.getCurrentRoutedURL()), "/$","","all" );
      /*
      ** WebDAV using basic auth sends a Authorization header with every request if one exists.
      ** If you want non-anonymous access to WebDAV you have to keep this section enabled.
      ** We are using basic authentication here as, which means usernames/passwords are sent in pretty much
      ** plain text. If using Windows, you MUST use SSL on your site and connect using https; firstly it's best
      ** practice, and also because Windows will not let you connect (you get stuck in an endless spiral of authentication.
      ** At least this is true in Windows 7/8. I'm not sure about XP because we haven't tested it.
      */
      if (event.getHTTPHeader("Authorization", "") != "") {
        var authHeader = event.getHTTPHeader("Authorization", "");
        encodedCredentials = ListLast(event.getHTTPHeader("Authorization", ""), " ");
        credentials = ToString(ToBinary(encodedCredentials));
        var username = ListFirst(credentials, ":");
        var password = ListLast(credentials, ":");
        /*
        ** do your own security validation here. Windows WebDAV client actually stores cookies,
        ** so we can check for a cookie/login session and only have to do the login procedure once.
        ** If the user isn't using a windows WebDAV client, unfortunately you have to do this every time if
        ** you want to secure your app. Therefore, you need to make this part speedy (ideally leverage heavy caching).
        ** WebDAV by it's nature is very "chatty", so optimising performance is a priority.
        */

        if (!authenticator.isUserAuthenticated()) {
          authenticator.authenticate(username, password);
        }
      } else {
        /*
        ** No Authorization header exists, so if you want your app secured, you have to prompt
        ** for authorization.
        */
        if (!authenticator.isUserAuthenticated()) {
          event.setHTTPHeader(name = "WWW-Authenticate", value = "basic realm=""webdav""");
          event.renderData(data = "", statusCode = "401", statusText = "Unauthorized").noExecution();
        }
      }
    }
  }
}