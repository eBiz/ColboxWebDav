component {

  public Array function lockData() {
    return [{
      "lockdiscovery": {
        "activelock": {
          "locktype": {
            "write":""
          },
          "lockscope": {
            "exclusive": ""
          },
          "depth": "infinity",
          "owner": "#GetAuthUser()#",
          "timeout": "Second-3559",
          "locktoken": {
            "href": "opaquelocktoken:#createUUID()#:#urlEncodedFormat(GetAuthUser())#"
          }
        }
      }
    }];
  }

  public void function createFolder (String path) {
    directoryCreate(getTempDirectory() & path)
  }

  private boolean function isResourceFile(string path) {
    return ((Len(ListLast(path,".")) gt 1 AND Len(ListLast(path,".")) lte 5) ? true : false);
  }

  public void function moveResource(String path, string destination) {
    destination = replace(destination,"https://","");
    destination = replace(destination,"http://","");
    destination = replace(destination,cgi.http_host,"");
    if (isResourceFile(arguments.path)) {
      // it's an operation on a file
      FileMove(getTempDirectory() & path, getTempDirectory() & destination);
    } else {
      if (ListLast(path, "/") != ListLast(destination, "/")) {
        // we're renaming a directory
        directoryRename(getTempDirectory() & path, getTempDirectory() & destination, true);
      } else {
        DirectoryCopy(source = getTempDirectory() & path, destination = getTempDirectory() & destination, recurse = true, createPath = true);
        directoryDelete(getTempDirectory() & path, true);
      }
    }
  }

  public any function getFile (string path) {
    return getTempDirectory() & path;
  }

  public Array function getObject(String path) {
    // get the current Item
    if (!isResourceFile(path)) {
      if (path == "") {
        // we need to return the root folder
        return [{
          "response": {
            "href": "/#arguments.path#",
            "properties": {
              "getcontenttype": "",
              "getcontentlength": "",
              "resourcetype": {
                "collection":""
              },
              "getlastmodified": "",
              "displayname": "ROOT",
              "getetag":"",
              "creationdate":""
            },
            "status":"HTTP/1.1 200 OK"
          }
        }];
      } else {
        if (NOT DirectoryExists(getTempDirectory() & path)) {
          return [];
        } else {
          return [{
            "response": {
              "href": "/#arguments.path#",
              "properties": {
                "getcontenttype": "",
                "getcontentlength": "",
                "resourcetype": {
                  "collection":""
                },
                "getlastmodified": "",
                "displayname": "#ListLast(path, "/")#",
                "getetag":"",
                "creationdate":""
              },
              "status":"HTTP/1.1 200 OK"
            }
          }];
        }

      }
    } else {
      if (NOT fileExists(getTempDirectory() & path)) {
        return [];
      } else {
        doc = getFileInfo(getTempDirectory() & path);
        return [{
          "response": {
            "href": "/#arguments.path#",
            "properties": {
              "getcontenttype": "#FileGetMimeType(getTempDirectory() & path)#",
              "getcontentlength": "#doc.size#",
              "resourcetype": "",
              "getlastmodified": "#DateTimeFormat(doc.lastModified,"ISO8601")#",
              "displayname": "#doc.name#",
              "getetag":"",
              "creationdate":"#DateTimeFormat(doc.lastModified,"ISO8601")#"
            },
            "status":"HTTP/1.1 200 OK"
          }
        }];
      }

    }

  }

  public Array function getChildren(String path) {
    // prop find on a folder
    var thisCategory = directoryList(getTempDirectory() & arguments.path,false,"query");
    var returnArray = getObject(arguments.path);
    loop query="thisCategory" {
      if (type == "dir") {
        returnArray.append({
          "response":{
            "href": "/#arguments.path#/#name#/",
            "properties": {
              "getcontenttype": "",
              "getcontentlength": "",
              "resourcetype": {
                "collection":""
              },
              "getlastmodified": "",
              "displayname": "#name#",
              "getetag":"",
              "creationdate":""
            },
            "status":"HTTP/1.1 200 OK"
          }
        });
      } else {
        returnArray.append({
          "response":{
            "href": "/#arguments.path#/#name#",
            "properties": {
              "getcontenttype": "#FileGetMimeType(getTempDirectory() & path)#",
              "getcontentlength": "#size#",
              "resourcetype": "",
              "getlastmodified": "#DateFormat(dateLastModified,'YYYY-MM-DD')#T#TimeFormat(dateLastModified,'HH:MM:SS')#Z",
              "displayname": "#name#",
              "getetag":"",
              "creationdate":"#DateFormat(dateLastModified,'YYYY-MM-DD')#T#TimeFormat(dateLastModified,'HH:MM:SS')#Z"
            },
            "status":"HTTP/1.1 200 OK"
          }
        });
      }
    }
    return returnArray;
  }

  public boolean function deleteFile(String path) {
    fileDelete(getTempDirectory() & path);
    return true;
  }

  public void function createFile (String path) {
    var folderPath = listDeleteAt(path,listLen(path,"/"),"/");
    fileWrite(getTempDirectory() & path,"");
  }

  public void function createFileContents(String path) {
    var inputStream = getPageContext().getHttpServletRequest().getInputStream();
    var fo = createObject("Java", "java.io.File");
    var fso = createObject("Java", "java.io.FileOutputStream");
    var tempFile = getTempDirectory() & path;
    fo.init(javacast("string",tempFile));
    fso.init(fo);
    var byteArray = repeatString(" ", 1000).getBytes();
    j = inputStream.read(byteArray);
    while (j != -1) {
      fso.write(byteArray, 0, j);
      j = inputStream.read(byteArray);
    }
    fso.close();
  }
}