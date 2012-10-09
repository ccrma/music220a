// centered image

adc => Delay left => dac.left;
adc => Delay right => dac.right;

// ITD
0::ms => left.delay;
0::ms => right.delay;

// IID
0.5 => left.gain;
0.5 => right.gain;

30::second => now;
<<<"done">>>;
