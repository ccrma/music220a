// mic or instrument input through trackers
// browser needs to have adc enabled
// from analysis/centroid.ck and analysis/rms.ck
// print centroid of input signal
// oscillator to sonify the same info
// try singing, vowel change, whistling, breath noise
// basically converts speech to bird calls...
// say "red-winged blackbird, red-winged blackbird, red-winged blackbird..."

// patch mic through FFT to centroid and RMS trackers
adc.chan(0) => Gain inGain => FFT fft =^ Centroid cent => blackhole;
fft =^ RMS rms => blackhole;

// add a sine to sonify the analysis output
SinOsc s => dac;
s.gain(5.0);

// set parameters
1024 => fft.size;
// set hann window
Windowing.hamming(fft.size()) => fft.window;

// compute rate
second / samp => float srate;
Step unity => Envelope cEnv => blackhole;
unity => Envelope rEnv => blackhole;
cEnv.duration(fft.size()::samp);
rEnv.duration(fft.size()::samp);
float c, r;

fun void smoothUpdates() // to SinOsc from envelopes
{
  while( true )
  {
    s.freq(cEnv.last());
    s.gain(rEnv.last());
    1::samp => now;
  }
}
spork ~smoothUpdates();
// control loop
while( true )
{
    // upchuck: take centroid
    cent.upchuck();
    cent.fval(0) * srate / 2 => c;

    // upchuck: take RMS
    rms.upchuck() @=> UAnaBlob blob;
    blob.fval(0) => r;

    // print out centroid & RMS
    <<< c, r >>>;
 
    // update envelopes
    cEnv.target(c);
    rEnv.target(r*10.0);
    
    // advance time
    fft.size()::samp => now;
}
