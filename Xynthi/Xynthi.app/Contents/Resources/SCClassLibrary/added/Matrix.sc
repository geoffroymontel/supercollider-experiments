/*
	Filename: Matrix.sc 
	created: 11.4.2005 

	Copyright (C) IEM 2005, Christopher Frauenberger [frauenberger@iem.at] 

	This program is free software; you can redistribute it and/or 
	modify it under the terms of the GNU General Public License 
	as published by the Free Software Foundation; either version 2 
	of the License, or (at your option) any later version. 

	This program is distributed in the hope that it will be useful, 
	but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
	GNU General Public License for more details. 

	You should have received a copy of the GNU General Public License 
	along with this program; if not, write to the Free Software 
	Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. 

	IEM - Institute of Electronic Music and Acoustics, Graz 
	Inffeldgasse 10/3, 8010 Graz, Austria 
	http://iem.at
*/

/* Class: Matrix
   some matrix calculation helper functions
*/
Matrix {
	/* Class method: *mul
	   Matrix multiplication
	   Parameter: 
	   	m1: Matrix 1
	   	m2: Matrix 2
	   Return:
	   	out = m1 * m2
	*/
	*mul { arg m1=0, m2=0;
		
		var m2s;
		var out, size;
		
		// TODO: do some checking here whether multiplication is possible	
		size = m1.size;
		out = Array.new(size);
		size.do { out.add(Array.new(size)); };
		
		// swap the m2 Matrix (rows -> columns)
		m2s = m2.flop;
		
		// multiplication
		m1.do { arg row, i;
			size.do { arg u;
				out.at(i).add((row * m2s.at(u)).sum);
			};
		};
		^out;	
	}
}