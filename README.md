# wifimodem
Swift port of wifi modem code 

This port can be compiled also under linux ( raspberry pi ). 
Clone the repository and execute: 

 swiftc *.swift          
 
 Of course you need to install the swift compiler on Raspberry.
 
 import os does not work on raspberry, to you have to remove also all the usages of the os_log
 
 I'm using swift because is easy to use as Python and produces real binary executables. So on raspberry it is a good choice. I'm developping on a Apple Mac 
 and Xcode helps a log in writing swift programs. Anyway it is easy to get a good editor with swift support, like the Visual Studio Code from Microsoft.
 
 
I have to say that Apple and Microsoft did a great job that can be used to write superfast programs on Raspberry PI.

