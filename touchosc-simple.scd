//********************************************************************//
//* This is a GUI example for the TouchOSC Simple Layout. Please     *//
//* make sureyou set the Port (outgoing) on 57120, it's the default  *//
//* SCLang Port. You can change it with the -u flag if necessary.    *//
//* Incoming Port would be 58100 in this example, but you can        *//
//* change that if you want.						             *//
//*					Wilm Thoben 2008				             *//
//********************************************************************//

(
var win, sliders=Array.newClear(5);
var adrs;
var xpos=0, ypos=0;

var resp1=Array.newClear(9);
var resp2=Array.newClear(20);
var resp3=Array.newClear(5);
var resp4=Array.newClear(68);

var toggle1=Array.newClear(4);
var toggle2=Array.newClear(4);
var toggle3=Array.newClear(4);
var toggle4=Array.newClear(4);

var pushb=Array.newClear(16);
var xyslider;
var multitog=Array.newClear(64);
var mess=Array.newClear(64);
var mess2=Array.newClear(64);

// choose your favourite GUI-Kit here
//GUI.swing; //don't forget to boot the SwingOSC Server
GUI.cocoa;

//insert your IPhone/Ipod Touch IP + Send Port here
adrs = NetAddr("192.168.1.102", 58100);

win = GUI.window.new("TouchOSC", Rect(10, 400, 970, 340));
win.view.background = Color(0.15,0.15,0.1);
win.front;

// PAGE 1

5.do({|i|
	if(i<4)
	{
	sliders.put(i, GUI.slider.new(win, Rect(10+xpos, 60, 30, 200))
					.knobColor_(Color(1,1,0.51))
					.background_(Color.grey)
					.value_(1)
					.action_({|view|
						//send messages, likewise on other pages
						adrs.sendMsg("/1/fader"++(i+1).asString, 1-view.value);
					});
	);
	}
	{
	sliders.put(i, GUI.slider.new(win, Rect(10, 10, 210, 30))
					.knobColor_(Color(0.6,0.8,0.8))
					.background_(Color.grey)
					.action_({|view|
						adrs.sendMsg("/1/fader"++(i+1).asString, view.value);
					});
	);
	};
	
	xpos=xpos+60;
	
	// receive messages with OSCresponderNode, likewise on other pages
	resp1.put(i, OSCresponderNode(nil, '/1/fader'++(i+1).asString, {|t, r, msg|
			if (i<4)
			{{sliders[i].value=1-msg[1]}.defer;}
			{{sliders[i].value=msg[1]}.defer;}		
			}).add;)
});

xpos=0;

4.do({|i|
	toggle1.put(i, GUI.button.new(win, Rect(10+xpos, 280, 30, 30))
		.states_([["", Color(0.6,0.8,0.8),Color.grey],["", Color.grey,Color(0.6,0.8,0.8)]])
		.action_({|view|
			adrs.sendMsg("/1/toggle"++(i+1).asString, view.value);
		});
	);
	
	xpos=xpos+60;
	resp1.put(i+5, OSCresponderNode(nil, '/1/toggle'++(i+1).asString, {|t, r, msg|
			{toggle1[i].value=msg[1]}.defer;
	}).add;);
});

xpos=0;

// PAGE 2

16.do({|i|
	pushb.put(i, GUI.button.new(win, Rect(255+xpos, 35+ypos, 35, 35))
					.states_([["", Color(1,1,0.51),Color.grey],["", Color.grey,Color(1,1,0.51)]])
					.action_({|view|
						adrs.sendMsg("/2/push"++(i+1).asString, view.value);
					});
	);
	
	xpos=(xpos+55).wrap(0, 219);

	case
		{i==3}	{ypos=55}
		{i==7}	{ypos=110}
		{i==11}	{ypos=165};
		
	resp2.put(i, OSCresponderNode(nil, '/2/push'++(i+1).asString, {|t, r, msg|
			{pushb[i].value=msg[1]}.defer;
	}).add;)

});

xpos=0;

4.do({|i|
	toggle2.put(i, GUI.button.new(win, Rect(250+xpos, 280, 30, 30))
		.states_([["", Color(0.6,0.8,0.8),Color.grey],["", Color.grey,Color(0.6,0.8,0.8)]])
		.action_({|view|
			adrs.sendMsg("/2/toggle"++(i+1).asString, view.value);
		});
	);
	
	xpos=xpos+60;
	
	resp2.put(i+16, OSCresponderNode(nil, '/2/toggle'++(i+1).asString, {|t, r, msg|
			{toggle2[i].value=msg[1]}.defer;
	}).add;)
});

xpos=0;

// PAGE 3

xyslider = GUI.slider2D.new(win, Rect(505,35,200,200))
			.background_(Color.grey)
			.knobColor_(Color(1,1,0.51))
			.y_(1)
			.action_({|view|
					adrs.sendMsg("/3/xy", view.x.value, 1-view.y.value);
			});

resp3.put(0, OSCresponderNode(nil, '/3/xy', {|t, r, msg|
			{xyslider.x_(msg[1]);xyslider.y_(1-msg[2])}.defer;
		}).add;
);
			
4.do({|i|
	toggle3.put(i, GUI.button.new(win, Rect(500+xpos, 280, 30, 30))
		.states_([["", Color(0.6,0.8,0.8),Color.grey],["", Color.grey,Color(0.6,0.8,0.8)]])
		.action_({|view|
			adrs.sendMsg("/3/toggle"++(i+1).asString, view.value);
		});
	);
	
	xpos=xpos+60;
	
	resp3.put(i+1, OSCresponderNode(nil, '/3/toggle'++(i+1).asString, {|t, r, msg|
			{toggle3[i].value=msg[1]}.defer;
	}).add;)
});			

xpos=0;ypos=0;

// PAGE 4

j=0;
64.do({|i|
	if (i%8==0) {j=j+1};
	mess.put(i, ("/4/multitoggle/"++((i+1).wrap(1,8)).asString++"/"++j.asString));
	mess2.put(i, ('/4/multitoggle/'++((i+1).wrap(1,8)).asString++'/'++j.asString));
	
	multitog.put(i,  GUI.button.new(win, Rect(750+xpos, 35+ypos, 20, 20))
		.states_([["", Color(1,1,0.51),Color.grey],["", Color.grey,Color(1,1,0.51)]])
		.action_({|view|
			adrs.sendMsg(mess[i], view.value);
		});
	);
	
	resp4.put(i, OSCresponderNode(nil, mess2[i], {|t, r, msg|
			{multitog[i].value=msg[1]}.defer;
	}).add);
	
	xpos=(xpos+25).wrap(0, 199);
	case
		{i==7}	{ypos=25}
		{i==15}	{ypos=50}
		{i==23}	{ypos=75}
		{i==31}	{ypos=100}
		{i==39}	{ypos=125}
		{i==47}	{ypos=150}
		{i==55}	{ypos=175};

});

4.do({|i|
	toggle4.put(i, GUI.button.new(win, Rect(745+xpos, 280, 30, 30))
		.states_([["", Color(0.6,0.8,0.8),Color.grey],["", Color.grey,Color(0.6,0.8,0.8)]])
		.action_({|view|
			adrs.sendMsg("/4/toggle"++(i+1).asString, view.value);
		});
	);
	
	xpos=xpos+60;
	
	resp4.put(i+64, OSCresponderNode(nil, '/4/toggle'++(i+1).asString, {|t, r, msg|
			{toggle4[i].value=msg[1]}.defer;
	}).add;)
});			

// REMOVE RESPONDERS (don't forget)

win.onClose_({
(resp1.size).do({|i| resp1[i].remove;});
(resp2.size).do({|i| resp2[i].remove});
(resp3.size).do({|i| resp3[i].remove});
(resp4.size).do({|i| resp4[i].remove});
});

)