{SinOsc.ar(freq:MouseX.kr(100,2000),mul:MouseY.kr(0,1))}.play;

(
{SinOsc.ar(freq:MouseX.kr(100,400),mul:MouseY.kr(0,1))}.play;
{SinOsc.ar(freq:MouseX.kr(200,600),mul:MouseY.kr(0,1))}.play;
{SinOsc.ar(freq:MouseX.kr(300,800),mul:MouseY.kr(0,1))}.play;
)

(
{VarSaw.ar(freq:MouseX.kr(20,500),width:MouseX.kr(),mul:MouseY.kr(0,1))}.play;
{VarSaw.ar(freq:MouseX.kr(300,100),width:MouseX.kr(),mul:MouseY.kr(0,1))}.play;
)