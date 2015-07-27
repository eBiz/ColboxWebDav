# ColboxWebDav

This is a coldbox module to enable WebDAV access to your coldbox application.

## Tested on Luccee with Windows WebDAV client using SSL.

To use, simply drop the module into your application. By default, it has annoymous access and uses the lucee temp directory as
a base for file operations, however, in production we are using it with basic auth over SSL and are using it with a virtual
file system and a MySQL.

Currently it supports the following WebDAV protocols:

### GET
Downloads a file.

### PUT
Uses the body of the request to update an existing document, or, when the body is empty, creates a new document.

### LIST
Lists the contents of a directory

### MKCOL
Creates a new directory

### DELETE
Deletes a file or directory

### PROPFIND
Get properties for a file or directory

### COPY
Copies a file or directory

### MOVE
Moves or renames a file or directory

### LOCK
Locks a file for editing

### UNLOCK
Unlocks a file once editing is complete

