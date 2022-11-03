// observe a low frequency periodic signal suitable for
// varying coefficients 

// prints to browser console 10 points per second
100 => int dataPts;

class Periodic
{
    TriOsc osc => Gain out => blackhole; // could be Sin, Saw, etc.
    Step unity => out;
    float _f, _a;
    false => int isSet;
    fun void set( float f, float a )
    {
        f => _f;
        a => _a;
        osc.freq(_f);
        out.gain(_a);
        true => isSet;
    }
    fun float tick( )
    {
        if (!isSet)  me.exit();
        return out.last();
    }
}
Periodic wav;
wav.set(1.0, 1.0);
for (0 => int i; i<dataPts; i++) 
{
    wav.tick() => float tmp;
    <<<i, tmp>>>;
    100::ms => now; // next data point in time
}

