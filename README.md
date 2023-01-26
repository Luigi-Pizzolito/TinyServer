# TinyServer
A lightweight simple web server with a GUI.

![GUI Image](https://luigi-pizzolito.github.io/TinyServer/pictures/GUI.png)

#### This is based on Jibble Web Server
[Check out the original page here](http://www.jibble.org/jibblewebserver.php)

## Contents
* [Introduction](#introduction)
* [Features](#features)
* [Content Type Support](#content-type-support)
* [Directory Browsing and Index Pages](#directory-browsing-and-index-pages)
* [Server Side Includes](#server-side-includes)
* [Server Side Scripting](#server-side-scripting)
* [Logging](#logging)
* [Who Made it?](#who-made-it)

### Introduction
TinyServer is a MacOS app that acts as a GUI interface for Jibble Web Server. It makes it simple to use with no command-line required. Simultaneously adding a couple more features...
Jibble Web Server is an extremely small web server written in Java.  It correctly supports a variety of file types, allowing delivery of multimedia web content and allows many HTTP requests to be dealt with simultaneously.

### Features
* Easy-to-use interface
* Notification alerts when server starts/stops/crashes
* Tiny for a web server with a GUI (10MB)
* Supports SSI (Server Side Includes) [Limited]
* Supports SSS (Server Side Scripting) [in cgi-bin folder]
* Can deal with multiple requests at the same time
* Support for a variety of content-types
* Directory Browsing included
* Index page retrieval without specifying full path
* Request logging
* Log can be exported to .log file
* Portable (The web server root can be set, only requires Java)
* 100% Open Source

### Content Type Support
The webserver supports these content types:

**Content type** | **Recognised filename extensions**
---|---
application/postscript | ai ps eps
application/rtf | rtf
audio/basic	au | snd
application/octet-stream | bin dms lha lzh exe class
application/msword | doc
application/pdf | pdf
application/powerpoint | ppt
application/smil | smi smil sml
application/x-javascript | js
application/zip | zip
audio/midi | midi kar
audio/mpeg | mpga mp2 mp3
audio/x-wav | wav
image/gif | gif
image/ief | ief
image/jpeg | jpeg jpg jpe
image/png | png
image/tiff | tiff tif
model/vrml | wrl vrml
text/css | css
text/html | html htm shtml shtm stm sht
text/plain | txt inf nfo
text/xml | xml dtd
video/mpeg | mpeg mpg mpe
video/x-msvideo | avi

Any unrecognised file types will be delivered with the application/octet-stream content type.

### Directory Browsing and Index Pages
Accessing a directory via the web server will present you with a browsable directory listing of all files in the logical web directory.  Users will be prevented from obtaining any directory listings or viewing any files that are not reachable by descending from the web root directory.

The exception to this is if the directory contains a file recognised to be an index page, in which case the contents of that file will be delivered to the client.

The known index page names are (in order): -

1. index.html
2. index.htm
3. index.shtml
4. index.shtm
5. index.stm
6. index.sht

### Server Side Includes
The web server provides limited SSI support in the form of the "#include" element.  Any file with an extension of .shtml, .shtm, .stm or .sht will be processed by the SSI engine.  Such pages may include the "#include file" directive in order to include the contents of another file on the page.  If the included file also has a recognised SSI filename extension, then it too will be processed.  The inclusion process will be cleanly halted if a circular inclusion pattern is detected.

To include another file on a page with this web server, you must use the exact following syntax: -

```<!--#include file="filename.inc" -->```

This will caused the comment to be replaced with the contents of the file called filename.inc before it is delivered to the client.

Please note that all filenames must be relative to the location of the SSI page from which they are included.  It is also important to note that files outside of the web root directory may also be included.  This is only meant to be a personal web server, so that feature has been provided to make it easier for you to include files from other places on the same disk partition.

### Server Side Scripting
Server-side scripting allows a web server to deliver dynamic pages.  These are typically generated on-the-fly by running a script on the web server in order to produce HTML dynamically.  This web server supports the execution of scripts if their path under the web root directory contains the string "cgi-bin".  All scripts must be executable in order to be processed by the web server. You can test that the server-side scripting works by placing the following batch file in a directory called cgi-bin: -
**cgi-test.command**
```
echo Content-Type: text/html
echo
echo If you can read this, then your CGI jibble is set up properly!
echo \<p\>Server variables: -
echo \<pre\>
set
```
To try out the above script, make sure it is saved in a directory called cgi-bin, under your web root directory, and that it is executable (`chmod +x`).  Now if you access this file via a web browser, rather than seeing the contents of the file, you should (fingers crossed!) see the output from executing the batch file.  This should give you a page that displays the text "If you can read this, then your CGI jibble is set up properly!", followed by a list of the server variables.  These typically show you what sort of web browser the client is using, etc.

### Logging
All HTTP requests, whether successful or not, will be logged to the standard output.  You may find it useful to redirect this to a file for later analysis.

Each log entry is time stamped and is in the following format: -
```
[Sat Dec 08 20:16:25 GMT 2001] 127.0.0.1 "GET / HTTP/1.1" 200
```
Each line in the log consists, in order, of a timestamp, the I.P. address of the remote host, the raw request and finally a number to represent the status of the request.

Typical request status values: -

**Code** | **Meaning**
---|---
200	| OK
403	| Forbidden
404	| File Not Found
405	| Method Not Allowed
000	| Reserved for error messages from the web server


### Who Made it?
Jibble Web Server was made by Paul Mutton, who wanted a simple and small web server to be able to deliver web pages and other content from nearly any platform.
The GUI 'TinyServer' was made by Luigi Pizzolito, who wanted a neat interface for this awesomely developed web server.

### License
http://www.jibble.org/licenses/gnu-license.php
