// @title example-DBAP4.ck
// @author Hongchan Choi (hongchan@ccrma) 
// @desc A simple examplary usage of DBAP4, DBAP4e class
// @version chuck-1.3.1.3 / ma-0.2.2c
// @revision 1

// for DBAP4
Impulse i => DBAP4 p;
// for DBAP4e: note that Binaural4 class is required
// Impulse i => DBAP4e p;

0.0 => float t;
while(true) {
    1.0 => i.next;
    0.15 +=> t;
    p.setPosition(Math.sin(t), Math.cos(t));
    100::ms => now;
}