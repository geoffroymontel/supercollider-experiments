ViewRedirect { // Abstract class

	classvar <>redirectQueries = false;

	*implClass {
		^GUI.scheme.perform(this.key)
	}
	*key { ^\viewRedirect }
	*new { arg parent, bounds;
		var	impl;
		if((impl = this.implClass).notNil) {
			^impl.new(parent, bounds)
		} {
			MethodError("ViewRedirect is an abstract class and should not be instantiated directly. *new method not valid.", this).throw;
		}
	}
	*browse { ^ClassBrowser(this.implClass ?? { ViewRedirect }) }
	*doesNotUnderstand{|selector ... args|
		var	impl;
		if((impl = this.implClass).notNil) {
			^this.implClass.perform(selector, *args)
		} {
			DoesNotUnderstandError(this, selector, args).throw;
		}
	}
	*classRedirect { ^redirectQueries.if({this.implClass ? this}, this)}
}

Window : ViewRedirect {
	*key { ^\window }
	*new { arg name = "panel", bounds, resizable = true, border = true, server, scroll = false;
		^this.implClass.new(name, bounds, resizable, border, server, scroll)
	}
}
// SCWindow
CompositeView : ViewRedirect { *key { ^\compositeView }}
// SCCompositeView
ScrollView : ViewRedirect { *key { ^\scrollView }}
// SCScrollView
HLayoutView : ViewRedirect { *key { ^\hLayoutView }}
VLayoutView : ViewRedirect { *key { ^\vLayoutView }}

Slider : ViewRedirect { *key { ^\slider }}
// SCSlider

//Knob : SCSlider {
//}

//Font : ViewRedirect { *key { ^\font }}
Pen : ViewRedirect { *key { ^\pen }}
// SCPen

Stethoscope : ViewRedirect {
	*new {  arg server, numChannels = 2, index, bufsize = 4096, zoom, rate, view, bufnum;
		^this.implClass.new(server, numChannels, index, bufsize, zoom, rate, view, bufnum)
		}
	*key { ^\stethoscope }

}
ScopeView : ViewRedirect { *key { ^\scopeView }}
FreqScopeView : ViewRedirect { *key { ^\freqScopeView }} // redirects to SCFreqScope

FreqScope : ViewRedirect { // redirects to SCFreqScopeWindow
	*new { arg width=512, height=300, busNum=0, scopeColor, bgColor;
		^this.implClass.new(width, height, busNum, scopeColor)
		}
	*key { ^\freqScope }
}

Dialog : ViewRedirect { *key { ^\dialog }}
View : ViewRedirect { *key { ^\view }}
// SCView

RangeSlider : ViewRedirect { *key { ^\rangeSlider }}
Slider2D : ViewRedirect { *key { ^\slider2D }}
// SCSlider2D
TabletSlider2D : ViewRedirect { *key { ^\tabletSlider2D }}
Button : ViewRedirect { *key { ^\button }}
// SCButton

PopUpMenu : ViewRedirect { *key { ^\popUpMenu }}
StaticText : ViewRedirect { *key { ^\staticText }}
NumberBox : ViewRedirect { *key { ^\numberBox }}
ListView : ViewRedirect { *key { ^\listView }}

DragSource : ViewRedirect { *key { ^\dragSource }}
DragSink : ViewRedirect { *key { ^\dragSink }}
DragBoth : ViewRedirect { *key { ^\dragBoth }}

UserView : ViewRedirect { *key { ^\userView }}
// SCUserView
AnimationView : ViewRedirect { *key {^\animationView}}
MultiSliderView : ViewRedirect { *key { ^\multiSliderView }}
// SCMultiSliderView
EnvelopeView : ViewRedirect { *key { ^\envelopeView }}

TextField : ViewRedirect  { *key { ^\textField }}


TabletView : ViewRedirect { *key { ^\tabletView }}
SoundFileView : ViewRedirect { *key { ^\soundFileView }}
MovieView : ViewRedirect { *key { ^\movieView }}
TextView : ViewRedirect  {	*key { ^\textView }}

Font : ViewRedirect  {	*key { ^\font }}
// SCFont
Knob : ViewRedirect  {	*key { ^\knob }}

LevelIndicator : ViewRedirect  {	*key { ^\levelIndicator }}


