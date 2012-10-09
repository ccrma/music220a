// demo of 3 allpass sections in series

// ap1
adc => DelayL d1 => Gain ap1Sum;
adc => Gain ff1 => ap1Sum;
Gain fb1 => d1 => fb1;

// ap2
ap1Sum => DelayL d2 => Gain ap2Sum;
ap1Sum => Gain ff2 => ap2Sum;
Gain fb2 => d2 => fb2;

// ap3
ap2Sum => DelayL d3 => dac;
ap2Sum => Gain ff3 => dac;
Gain fb3 => d3 => fb3;

// try different values of delay
347.0::samp => d1.delay;
113.0::samp => d2.delay;
37.0::samp => d3.delay;

// try different values of allpass coefficient
0.5 => float apc;
-apc => fb1.gain;
apc => ff1.gain;
-apc => fb2.gain;
apc => ff2.gain;
-apc => fb3.gain;
apc => ff3.gain;

while (true)
{
    0.1::second => now;
}