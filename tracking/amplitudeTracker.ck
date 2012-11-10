// @title amplitudeTracker.ck
// @author Chris Chafe (cc@ccrma), Hongchan Choi (hongchan@ccrma) 
// @desc A starter code for homework 5, Music220a-2012
// @note amplitude tracking using UAna ugens
// @version chuck-1.3.1.3 / ma-0.2.2c
// @revision 1


// IMPORTANT NOTE: this patch is designed to use microphone.
// If you're using speakers and your microphone at the same time,
// you might experience serious feedback. Make sure to use 
// the headphone or earbuds to avoid it.


// pipe input into analysis audio graph:
// track amplitude to control breath pressure of a clarinet
adc => FFT fft =^ RMS rms => blackhole;

// choose high-quality transform parameters
4096 => fft.size;
Windowing.hann(fft.size()/2) => fft.window;
20 => int overlap;
0 => int ctr;

// actual audio graph and parameter setting
// NOTE: gain 'g' prevents direct connection bug
adc => Gain g => dac.left;
// STK clarinet instrument
Clarinet cl => dac.right;
60 => Std.mtof => cl.freq;
// instantiate a smoother to smooth tracker results (see below)
Smooth sma; 
// set time constant: shorter time constant gives faster 
// response but more jittery values
sma.setTimeConstant((fft.size() / 2)::samp);


// setBlowingPressure()
spork ~ setBlowingPressure();
fun void setBlowingPressure() {
    while (true) {
        // apply smoothed value to pressure
        cl.pressure(sma.getLast()); 
        1::samp => now;
    }
}


// main inf-loop
while(true) {
    // hop in time by overlap amount
    (fft.size() / overlap)::samp => now;
    // then we've gotten our first bufferful
    if (ctr > overlap) {
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
    ctr++;
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