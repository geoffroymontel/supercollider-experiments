s.waitForBoot({
	~playersGroup = Group.tail(s);
	~groupPlayer1 = Group.tail(~playersGroup);
	~groupPlayer2 = Group.tail(~playersGroup);
	~groupPlayer3 = Group.tail(~playersGroup);
	~groupPlayer4 = Group.tail(~playersGroup);
	~groupPlayer5 = Group.tail(~playersGroup);
	~groupPlayer6 = Group.tail(~playersGroup);
	~groupPlayer7 = Group.tail(~playersGroup);
	~mixerGroup = Group.tail(s);

	~busPlayer1 = Bus.audio(s,2);
	~busPlayer2 = Bus.audio(s,2);
	~busPlayer3 = Bus.audio(s,2);
	~busPlayer4 = Bus.audio(s,2);
	~busPlayer5 = Bus.audio(s,2);
	~busPlayer6 = Bus.audio(s,2);
	~busPlayer7 = Bus.audio(s,2);

	~tempoClock = TempoClock.new(60/60);

	SynthDef(\mixer, {
		var snd;
		snd = In.ar(~busPlayer1, 2)
		+ In.ar(~busPlayer2, 2)
		+ In.ar(~busPlayer3, 2)
		+ In.ar(~busPlayer4, 2)
		+ In.ar(~busPlayer5, 2)
		+ In.ar(~busPlayer6, 2)
		+ In.ar(~busPlayer7, 2);
		snd = snd + (NHHall.ar(snd, rt60: 0.5) * -6.dbamp);
		snd = snd.tanh;
		Out.ar(0, snd);
	}).add;

	s.sync;
	Synth(\mixer, target: ~mixerGroup);
});
