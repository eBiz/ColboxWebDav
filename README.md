# ColboxWebDav

This is a coldbox module to enable WebDAV access to your coldbox application.

## Tested on Luccee with Windows WebDAV client.

To use, simply drop the module into your application. By default, it has annoymous access and uses the lucee temp directory as
a base for file operations, however, in production we are using it with basic auth over SSL and are using it with a virtual
file system and MySQL.

##License

LGPL v2.1


## Getting started

To get started, there is a sample tempDirectoryProvider which provides WebDAV access to the lucee temp directory. This is for demo purposes only(!),
It's advisable to write your own provider - either fileSystem based provider, or Virtual File System provider.

* In your lucee temp directory, create a folder called webdav - this is the folder we'll be using for demo purposes.
* Map a network drive in windows to http://yourserver/webdav
* Enter a dummy username and password - it doesn't matter what at this point as we're returning true regardless of user/pass
* Create a folder and drag and drop some files, and dir/ls your lucee temp directory to make sure the files are appearing/editing/deleting properly.

## Notes.

* You need SES turned on, and proper re-writes with either nginx or tuckey.
* Turn off SES extention detection (or fiddle around with the code and add your extentions and prepend the rc.format var onto the path - this can get tricky, so we turned it off)
* Be careful of your rewrite rules. In tuckey, we added the following as we had disabled rewrites for static files. Obviously, you DO want static files to be passed to webdav (jpgs etc), so we did the following:
```xml
<condition type="request-uri" operator="notequal">^(?!\/webdav\/).+\.(bmp|gif|jpe?g|png|css|js|txt|pdf|doc|xls|xml|cfc|ico|php|asp|eot|otf|svg|ttf|woff|swf)$</condition>
```
In other words, do pass to coldbox if even if the extensions match if the URL starts with webdav.

## Other information

Currently it supports the following WebDAV protocols:

##### GET
Downloads a file.

##### PUT
Uses the body of the request to update an existing document, or, when the body is empty, creates a new document.

##### LIST
Lists the contents of a directory

##### MKCOL
Creates a new directory

##### DELETE
Deletes a file or directory

##### PROPFIND
Get properties for a file or directory

##### COPY
Copies a file or directory

##### MOVE
Moves or renames a file or directory

##### LOCK
Locks a file for editing

##### UNLOCK
Unlocks a file once editing is complete

