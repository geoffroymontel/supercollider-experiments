C2PL_GUI_Pic_StyleFunc {

	classvar func;


	*initClass {
	
		func = 
			[
			// 0 - lines between points
			{
			|coords, lineWidth, blobWidth, moveToIndex = 0, startFromIndex = 0|
			Pen.moveTo(Point(coords[moveToIndex][0], coords[moveToIndex][1]));
			coords.do { |item, index|
				Pen.lineTo(Point(*item));
			};
			Pen.stroke;
			},
			// 1 - radiating lines
			{
			|coords, lineWidth, blobWidth|
			coords.do { |item, index|
																Pen.moveTo(Point(0, 0));
				Pen.lineTo(Point(*item));
			};
			Pen.stroke;
			},
			// 2 - blobs
			{
			|coords, lineWidth, blobWidth|
			coords.do { |item, index|
		
				Pen.fillOval(
					Rect(
						item[0] - (blobWidth * 0.5),
						item[1] - (blobWidth * 0.5),
						blobWidth,
						blobWidth
					)
				);
			};
								
			},
			// 3 radiating lines + blobs
			{
			|coords, lineWidth, blobWidth|
			coords.do { |item, index|
				Pen.moveTo(Point(0, 0));
				Pen.lineTo(Point(*item));
				Pen.stroke;
		
				Pen.fillOval(
					Rect(
						item[0] - (blobWidth * 0.5),
						item[1] - (blobWidth * 0.5),
						blobWidth,
						blobWidth
					)
				);
			};
			
			},
			// 4 - circles
			{
			|coords, lineWidth, blobWidth|
			coords.do { |item, index|
		
				Pen.strokeOval(
					Rect(
						item[0] - (blobWidth * 0.5),
						item[1] - (blobWidth * 0.5),
						blobWidth,
						blobWidth
					)
				);
			};	
			
			},
			// 5 - radiating lines + circles
			{
			|coords, lineWidth, blobWidth|
			coords.do { |item, index|
				Pen.moveTo(Point(0, 0));
				Pen.lineTo(Point(*item));
				Pen.stroke;
		
				Pen.strokeOval(
					Rect(
						item[0] - (blobWidth * 0.5),
						item[1] - (blobWidth * 0.5),
						blobWidth,
						blobWidth
					)
				);
			};	
			
			},
			// 6 - squares
			{
			|coords, lineWidth, blobWidth|
			coords.do { |item, index|

				Pen.strokeRect(Rect(item[0] - (blobWidth * 0.5), item[1] - (blobWidth * 0.5), blobWidth, blobWidth));
			};
			
			},
			// 7 - rects from 0,0
			{
			|coords, lineWidth, blobWidth|
			coords.do { |item, index|
				
				Pen.strokeRect(Rect(0, 0, item[0], item[1]));
			};
			
			},
			// 8 - spikes
			{
			|coords, lineWidth, blobWidth|
			coords.do { |item, index|
																Pen.moveTo(Point((blobWidth * -0.5), 0));
				Pen.lineTo(Point((blobWidth * 0.5), 0));
				Pen.lineTo(Point(*item));
				Pen.fill;
			};
			
			},
			// 9 - curve in
			{
			|coords, lineWidth, blobWidth|
			var lastX = 0, lastY = 0;
			
			Pen.moveTo(Point(coords[4][0], coords[4][1]));
			coords.do { |item, index|
				Pen.curveTo(Point(*item), Point(lastX, lastY), Point(*item) - Point(lastX, lastY));
				#lastX, lastY = item;
			};
			Pen.stroke;
			
			},
			// 10 - curve out
			{
			|coords, lineWidth, blobWidth|
			var lastX = 0, lastY = 0;
			
			Pen.moveTo(Point(coords[4][0], coords[4][1]));
			coords.do { |item, index|
				Pen.curveTo(Point(*item), Point(lastX, lastY), Point(*item) + Point(lastX, lastY));
				#lastX, lastY = item;
			};
			Pen.stroke;
			
			}
			
		];
	
	
	}
	
	*return { |index = 0|
	
		^func[index]
	
	}
	
}


