include <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>
use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-baseplate.scad>

// ===== INFORMATION ===== //
/*
 IMPORTANT: rendering will be better for analyzing the model if fast-csg is enabled. As of writing, this feature is only available in the development builds and not the official release of OpenSCAD, but it makes rendering only take a couple seconds, even for comically large bins. Enable it in Edit > Preferences > Features > fast-csg
 the magnet holes can have an extra cut in them to make it easier to print without supports
 tabs will automatically be disabled when gridz is less than 3, as the tabs take up too much space
 base functions can be found in "gridfinity-rebuilt-utility.scad"
 examples at end of file

 BIN HEIGHT
 the original gridfinity bins had the overall height defined by 7mm increments
 a bin would be 7*u millimeters tall
 the lip at the top of the bin (3.8mm) added onto this height
 The stock bins have unit heights of 2, 3, and 6:
 Z unit 2 -> 7*2 + 3.8 -> 17.8mm
 Z unit 3 -> 7*3 + 3.8 -> 24.8mm
 Z unit 6 -> 7*6 + 3.8 -> 45.8mm

https://github.com/kennetek/gridfinity-rebuilt-openscad

*/

// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 2;
// number of bases along y-axis
gridy = 2;
// bin height. See bin height information and "gridz_define" below.
gridz = 3;

/* [Features] */
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = true;

/* [Base] */
style_hole = 4; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit, 4: Gridfinity Refined hole - no glue needed]

/* [Magnets] */
/* Note: press fit tolerances should be included in these dimensions */
magnet_mode = 1; // 0 = no magnets, 1 = cylinder, 2 = rectangular

// Cylinder magnets
magnet_r = 6.1/2;

// Rectangular magnets
magnet_x = 8.1;
magnet_y = 8.1;

magnet_z = 1.5;

// How many magnets?
magnet_grid_x = 4;
magnet_grid_y = 4;

// Distance between magnets
magnet_stride_x = 20;
magnet_stride_y = 20;

/* [Lid Magnets] */
lid_magnet_r = 3.2/2;
lid_magnet_z = 2.5;

lid_magnet_r_outer = lid_magnet_r + 2;
lid_magnet_x = 42 * gridx / 2 - 4;
lid_magnet_y = 42 * gridy / 2 - 4;
lid_thickness = lid_magnet_z + 0.5;

render_body = true;
render_lid = false;

module model()
{
    union()
    {
        gridfinityInit(gridx, gridy, height(gridz, 0, 1, false), 0, sl=1)
        {
            difference()
            {
                translate([0, 0, magnet_mode == 0 ? 0 : magnet_z - 0.21])
                    cutEqual(n_divx = 1, n_divy = 1, style_tab = 5, scoop_weight = 0);
                    
                translate([0, 0, 7 * gridz - lid_thickness * 0.5])
                    cube([42 * gridx, 42 * gridy, lid_thickness], center = true);
                    
                for (xi = [-1, 1])
                    for (yi = [-1, 1])
                        translate([lid_magnet_x * xi, lid_magnet_y * yi, 7 * (1 + (gridz - 1) / 2)])
                        {
                            cylinder(h = 7 * (gridz - 1), r = lid_magnet_r_outer, center = true);
                            difference()
                            {
                                cube([lid_magnet_r_outer * 2, lid_magnet_r_outer * 2, 7 * (gridz - 1)], center = true);
                                translate([-xi * lid_magnet_r_outer / 2, -yi * lid_magnet_r_outer / 2, 0])
                                    cube([lid_magnet_r_outer, lid_magnet_r_outer, 7 * (gridz - 1)], center = true);
                            }   
                        }
            }
            
            for (xi = [-(magnet_grid_x - 1) / 2 : 1 : (magnet_grid_x - 1) / 2])
                for (yi = [-(magnet_grid_y - 1) / 2 : 1 : (magnet_grid_y - 1) / 2])
                    translate([xi * magnet_stride_x, yi * magnet_stride_y, 7 + magnet_z * 0.5])
                    {
                        if (magnet_mode == 1) cylinder(h = magnet_z, r = magnet_r, center = true);
                        if (magnet_mode == 2) cube([magnet_x, magnet_y, magnet_z], center = true);
                    }
                
            for (xi = [-1, 1])
                for (yi = [-1, 1])
                    translate([lid_magnet_x * xi, lid_magnet_y * yi, 7 * gridz - lid_thickness])
                        cylinder(h = lid_magnet_z * 2, r = lid_magnet_r, center = true);
        }
        gridfinityBase(gridx, gridy, l_grid, 0, 0, style_hole, only_corners=only_corners);

        translate([0, 0, gridz * 7])
            gridfinityBaseplate(gridx, gridy, l_grid, 0, 0, 0, true, 2, 0, 0);
    }
}
  
module body_split()
{  
    translate([-42 * gridx / 2, -42 * gridy / 2, 0])
        cube([42 * gridx, 42 * gridy, 7 * gridz - lid_thickness], center = false);
}

// Body
if (render_body) intersection()
{
    model();
    body_split();
}

// Lid
if (render_lid) difference()
{
    model();
    body_split();
}