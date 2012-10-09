// bank of 6 combs in parallel

adc => Gain direct => dac;
adc => Gain reverb;
0.5 => direct.gain;     // direct amount
0.1 => reverb.gain;     // reverb amount
0.9995 => float R;      // radius, affects reverb time

reverb => DelayL d1 => dac;
Gain fb1 => d1 => fb1;
reverb => DelayL d2 => dac;
Gain fb2 => d2 => fb2;
reverb => DelayL d3 => dac;
Gain fb3 => d3 => fb3;
reverb => DelayL d4 => dac;
Gain fb4 => d4 => fb4;
reverb => DelayL d5 => dac;
Gain fb5 => d5 => fb5;
reverb => DelayL d6 => dac;
Gain fb6 => d6 => fb6;

// NREV combs
1433.0 => float L1;
1601.0 => float L2;
1867.0 => float L3;
2053.0 => float L4;
2251.0 => float L5;
2399.0 => float L6;
L1::samp => d1.delay;
L2::samp => d2.delay;
L3::samp => d3.delay;
L4::samp => d4.delay;
L5::samp => d5.delay;
L6::samp => d6.delay;
Math.pow( R, L1 ) => fb1.gain;
Math.pow( R, L2 ) => fb2.gain;
Math.pow( R, L3 ) => fb3.gain;
Math.pow( R, L4 ) => fb4.gain;
Math.pow( R, L5 ) => fb5.gain;
Math.pow( R, L6 ) => fb6.gain;

while (true)
{
    0.1::second => now;
}