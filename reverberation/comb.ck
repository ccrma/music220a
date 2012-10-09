// demo of a comb filter (IIR)
 
// add a feedback path through a delay
adc => DelayL d => dac;
Gain fb => d => fb;

// try different values of delay and gain
300::samp => d.delay;
0.8 => fb.gain;

while (true)
{
    0.1::second => now;
}