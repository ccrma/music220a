// real-time efx demo

adc => PitShift p => dac;
1.0 => p.mix;
0.75 => p.shift;
day => now;



