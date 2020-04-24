# wifimodem
Swift port of wifi modem code. I choose to use swift because is as easy as python and  compiles in binary that run fast. My idea is start with a modem emulation and evolve in something better and usefull. 

Of course, this port can be compiled also under linux ( raspberry pi ) and you need to install the swift compiler on Raspberry. Please follow the [Marc Aupong guide](https://lickability.com/blog/swift-on-raspberry-pi/)

To play with the wifimodem you have to clone the repository and execute: 

```$ git https://github.com/ozw1z5rd/wifimodem.git
$ cd wifimodem
$ swiftc -DRASPBERRY *.swift          
``` 
This process will leave a main file that you can execute using:

```
./main
```
## Work status
There are several things that must work before to have the wifimodem working
- [X] - ~~TCP connection in swift that compiles in MacOS and Raspberry  without using external modules / libraries~~
- [ ] - Serial port control and serial port emulation for testing, both must run under MacOS and Raspberry
- [ ] - Ful working AT command parser
- [ ] - Wifi support(!) :sweat_smile: at the moment I'm using the cablated connection on raspberry and there is no way to change wifi network. Please note that my Raspberry reference hardware is the Raspberry Model B and I'm compiling using a Raspberry 3, so I can count on a cabled connection that is usefull is this development stage.
- [ ] - Raspberry disk image that allow the unit to boot and start the services.
- [ ] - led/display support
- [ ] - something even more usefull ... 

##Swift vs Python 
A lot of people think that Python is the best solution for raspberry, I have to say the truth: swift is really a good choice. There is no a huge community behind this language and this is sad because is really a good one. If you are so lucky to have a Mac, you can use the great XCode for free, which is fabulous to work with swift and this is the reason because this project is born inside Xcode.
If you are less lucky, you can use  [Microsoft's Visual Studio Code](https://code.visualstudio.com) that allow you to develop remotely on your raspberry.
About resource usage: simple projects like this runs with no issue on smaller raspberry, however, swift is a modern language and uses resource in "modern" sizes.
