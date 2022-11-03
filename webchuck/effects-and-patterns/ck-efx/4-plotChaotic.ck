// chaotic function suitable for varying efx coefficients 
// prints to browser console 10 points per second
// see https://en.wikipedia.org/wiki/Logistic_map
100 => int dataPts;

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
        if (!isSet)  me.exit();
        (_r * _x) * (1.0 - _x) => _x;
        return _x;
    }
}
Logistic map;
map.set(0.7, 3.1);
for (0 => int i; i<dataPts; i++) 
{
    map.tick() => float tmp;
    <<<i, tmp>>>;
    100::ms => now; // next data point in time
}

