// @title amplitudeFrequencyTracker.ck
// @author Chris Chafe (cc@ccrma), Hongchan Choi (hongchan@ccrma) 
// @desc A starter code for homework 5, Music220a-2012
// @note amplitude/frequency tracking using UAna ugens
// @version chuck-1.3.2.0
// @revision 2


// IMPORTANT NOTE: this patch is designed to use microphone.
// If you're using speakers and your microphone at the same time,
// you might experience serious feedback. Make sure to use 
// the headphone or earbuds to avoid it.


// pipe input into analysis audio graph:
// track amplitude for gain of an FM patch
// frequency will be max bin amplitude from the spectrum
adc.chan(0) => FFT fft  =^ RMS rms => blackhole;

// setup FFT: choose high-quality transform parameters
2048 => fft.size;
0.5 => float hop;
second / samp => float srate;
complex s[fft.size()/2];
float spect[fft.size()/2];


// actual audio graph and parameter setting
// NOTE: gain 'g' prevents direct connection bug
adc.chan(0) => Gain g => dac.left;
// creating hammond organ-like FM instrument
BeeThree b3 => dac.right; 
b3.noteOn(1); // to start the synth
// set initial frequency
60 => Std.mtof => b3.freq; 
// instantiate a smoother to smooth tracker results (see below)
Smooth sma, smf;
// set time constant: shorter time constant gives faster 
// response but more jittery values
sma.setTimeConstant((fft.size() * 2)::samp);
smf.setTimeConstant((fft.size() * 2)::samp);


// setGainAndFreq()
spork ~ setGainAndFreq();
fun void setGainAndFreq() {
    while (true) {
        // apply smoothed values
        b3.gain(sma.getLast()); 
        b3.freq(smf.getLast());
        1::samp => now;
    }   
}


// main inf-loop
while(true) {
    // hop in time by overlap amount
    (fft.size() * hop)::samp => now; 
    // then we've gotten our first bufferful
    // compute the FFT and RMS analyses
    rms.upchuck(); 
    rms.fval(0) => float a;
    Math.rmstodb(a) => float db;
    // boost the sensitity
    30 + db * 15 => db;
    // but clip at maximum
    Math.min(100, db) => db; 
    sma.setNext(Math.dbtorms(db));      
    
    // only process half the spectrum to save computation
    for (0=>int i; i<fft.size()/4; i++) 
    {
        fft.cval(i).re => s[i].re;
        fft.cval(i).im => s[i].im;
        Math.sqrt(s[i].re*s[i].re + s[i].im*s[i].im) => spect[i];
    }
    0 => float max;
    0 => int where;
    // look for a frequency peak in the spectrum
    for(0 => int i; i < fft.size()/4; ++i) {
        if(spect[i] > max) {
            spect[i] => max;
            i => where;
        }
    }
    // get frequency of peak
    (where $ float) / fft.size() * srate => float f; 
    // then convert it to MIDI pitch
    f => Math.ftom => float p;
    // plus a major third
    4 +=> p; 
    // set lower boundary: prevents note too low
    Math.max(20, p) => p;
    // new freq if not noise
    if(db > 10.0) {
       smf.setNext(Math.mtof(p));
    }
}


// @class Smooth
// @desc contral signal generator for smooth transition
class Smooth
{
    // audio graph
    Step in => Gain out => blackhole;
    Gain fb => out;
    out => fb;
    
    // init: smoothing coefficient, default no smoothing
    0.0 => float coef;
    initGains();
    
    // initGains()
    fun void initGains() {
        in.gain(1.0 - coef);
        fb.gain(coef);
    }
    
    // setNext(): set target value
    fun void setNext(float value) { 
        in.next(value); 
    }
    
    // getLast(): return current interpolated value
    fun float getLast() {
        1::samp => now; 
        return out.last(); 
    }
    
    // setExpo(): set smoothing directly from exponent
    fun void setExpo(float value) { 
        value => coef;
        initGains();
    }
    
    // setTimeConstant(): set smoothing duration
    fun void setTimeConstant(dur duration) {
        Math.exp(-1.0 / (duration / samp)) => coef;
        initGains();
    }
} // END OF CLASS: Smooth
