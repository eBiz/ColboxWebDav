/********************************************************************************
* Copyright Since 2015 eBiz UK UK LLC
* ebiz.uk
********************************************************************************
* WebDAV Module configurator
*/
component {

  this.title        = "WebDav";
  this.author       = "Tom Miller";
  this.webURL       = "https://ebiz.uk";
  this.description    = "This module provides WebDAV access";
  this.version      = "1.0.0";
  this.entryPoint     = "webdav";
  this.modelNamespace   = "webdav";
  this.cfmapping      = "webdav";

  function configure(){
    routes = [
      {
        pattern="/regex:(ini$)/",
        response="",
        statusCode=404
      },
      {
        pattern="/:anything?",
        handler="webdav",
        action={
          GET = "downloadFile",
          LOCK = "lock",
          UNLOCK = "unlock",
          MOVE = "move",
          PROPFIND = "list",
          DELETE = "delete",
          HEAD = "head",
          MKCOL = "createFolder",
          PUT = "create",
          LOCK = "lock",
          PROPPATCH  = "update",
          OPTIONS="list"
        }
      }
    ];
    interceptors = [
      {
        class="webdav.interceptors.WebDav",
        name="WebDav",
        properties={}
      }
    ];
  }
}
