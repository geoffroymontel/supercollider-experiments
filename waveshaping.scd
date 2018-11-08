// using signal.sign - signal

(
{
	var sig = Line.ar(-1,1,1);
	[sig, sig.sign - sig];
}.plot(1);
)

(
{
	var sig = Saw.ar(440);
	[sig, sig.sign - sig];
}.play;
)

// pow(3)

(
{
	var sig = Line.ar(-1,1,1);
	[sig, sig.pow(3)];
}.plot(1);
)

(
{
	var sig = Saw.ar(440);
	[sig, sig.pow(3)];
}.play;
)

// tanh

(
{
	var sig = Line.ar(-1,1,1);
	[sig, sig.tanh];
}.plot(1);
)

(
{
	var sig = Saw.ar(440);
	[sig, sig.tanh];
}.play;
)
