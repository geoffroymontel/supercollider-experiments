/*
Monophonic Triplets (Ver 1.0)
by Joo Won Park (2017) : joowon@joowonpark.net
http://joowonpark.net/monotriple/

Instructions:
This code is for the "Conductor" computer. It controls up to 6 Singer computers that produces for sound and visuals
1. Open this code with SuperCollider  (http://supercollider.github.io/download)
2. In lines 20-25, edit the code so that ~ip1 to ~ip5 has the IP addresses for the Singer computer.
3. Open MonoTriplets-Singer.scd
4. Follow the instructions on MonoTriplets-Singer.scd
5. Once the GUI appears, go back to this file and select Menu->Language->Evaluate File
6. The computer is ready to perform. On the GUI window:
- Hit SPACEBAR to trigger a fast-changing noisy sound.
- Hit DELETE to trigger a relatively static pad
- The space bar and Delete can be used as many times as you want.
To stop the program, hit Command+Period(.) The graphics window on the conductor computer only will close.
*/

~ip0="127.0.0.1"; //Leave this IP address as 127.0.0.1 so that the conductor computer produces sound and visuals
~ip1="169.254.114.5"; //The IP address should begin and end with the " mark
~ip2="169.254.126.76";
~ip3="169.254.134.253";
~ip4="169.254.70.255";
~ip5="169.254.46.135";



//Do not edit below this line

~net0=NetAddr.new(~ip0, 57120);
~net1=NetAddr.new(~ip1, 57120);
~net2=NetAddr.new(~ip2, 57120);
~net3=NetAddr.new(~ip3, 57120);
~net4=NetAddr.new(~ip4, 57120);
~net5=NetAddr.new(~ip5, 57120);

/*
//\path, event on/off, whichevent, interval from the key,instrument specific  vol
//if whichevent ==7, peek
~net1.sendMsg(\event,1,15.rand,1,1);
~net1.sendMsg(\event,1,7,[0,7,12,19,24,31,36].choose,1);
~net1.sendMsg(\event,1,8,0,3);
*/

//space= keycode 49, backspace= keycode 51



~window2.view.keyDownAction = {
	arg view, char, modifiers, unicode, keycode;
	[char, unicode,keycode].postln;
	if (keycode==49,
		{
			~net0.sendMsg(\event,1,25.rand,1,1);
			~net1.sendMsg(\event,1,25.rand,1,1);
			~net2.sendMsg(\event,1,25.rand,1,1);
			~net3.sendMsg(\event,1,25.rand,1,1);
			~net4.sendMsg(\event,1,25.rand,1,1);
			~net5.sendMsg(\event,1,25.rand,1,1);
		},
		if(keycode==51,{
			~net0.sendMsg(\unevent,1,[7,8].choose,[0,7,12,19,24,31,36].choose,1);
			~net1.sendMsg(\unevent,1,[7,8].choose,[0,7,12,19,24,31,36].choose,1);
			~net2.sendMsg(\unevent,1,[7,8].choose,[0,7,12,19,24,31,36].choose,1);
			~net3.sendMsg(\unevent,1,[7,8].choose,[0,7,12,19,24,31,36].choose,1);
			~net4.sendMsg(\unevent,1,[7,8].choose,[0,7,12,19,24,31,36].choose,1);
			~net5.sendMsg(\unevent,1,[7,8].choose,[0,7,12,19,24,31,36].choose,1);
		})
	);
};

//command period thing
CmdPeriod.doOnce({
//net0 is local so window2.close
	~net1.sendMsg(\end,1);
	~net2.sendMsg(\end,1);
	~net3.sendMsg(\end,1);
	~net4.sendMsg(\end,1);
	~net5.sendMsg(\end,1);
	~window2.close;

});



