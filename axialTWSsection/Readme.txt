This is the MATLAB replica of OpenSees C++ class pinching4 by Jiazhen Leng.

Right now, the program can calculate the force response of a single DOF system with pinching4 material under specified displacement, like the case of displacement control tests.

Pincing4.m the main file. The user should specify all the parameters in another .m file as a struct and let main file to source it. There are several examples. Every .m file is commented for ease of reading. Users are welcome to look at the slides I created for more information and example plots.

*******************
In this version, Pinching4 is modified as a function to be called inside a main program. The input of Pinching4.m is still the struct and it returns the force. I created a simple main file to call Pinching4 and plot in the main.

Jiazhen