// combine clarinet physical model with chaotic variation
// uses two independent Logistic maps, one for pitch, one for loudness

// patch Clarinet to output
Clarinet clar => NRev rev => dac;
clar.noteOn(0.05);
clar.vibratoGain(0.0);
// set effect mix to full on
rev.mix(0.1);

// smoothing envelope to use for variation
Step unity => Envelope pitchEnv => blackhole;
     unity => Envelope pressEnv => blackhole;
50::ms => dur updateDur;
pitchEnv.duration(updateDur);
pressEnv.duration(updateDur);

// instantiate and initialize logistic maps
// slight differences are fun
Logistic pitch;
pitch.set(0.7, 3.7);
Logistic press;
press.set(0.6, 3.6);

// spork an update function to vary shift amount smoothly
fun void smoothUpdates() 
{
  while( true )
  {
    clar.freq(Std.mtof(60.0 + 12.0 * pitchEnv.last()));
    clar.pressure( (.9 * pressEnv.last()) );
    1::samp => now;
  }
}
spork ~smoothUpdates();

// control loop
while( true )
{
    pitchEnv.target(pitch.tick());
    pressEnv.target(press.tick());
    updateDur => now;
}

class Logistic
{
    float _x, _r;
    false => int isSet;
    fun void set( float x, float r )
    {
        x => _x;
        r => _r;
        true => isSet;
    }
    fun float tick( )
    {
        if (!isSet) 
        {
            <<<"Logistic not set, quitting","\ntry adding something like... 
            <your_obj>.set(0.7, 3.1); 
            for initial x value and r coefficient">>>;
            me.exit();
        }
        (_r * _x) * (1.0 - _x) => _x;
        return _x;
    }
}

