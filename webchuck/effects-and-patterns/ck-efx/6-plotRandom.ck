// observe a random walk suitable for varying efx coefficients 
// prints to browser console 10 points per second
100 => int dataPts;

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
        return Std.rand2f(_l, _h); // low and high bounds on random
    }
}
Random ran;
ran.set(0.0, 1.0);
for (0 => int i; i<dataPts; i++) 
{
    ran.tick() => float tmp;
    <<<i, tmp>>>;
    100::ms => now; // next data point in time
}

