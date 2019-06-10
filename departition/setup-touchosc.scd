// set multitoggle to N
(1..7).do { |player|
	~iPadNetAddr.sendMsg("/departition/multitoggle"++player++"/1/1",1);
	~iPadNetAddr.sendMsg("/departition/multitoggle"++player++"/1/2",0);
	~iPadNetAddr.sendMsg("/departition/multitoggle"++player++"/1/3",0);
}
