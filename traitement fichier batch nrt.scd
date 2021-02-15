(
var path, files, server, buffer, filename, inputFile, score, filePath;

path = "/Volumes/LaCie/CONTRE-FLUX 2 (ELECTRO)/Contreflux 2/essais melodyne/SONG 3/Export Audio/Song 3 NEW/*.wav";
files = path.pathMatch;

files.collect( { |filename|
	inputFile = SoundFile.openRead(filename);
	inputFile.close;  // doesn't need to stay open; we just need the stats

	server = Server(\nrt,
		options: ServerOptions.new
		.numOutputBusChannels_(inputFile.numChannels)
		.numInputBusChannels_(inputFile.numChannels)
	);

	score = Score([
		[0.0,
			[ 'b_allocRead', buffer, filename, 0, 0 ],
			[ '/d_recv',
				SynthDef(\player, { |buffer|
					Out.ar(0, PlayBuf.ar(inputFile.numChannels, buffer, XLine.kr(BufRateScale.kr(buffer) * 0.midiratio, BufRateScale.kr(buffer) * 3.midiratio, BufDur.kr(buffer))))
				}).asBytes
			],
			[ 's_new', '\player', 1001, 0, 1, 'buffer', buffer ]
		]
	]);

	score.add([inputFile.duration, ['n_free', 1001] ],);
	score.add([inputFile.duration + 0.1, ['b_free', buffer] ],);
	score.add([inputFile.duration + 0.2, [0]] );

	filePath = PathName.new(filename);

	score.recordNRT(
		outputFilePath: ("~/" ++ filePath.fileName).standardizePath,
		sampleRate: 44100,
		headerFormat: "WAV",
		sampleFormat: "int24",
		options: server.options,
		duration: inputFile.duration
	);

	server.remove;
});
)
