// add in the effects patch from filter/resonz.ck
// rectified sine pattern affecting resonance
// (effect on left, dry signal on right)

adc.chan(0) => Gain inGainL => ResonZ f => dac.chan(0);
inGainL.gain(2.0);
adc.chan(0) => Gain inGainR => dac.chan(1);
inGainR.gain(0.3);

// set filter Q
10 => f.Q;

while( true ) {
    // sweep the cutoff
    10 + Std.fabs( Math.sin( 4 * (now/second) )) * 1000 => f.freq;
    1::samp => now;
}
