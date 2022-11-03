// mic or instrument input through pitch shifter with random variation
// browser needs to have adc enabled

// patch mic through effect to left and direct to right
adc.chan(0) => Gain inGainL => PitShift p => dac.chan(0);
adc.chan(0) => Gain inGainR => dac.chan(1);

// set effect mix to full on
p.mix(1.0);

// smoothing envelope to use for variation
Step unity => Envelope pEnv => blackhole;
500::ms => dur updateDur;
pEnv.duration(updateDur);

// instantiate our class and initialize
Random ran;
ran.set(0.9, 1.1);

// spork an update function to vary shift amount smoothly
fun void smoothUpdates() 
{
  while( true )
  {
    p.shift(pEnv.last());
    1::samp => now;
  }
}
spork ~smoothUpdates();

// control loop
while( true )
{
    ran.tick() => float tmp;
    pEnv.target(tmp);
    updateDur => now;
}

class Random
{
    float _l, _h;
    false => int isSet;
    fun void set( float l, float h )
    {
        l => _l;
        h => _h;
        true => isSet;
    }
    fun float tick( )
    {
        if (!isSet)  me.exit();
        return Std.rand2f(_l, _h);
    }
}
