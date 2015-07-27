component {
  // property name="authenticator" inject="provider:webdav.authenticatorProvider";
  // add your own authenticator here!
  public any function authenticate (string username, string password) {
    // return authenticator.logUserIn(arguments.username,arguments.password);
  }
  public boolean function isUserAuthenticated() {
    // for demo purposes, return true for anonymous access
    return true;
    // return isUserLoggedIn();
  }
}