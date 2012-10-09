// Nrev without the comb bank

// allpass, lowpass coefficients
0.6 => float apc;
0.7 => float lpc;

// series ap1, ap2, ap3, lpf, ap4
// ap1
adc => DelayL d1 => Gain ap1Sum;
adc => Gain ff1 => ap1Sum;
Gain fb1 => d1 => fb1;

// ap2
ap1Sum => DelayL d2 => Gain ap2Sum;
ap1Sum => Gain ff2 => ap2Sum;
Gain fb2 => d2 => fb2;

// ap3
ap2Sum => DelayL d3 => Gain ap3Sum;
ap2Sum => Gain ff3 => ap3Sum;
Gain fb3 => d3 => fb3;

// lpf
ap3Sum => OnePole lpf;

// ap4
lpf => DelayL d4 => Gain ap4Sum;
lpf => Gain ff4 => ap4Sum;
Gain fb4 => d4 => fb4;

// stereo split to uncorrelated signals for left and right
// ap5 -- left side
ap4Sum => DelayL d5 => dac.left;
ap4Sum => Gain ff5 => dac.left;
Gain fb5 => d5 => fb5;

// ap6 -- right side
ap4Sum => DelayL d6 => dac.right;
ap4Sum => Gain ff6 => dac.right;
Gain fb6 => d6 => fb6;

// NREV delays
347.0::samp => d1.delay;
113.0::samp => d2.delay;
37.0::samp => d3.delay;
59.0::samp => d4.delay;
53.0::samp => d5.delay;
43.0::samp => d6.delay;

-apc => fb1.gain;
apc => ff1.gain;
-apc => fb2.gain;
apc => ff2.gain;
-apc => fb3.gain;
apc => ff3.gain;
lpc => lpf.a1;
1.0 - lpc => lpf.b0;
-apc => fb4.gain;
apc => ff4.gain;
-apc => fb5.gain;
apc => ff5.gain;
-apc => fb6.gain;
apc => ff6.gain;

while (true)
{
    0.1::second => now;
}