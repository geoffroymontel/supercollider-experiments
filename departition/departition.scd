if// Ligne noire : événements discontinus
// Ligne rouge : événements continus (drone, quoi)
// Ligne verte : interjection rapide et contrastée

OSCFunc.trace(true, true);

// change iPad IP address here
~iPadNetAddr = NetAddr.new("192.168.1.12", 63763);

OSCFunc.trace(false, true);

// load all files
(
[
	"groups-buses.scd",
	"setup-touchosc.scd",
	"player1.scd",
	"player2.scd",
	"player3.scd",
	"player4.scd",
].do { |file|
	file.loadRelative;
}
)
