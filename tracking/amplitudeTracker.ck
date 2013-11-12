// @title amplitudeTracker.ck
// @author Chris Chafe (cc@ccrma), Hongchan Choi (hongchan@ccrma) 
// @desc A starter code for homework 5, Music220a-2012
// @note amplitude tracking using UAna ugens
// @version chuck-1.3.2.0
// @revision 2

// IMPORTANT NOTE: this patch is designed to use microphone.
// If you're using speakers and your microphone at the same time,
// you might experience serious feedback. Make sure to use 
// the headphone or earbuds to avoid it.

// pipe input into analysis audio graph:
// track amplitude to control breath pressure of a clarinet
adc.chan(0) => FFT fft =^ RMS rms => blackhole;
0.5 => float hop;
 2048 => fft.size;
// actual audio graph and parameter setting
// there is an adc disconnect bug when removing shred
// using Gain g is a workaround
adc.chan(0) => Gain g => dac.left;
// STK clarinet instrument
Clarinet cl => dac.right;
60 => Std.mtof => cl.freq;
// instantiate a smoother to smooth tracker results (see below)
Smooth sma; 
// set time constant: shorter time constant gives faster 
// response but more jittery values
sma.setTimeConstant((fft.size() / 2)::samp);

// setBlowingPressure()
fun void setBlowingPressure() {
    while (true) {
        // apply smoothed value to pressure
        cl.pressure(sma.getLast()); 
        1::samp => now;
    }
}
spork ~ setBlowingPressure();

// main inf-loop
while(true) {
    // hop in time by overlap amount
    (fft.size() * hop)::samp => now;
    // we've gotten our first bufferful
    // compute the RMS analysis
    rms.upchuck();
    rms.fval(0) => float a;
    Math.rmstodb(a) => float db;
    // boost the sensitity
    75 +=> db;
    // but clip at maximum 
    Math.min(100, db) => db; 
    sma.setNext(Math.dbtorms(db));      
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