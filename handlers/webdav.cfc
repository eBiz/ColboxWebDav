component {
  property name="webdavService" inject="provider:webdavService@webdav";
  property name="formatter" inject="provider:formatter@webdav";



  public void function list() {
    if (event.getHTTPHeader("Depth") == 0) {
      // get the current item
      rc.result = webdavService.getObject(rc.webDavPath);
    } else {
      // list the items children
      rc.result = webdavService.getChildren(rc.webDavPath);
    }
    if (rc.result.isEmpty()) {
      header statuscode = "404";
      header name = "DAV" value = "1,2";
      event.noRender();
    } else {
      rc.returnData = formatter.formatResult(rc.result);
      header statuscode = "207";
      header name = "DAV" value = "1,2";
      event.renderData(type = "PLAIN", data = rc.returnData, statusCode = "207", encoding = "UTF-8", contentType = "application/xml");
    }
  }
  public void function downloadFile() {
    rc.result = webdavService.getFile(rc.webDavPath);
    content file="#rc.result#" type="#FileGetMimeType('#rc.result#')#";
  }

  public void function head() {
    event.noRender();
  }

  public void function createFolder() {
    webdavService.createFolder(rc.webDavPath);
    header statuscode = "207";
    header name = "DAV" value = "1,2";
    event.renderData(type = "PLAIN", data = "", statusCode = "207", encoding = "UTF-8", contentType = "application/xml");
  }

  public void function move() {
    webdavService.moveResource(rc.webDavPath,event.getHTTPHeader("Destination"));
    event.noRender();
  }

  public void function blank () {
    event.noRender();
  }
  public void function create () {
    // create file/upload file return 201?
    rc.contentLength = event.getHTTPHeader("Content-Length", 0);
    if (rc.contentLength == 0) {
      // create the file
      webdavService.createFile(rc.webDavPath);
      header statuscode = "207";
      header name = "DAV" value = "1,2";
      event.noRender();
    } else {
      // upload the object
      webdavService.createFileContents(rc.webDavPath);
      header statuscode = "204";
      header name = "DAV" value = "1,2";
      event.noRender();
    }
    // get content length. If zero, create folder/file and return 201.
    event.noRender();
  }

  public void function update () {
    header statuscode = "200";
    header name = "DAV" value = "1,2";
    event.noRender();
  }

  public void function lock () {
    rc.lockData = webdavService.lockData();
    rc.returnData = formatter.lockResult(rc.lockData);
    header statuscode = "200";
    header name = "DAV" value = "1,2";
    event.renderData(type = "PLAIN", data = rc.returnData, statusCode = "200", encoding = "UTF-8", contentType = "application/xml");
  }
  public void function unlock () {
    rc.lockData = webdavService.lockData();
    rc.returnData = formatter.lockResult(rc.lockData);
    header statuscode = "200";
    header name = "DAV" value = "1,2";
    event.renderData(type = "PLAIN", data = rc.returnData, statusCode = "200", encoding = "UTF-8", contentType = "application/xml");
  }

  public void function delete () {
    rc.result = webdavService.deleteFile(rc.webDavPath);
    header statuscode = "200";
    header name = "DAV" value = "1,2";
    event.noRender();
  }
}