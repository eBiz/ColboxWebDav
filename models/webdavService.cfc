/********************************************************************************
* Copyright Since 2015 eBiz UK :TD
* ebiz.uk
********************************************************************************
*
*/
component {
  property name="daoProvider" inject="provider:tempDirectoryProvider@webdav";

  public Array function lockData() {
    return daoProvider.lockData();
  }

  public void function createFolder (String path) {
    daoProvider.createFolder(path);
  }

  public void function moveResource(String path, string destination) {
    daoProvider.moveResource(path,destination);
  }

  public Array function getObject(String path) {
    return daoProvider.getObject(path);
  }

  public any function getFile (string path,boolean getDetail=false) {
    return daoProvider.getFile(path,getDetail);
  }

  public Array function getChildren(String path) {
    return daoProvider.getChildren(path);
  }

  public any function getResource(String path, String getDetails="false") {
    return daoProvider.getResource(path,getDetails);
  }

  public boolean function deleteFile(String path) {
    return daoProvider.deleteFile(path);
  }

  public void function createFile (String path) {
    daoProvider.createFile(path);
  }

  public void function createFileContents(String path) {
    daoProvider.createFileContents(path);
  }
}