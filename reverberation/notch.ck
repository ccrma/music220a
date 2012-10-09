// demo of a notch filter (FIR)
 
// add a feedforward path around a delay
adc => DelayL d => dac;
adc => Gain ff => dac;

// try different values of delay and gain
300::samp => d.delay;
0.999 => ff.gain;

while (true)
{
    0.1::second => now;
}