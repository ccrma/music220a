"[put_your_file_path_here]" => string mydata;

DataReader dr;
dr.load(mydata);
dr.loop(1);
if (!dr.isValid()) me.exit(); // kill switch

// one sine osc
SinOsc s => dac;
0.01 => s.gain;
(1000/dr.getLength())::ms => dur rate;

// loop with modulation
while ( dr.next() ) {
    dr.getNormalized() * 20.0 + 80.0 => float pitch;
    Std.mtof(pitch) => s.freq;
    1.001 *=> rate;
    rate => now;
}