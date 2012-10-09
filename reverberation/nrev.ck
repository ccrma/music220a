// Nrev the hard way

// allpass, lowpass coefficients
0.6 => float apc;
0.7 => float lpc;
adc => Gain direct => dac;
adc => Gain reverb;
0.5 => direct.gain;     // direct amount
0.1 => reverb.gain;     // reverb amount
0.9995 => float R;      // radius, affects reverb time

reverb => DelayL dc1 => Gain combSum;
Gain fbc1 => dc1 => fbc1;
reverb => DelayL dc2 => combSum;
Gain fbc2 => dc2 => fbc2;
reverb => DelayL dc3 => combSum;
Gain fbc3 => dc3 => fbc3;
reverb => DelayL dc4 => combSum;
Gain fbc4 => dc4 => fbc4;
reverb => DelayL dc5 => combSum;
Gain fbc5 => dc5 => fbc5;
reverb => DelayL dc6 => combSum;
Gain fbc6 => dc6 => fbc6;
// NREV combs
1433.0 => float L1;
1601.0 => float L2;
1433.0 => float L3;
1867.0 => float L4;
2053.0 => float L5;
2399.0 => float L6;
L1::samp => dc1.delay;
L2::samp => dc2.delay;
L3::samp => dc3.delay;
L4::samp => dc4.delay;
L5::samp => dc5.delay;
L6::samp => dc6.delay;
Math.pow( R, L1 ) => fbc1.gain;
Math.pow( R, L2 ) => fbc2.gain;
Math.pow( R, L3 ) => fbc3.gain;
Math.pow( R, L4 ) => fbc4.gain;
Math.pow( R, L5 ) => fbc5.gain;
Math.pow( R, L6 ) => fbc6.gain;

// series ap1, ap2, ap3, lpf, ap4
// ap1
combSum => DelayL da1 => Gain ap1Sum;
combSum => Gain ffa1 => ap1Sum;
Gain fba1 => da1 => fba1;

// ap2
ap1Sum => DelayL da2 => Gain ap2Sum;
ap1Sum => Gain ffa2 => ap2Sum;
Gain fba2 => da2 => fba2;

// ap3
ap2Sum => DelayL da3 => Gain ap3Sum;
ap2Sum => Gain ffa3 => ap3Sum;
Gain fba3 => da3 => fba3;

// lpf
ap3Sum => OnePole lpf;

// ap4
lpf => DelayL da4 => Gain ap4Sum;
lpf => Gain ffa4 => ap4Sum;
Gain fba4 => da4 => fba4;

// stereo split to uncorrelated signals for left and right
// ap5 -- left side
ap4Sum => DelayL da5 => dac.left;
ap4Sum => Gain ffa5 => dac.left;
Gain fba5 => da5 => fba5;

// ap6 -- right side
ap4Sum => DelayL da6 => dac.right;
ap4Sum => Gain ffa6 => dac.right;
Gain fba6 => da6 => fba6;

// NREV all-pass delays
347.0::samp => da1.delay;
113.0::samp => da2.delay;
37.0::samp => da3.delay;
59.0::samp => da4.delay;
53.0::samp => da5.delay;
43.0::samp => da6.delay;

-apc => fba1.gain;
apc => ffa1.gain;
-apc => fba2.gain;
apc => ffa2.gain;
-apc => fba3.gain;
apc => ffa3.gain;
lpc => lpf.a1;
1.0 - lpc => lpf.b0;
-apc => fba4.gain;
apc => ffa4.gain;
-apc => fba5.gain;
apc => ffa5.gain;
-apc => fba6.gain;
apc => ffa6.gain;

while (true)
{
    0.1::second => now;
}