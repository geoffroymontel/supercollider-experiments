OSCFunc.trace(true, true);
OSCFunc.trace(false, true);
OSCdef.freeAll;

(
OSCdef.new(\stop1, {|msg, time, addr, recvPort| postf("stop1 : %\n",msg); }, '/departition/stop1');
OSCdef.new(\launch1, {|msg, time, addr, recvPort| postf("launch1 : %\n",msg); }, '/departition/launch1');
OSCdef.new(\multifader1_1, {|msg, time, addr, recvPort| postf("multifader1_1 : %\n",msg); }, '/departition/multifader1/1');
OSCdef.new(\multifader1_2, {|msg, time, addr, recvPort| postf("multifader1_2 : %\n",msg); }, '/departition/multifader1/2');
OSCdef.new(\multitoggle1_1, {|msg, time, addr, recvPort| postf("multitoggle1_1 : %\n",msg); }, '/departition/multitoggle1/1/1');
OSCdef.new(\multitoggle1_2, {|msg, time, addr, recvPort| postf("multitoggle1_2 : %\n",msg); }, '/departition/multitoggle1/1/2');
OSCdef.new(\multitoggle1_3, {|msg, time, addr, recvPort| postf("multitoggle1_3 : %\n",msg); }, '/departition/multitoggle1/1/3');
)

