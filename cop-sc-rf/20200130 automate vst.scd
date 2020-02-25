// install https://git.iem.at/pd/vstplugin/-/releases
// in your Platform.userExtensionDir folder
SCDoc.indexAllDocuments(clearCache: true)

Platform.userExtensionDir;

VSTPlugin.search;
VSTPlugin.pluginList;

// list all plugin keys
(
VSTPlugin.pluginKeys.do { |i|
	i.postln;
}
)

// Stereo VSTi SynthDef
(
SynthDef(\vsti, { |bus = 0|
	Out.ar(bus, VSTPlugin.ar(nil, 2));
}).add;
)

// test
~synth = Synth(\vsti);
~plugin = VSTPluginController(~synth);
~plugin.browse;
~plugin.open("TyrellN6", editor: true);
~plugin.editor(show: true);

// list VSTi parameters
~allPlugins = VSTPlugin.plugins(s);
(
~allPlugins.at('TyrellN6').parameters.do { |param|
	postf("% || %\n", param['name'], param['label']);
};
)

// play notes
(
p = Pbind(*[
	type: \vst_midi,
	vst: ~plugin,
	midinote: Pseq([40,42]*2, inf),
	dur: 1,
	legato: 1.0,
]).play;
)

p.stop

// get and set filter cutoff

~plugin.get('Tyrell: Cutoff', { |f| f.postln; });
~plugin.set('Tyrell: Cutoff', 1.0.rand.postln);
~plugin.get('Tyrell: Cutoff', { |f| f.postln; });

// automate filter with vst_set

(
q = Pbind(*[
	type: \vst_set,
	vst: ~plugin,
	params: ['Tyrell: Cutoff'],
	'Tyrell: Cutoff': Pseq([0,1], inf),
	dur: 0.2
]).play;
)

q.stop;

// play notes and change filter at the same time
// does not work

(
p = Pbind(*[
	type: \vst_midi,
	vst: ~plugin,
	midinote: Pseq([40,42]*2, inf),
	params: ['Tyrell: Cutoff'],
	'Tyrell: Cutoff': Pseq([0.3,0.6], inf),
	dur: 1,
	legato: 1.0,
]).play;
)
p.stop;