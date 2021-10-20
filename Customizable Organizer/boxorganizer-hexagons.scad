/* basic dimensions */
width  = 210;   // outer x dimension in mm
length = 160;   // outer y dimension in mm
height = 30;    // outer z dimension in mm
walls  = 0.8;   // wall thickness in mm, two perimeters
base   = true;  // is a bottom wanted?
lid = true; // is a sliding lid wanted?

hexRadius = 4; // radius of the hexagon holes
hexMargin = 1; // margin around hexagon holes 
hexRowReduceNum = 2; // number of rows to omit from top of walls

/* defines - use to define the grid */
N  = 0; // no walls
R  = 1; // right wall
B  = 2; // bottom wall
RB = 3; // both walls
BR = 3; // both walls

/* grid config */
grid = [
    [ B ],
    [ B ],
    [ B ],
    [ N ]
];

/* -------- */

// calculate base values
gridR = reverse(grid);
unitsX = len(grid[0]);  // units per width
unitsY = len(grid);     // units per length
unitX = (width - walls)/unitsX;   // unit width
unitY = (length - walls)/unitsY;  // unit length

echo(str("Each unit is ",unitX,"mm by ",unitY,"mm"));

/* build */
union() {
    // ground plate
    if(base) {
        cube([width, length, walls]);
    }

    // outer walls
    // outer left vertical
    cubeWithHexagons(walls, length, height);
    
    // outer right vertical
    cubeWithHexagons(walls, length, height, width - walls, 0, 0);
   
    // outer bottom horizontal
    cubeWithHexagons(width, walls, height);
   
    // outer top horizontal
    cubeWithHexagons(width, walls, height, 0, length - walls, 0);

    // iterate over the grid definition
    for (r = [0:1:unitsY-1], c = [0:1:unitsX-1]) {
        unit = gridR[r][c];
        
        if (unit) {
            // vertical walls
            if (bitwise_and(unit, R)) {
                cubeWithHexagons(walls, unitY + walls, height, (c+1)*unitX, r * unitY);
            }
            
            // horizontal walls
            if (bitwise_and(unit, B)) {
                cubeWithHexagons(unitX, walls, height, c*unitX, r*unitY, 0);
            }
        }
    }
    
    // sliding lid
    if (lid) {        
        difference() {
            translate([0, 0, height])
                cube([width, length, walls * 4]);

            // cut out sliding part
            translate([walls * 2, walls * 2, height + walls])
                cube([width, length - walls * 4, walls * 2]);

            // cut out top part
            translate([walls * 4, walls * 4, height - 2])
                cube([width + 100, length - walls * 8, 20]);
            
            
            // cut out end part top
            translate([width - walls * 5.7, 0- walls * 2, height + walls * 6])
                rotate([0, 45])
                cube([walls * 8, walls * 8, walls * 8]);
            
            // cut out end part bottom
            translate([width - walls * 6, length - walls * 6, height + walls * 6])
                rotate([0, 45])
                cube([walls * 8, walls * 8, walls * 8]);

        }
    }
}

// https://github.com/openscad/scad-utils/blob/master/lists.scad
function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

module cubeWithHexagons(width, length, height, x = 0, y = 0, z = 0) {
    isVert = width < length;
    rotateZ = isVert
        ? 90
        : 0;
    difference() {
        translate([x, y, z])
            cube([width, length, height]);

        rows = floor(
            height / ((hexRadius * 2) + (hexMargin * 2))
        ) - hexRowReduceNum;
        cols = floor(isVert
            ? length / ((hexRadius * 2) + (hexMargin * 2))
            : width / ((hexRadius * 2) + (hexMargin * 2))
        );
            
        echo ("Rendering hexagons for rows=",rows,"; cells=",cols);
        for ( row = [0 : rows]) {   
            offsetX = row % 2 == 0
              ? -hexRadius
              : hexRadius;
            for ( col = [0 : cols]) {
                translateX = hexRadius + hexMargin + (col * (hexRadius * 2 + hexMargin * 2));
                
                translateY = hexRadius * 2 + (row * (hexRadius * 2 + hexMargin * 2));

                translate([x, y, z])
                rotate([90, 0, rotateZ])
                translate([
                    translateX,
                    translateY,
                    -1,
                ])
                scale([1,1,4])
                  hexagon(
                    hexRadius,
                    offsetX,
                    hexRadius / 2
                  );
            }
        }
    }
}
    

module hexagon(r,x,y){
    linear_extrude(1)
    polygon(points=[[(r+x),(r*(tan(30)))+y],
                    [x,(r*(2/sqrt(3)))+y],
                    [-r+x,(r*(tan(30)))+y],
                    [-r+x,-(r*(tan(30)))+y],
                    [x,-(r*(2/sqrt(3)))+y], 
                    [r+x,-(r*(tan(30)))+y]]);
         
 }

// https://github.com/royasutton/omdl/blob/master/math/math_bitwise.scad
function bitwise_and
(
  v1,
  v2,
  bv = 1
) = ((v1 + v2) == 0) ? 0
  : (((v1 % 2) > 0) && ((v2 % 2) > 0)) ?
    bitwise_and(floor(v1/2), floor(v2/2), bv*2) + bv
  : bitwise_and(floor(v1/2), floor(v2/2), bv*2);
