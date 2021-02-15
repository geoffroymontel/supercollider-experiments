// (c) 2006, Thor Magnusson - www.ixi-software.net
// GNU licence - google it.

BoxGrid {

	var <>gridNodes; 
	var tracknode, chosennode, mouseTracker;
	var win, bounds;
	var downAction, upAction, trackAction, backgrDrawFunc;
	var background;
	var columns, rows;
	var fillcolor, fillmode;
	var traildrag;

	*new { arg w, bounds, columns, rows; 
		^super.new.initBoxGrid(w, bounds, columns, rows);
	}
	
	initBoxGrid { arg w, argbounds, argcolumns, argrows;
		var p, rect;
		bounds = argbounds ? Rect(20, 20, 400, 200);
		bounds = Rect(bounds.left + 0.5, bounds.top + 0.5, bounds.width, bounds.height);

		win = w ? SCWindow("BoxGrid", 
			Rect(10, 250, bounds.left + bounds.width + 40, bounds.top + bounds.height+30));
		// win.front;
		tracknode = 0;
		columns = argcolumns ? 6;
		rows = argrows ? 8;
		background = Color.clear;
		fillcolor = Color.new255(103, 148, 103);
		fillmode = true;
		traildrag = false;
		
		gridNodes = Array.newClear(columns) ! rows;
		
		columns.do({arg c;
			rows.do({arg r;
				rect = Rect((bounds.left+(c*(bounds.width/columns))).round(1)+0.5, 
							(bounds.top+(r*(bounds.height/rows))).round(1)+0.5, 
							(bounds.width/columns).round(1), 
							(bounds.height/rows).round(1)
						);

				gridNodes[r][c] = Box.new(rect, c, r);
			});
		});
				
		mouseTracker = SCUserView(win, bounds)
			.canFocus_(false)
			.mouseBeginTrackFunc_({|me, x, y, mod|
					chosennode = this.findNode(x, y, \down);
					if(chosennode !=nil, {  
						tracknode = chosennode;
						downAction.value(chosennode.nodeloc);
						this.refresh;	
					});
			})
			.mouseTrackFunc_({|me, x, y, mod|
				chosennode = this.findNode(x, y, \track);
				if(chosennode !=nil, {  
					if(tracknode.rect != chosennode.rect, {
						if(traildrag == false, {
							tracknode.state = false;
						},{
							tracknode.state = true;
						});
						tracknode = chosennode;
						this.refresh;
						trackAction.value(chosennode.nodeloc);
					});
				});
			})
			.mouseEndTrackFunc_({|me, x, y, mod|
				chosennode = this.findNode(x, y, \up);
				if(chosennode !=nil, {  
					tracknode = chosennode;
					upAction.value(chosennode.nodeloc);
					this.refresh;
				});
			})
			.drawFunc_({
			
			Pen.width = 1;
			background.set; // background color
			Pen.fillRect(bounds+0.5); // background fill

			backgrDrawFunc.value; // background draw function
			Color.black.set;

			// Draw the boxes
			gridNodes.do({arg row;
				row.do({arg node; 
					if(node.state == true, {
						if(fillmode, {
							fillcolor.set;
							Pen.fillRect(node.fillrect);
							Color.black.set;									Pen.strokeRect(node.fillrect);
						},{
							Color.black.set;									Pen.strokeRect(node.fillrect);
						});
					});
				});
			});

			// Draw the grid
			Color.black.set;
			(columns+1).do({arg i;
				Pen.line(
					Point(bounds.left+(i*(bounds.width/columns)),
							bounds.top).round(1) + 0.5, 
					Point(bounds.left+(i*(bounds.width/columns)),
							bounds.height+bounds.top).round(1) + 0.5
				);
			});
			
			(rows+1).do({arg i;
				Pen.line(
					Point(bounds.left, 
						bounds.top+(i*(bounds.height/rows))).round(1) + 0.5, 
					Point(bounds.width+bounds.left, 
						bounds.top+(i*(bounds.height/rows))).round(1) + 0.5
				);
			});
			Pen.stroke;			
			});
	}
	
	// GRID
	setBackground_ {arg color;
		background = color;
		mouseTracker.refresh;
	}
		
	setFillMode_ {arg mode;
		fillmode = mode;
		mouseTracker.refresh;
	}
	
	setFillColor_ {arg color;
		fillcolor = color;
		mouseTracker.refresh;
	}
	
	setTrailDrag_{arg mode; // true or false
		traildrag = mode;
	}

	refresh {
		mouseTracker.refresh;
	}
		
	// NODES	
	setNodeBorder_ {arg border;
		gridNodes.do({arg row;
			row.do({arg node; 
				node.setBorder_(border);
			});
		});
		mouseTracker.refresh;
	}
	
	// depricated
	setVisible_ {arg row, col, state;
		gridNodes[col][row].setVisible_(state);
		mouseTracker.refresh;
	}

	setState_ {arg row, col, state;
		if(state.isInteger, {state = state!=0}); // returns booleans
		gridNodes[col][row].setState_(state);
		mouseTracker.refresh;
	}
	
	getState {arg row, col;
		var state;
		state = gridNodes[col][row].getState;
		^state.binaryValue;
	}	
	
	getNodeStates {
		var array;
		array = Array.newClear(columns) ! rows;
		gridNodes.do({arg rows, r;
			rows.do({arg node, c; 
				array[r][c] = node.state.binaryValue;
			});
		});
		^array;
	}
	
	setNodeStates_ {arg array;
		gridNodes.do({arg rows, r;
			rows.do({arg node, c; 
				node.state = array[r][c]!=0;
			});
		});
		mouseTracker.refresh;
	}
	
	clearGrid {
		gridNodes.do({arg rows, r;
			rows.do({arg node, c; 
				node.state = false;
			});
		});
		mouseTracker.refresh;
	}	
	
	// PASSED FUNCTIONS OF MOUSE OR BACKGROUND
	nodeDownAction_ { arg func;
		downAction = func;
	}
	
	nodeUpAction_ { arg func;
		upAction = func;
	}
	
	nodeTrackAction_ { arg func;
		trackAction = func;
	}
	
	setBackgrDrawFunc_ { arg func;
		backgrDrawFunc = func;
	}
	
	// local function
	findNode {arg x, y, action;
		gridNodes.do({arg row;
			row.do({arg node; 
				if(node.rect.containsPoint(Point.new(x,y)), {
					if(action == \down, {
						node.state = not(node.state);
					});
					if(action == \track, {
						node.state = true ;
					});
					^node;
				});
			});
		});
		^nil;
	}
}

Box {
	var <>fillrect, <>state, <>border, <>rect, <>nodeloc;
	
	*new { arg rect, column, row ; 
		^super.new.initGridNode( rect, column, row);
	}
	
	initGridNode {arg argrect, argcolumn, argrow ;
		
		rect = argrect;
		nodeloc = [ argcolumn, argrow ];		
		border = 3;
		fillrect = Rect(rect.left+border, rect.top+border, 
					rect.width-(border*2), rect.height-(border*2));
		state = false;
	}
	
	setBorder_ {arg argborder;
		border = argborder;
		fillrect = Rect(rect.left+border, rect.top+border, 
					rect.width-(border*2), rect.height-(border*2));
	}
	
	setVisible_ {arg argstate;
		state = argstate;
	}
	
	setState_ {arg argstate;
		state = argstate;
	}
	
	getState {
		^state;
	}
}