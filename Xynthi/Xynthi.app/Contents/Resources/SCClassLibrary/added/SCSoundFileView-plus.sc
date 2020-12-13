+ SCSoundFileView {
	plotBuffer { arg buffer, startframe=0, frames, block=64, doneAction, showProgress=true;
		var cond, path, server, file;
		server = Server.default;
		Routine({
			cond = Condition.new;
			path = PathName.tmp ++ this.hash.asString;
			server.sendMsgSync(cond, 
				*buffer.writeMsg(path, "aiff", "float", frames ? -1, startframe));
			file = SoundFile.new;
			file.openRead(path);
			file.close;
			this.soundfile = file;
			{
				this.readWithTask(startframe, frames, block, {
					if(File.delete(path).not, {("Could not delete data file:" + path).warn;});
					doneAction.value(this);
				}, showProgress);
			}.defer
		}).play(AppClock);
	}
	
	plotBufnum { arg bufnum, startframe=0, frames, block=64, doneAction, showProgress=true;
		var cond, path, server, file;
		server = Server.default;
		Routine({
			cond = Condition.new;
			path = PathName.tmp ++ this.hash.asString;
			server.sendMsgSync(cond, 
				*["/b_write", bufnum, path, "aiff", "float", frames ? -1, startframe,0]);
			file = SoundFile.new;
			file.openRead(path);
			file.close;
			this.soundfile = file;
			{
				this.readWithTask(startframe, frames, block, {
					if(File.delete(path).not, {("Could not delete data file:" + path).warn;});
					doneAction.value(this);
				}, showProgress);
			}.defer
		}).play(AppClock);
	}

	scrollToSelectionStart { arg index=0;	// selection index
		this.x_((this.selectionStart(index) - (viewFrames*0.5))
			.clip(0, soundfile.numFrames - viewFrames));
		this.refresh;
		this.updateScroll
	}
	
	scrollToSelectionEnd { arg index=0;	// selection index
		this.x_((this.selectionStart(index) + this.selectionSize(index) - (viewFrames*0.5))
			.clip(0, soundfile.numFrames - viewFrames));
		this.refresh;
		this.updateScroll
	}

	defaultKeyDownAction { arg char, modifiers, unicode,keycode;		var zin, zout, lScroll, rScroll;
		zout = 1.1; zin = zout.reciprocal;
		rScroll = 0.1; lScroll = rScroll.neg;
		case      
			{char === $+} { this.zoom(zin) }		// zoom in
			{char === $=} { this.zoom(zin) }		// zoom in
			{char === $-} { this.zoom(zout) }	// zoom out
			{char === $1} { this.zoomAllOut }	// view all - zoom all out
			{char === $f} { this.zoomSelection(0) }	// fit selection to view
			{char === $.} { this.scroll(0.1) }	// scroll right ->
			{char === $,} { this.scroll(lScroll) }	// scroll left <-
			{char === $s} { this.scrollToStart }	// scroll to buffer start
			{char === $e} { this.scrollToEnd }	// scroll to buffer end
			{char === $a} { this.selectAll(0) }	// select all
			{char === $n} { this.selectNone(0) }	// select none
			 // scroll to selection start
			{char === $S} { this.scrollToSelectionStart(this.currentSelection) }
			 // scroll to selection end
			{char === $E} { this.scrollToSelectionEnd(this.currentSelection) };
	}

/* Drag methods */

	defaultGetDrag { 
		^Point(this.selectionStart(this.currentSelection), 
			this.selectionSize(this.currentSelection))
	}
	defaultCanReceiveDrag {
		^currentDrag.isKindOf(Point);
	}
	defaultReceiveDrag {
		this.setSelectionStart(this.currentSelection, currentDrag.x);
		this.setSelectionSize(this.currentSelection, currentDrag.y);
	}

}