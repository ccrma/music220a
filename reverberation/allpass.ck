// demo of a simple allpass delay (creates a colorless recirculating delay)
 
adc => DelayL d => dac;
// add a feedforward path
adc => Gain ff => dac;
// add a feedback path
Gain fb => d => fb;

// try different values of delay
3000::samp => d.delay;

// try different values of allpass coefficient
0.8 => float apc;
-apc => fb.gain;
apc => ff.gain;

while (true)
{
    0.1::second => now;
}