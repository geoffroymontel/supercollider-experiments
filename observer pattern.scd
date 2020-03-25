// Apart from that... you can have a "thing" (an object) broadcast that it has changed (`myObject.changed(\value, ...)`) and you can register other objects to receive notifications (`~responder = SimpleController(myObject).put(\value, { ... do something... })`) -- the Observer design pattern. This is exactly the kind of modularity you're talking about -- the thing that is changing doesn't have to know anything about the actions that will follow, and the receivers don't have to care how it changed.

// (One detail is to make sure you remove the responders -- if it's a SimpleController, `~responder.remove`.)

// With a class like this:

ValueNotify : Ref {
set { |thing|
value = thing;
this.changed(\value, value);
}

value_ { |thing|
value = thing;
this.changed(\value, value);
}

printOn { |stream|
stream << "ValueNotify(" << value << ")";
}

storeOn { |stream|
stream << "ValueNotify(" <<< value << ")";
}
}

// You could do:

f = ValueNotify(440);

r = SimpleController(f).put(\value, { |obj, what, value|
a.set(\freq, value);
});

a = Synth(\default);

// your OSCdef would do this:
// note there is no reference here to 'a'!
f.value = 220;
f.value = 660;

a.free;
r.remove;