/* basic dimensions, make sure these match your base*/
width  = 210;   // outer x dimension in mm
length = 160;   // outer y dimension in mm
walls  = 0.8;   // wall thickness in mm, two perimeters
/* -------- */

/* build */
union() {    
    cube([width - walls * 2, length - walls * 3.25, walls* 1.75]);
}