// @title multiTracker.ck
// @author Chris Chafe (cc@ccrma), Hongchan Choi (hongchan@ccrma) 
// @desc A starter code for homework 5, Music220a-2012
// @note amplitude/frequency tracking using UAna ugens
// @version chuck-1.3.1.3 / ma-0.2.2c
// @revision 1


// pipe input into analysis audio graph:
// track amplitude for amplitude of a StifKarp pluck
// frequency will be max bin amplitude from the spectrum
adc.chan(0) => FFT fft  =^ RMS rms => blackhole;

// choose high-quality transform parameters
2048 => fft.size;
0.5 => float hop;
second / samp => float samplerate;
complex s[fft.size()/2];
float spect[fft.size()/2];

// actual audio graph and parameter setting
// NOTE: gain 'g' prevents direct connection bug
adc => Gain g => dac.left;

// 3 Karplus strings and smoohers
3 => int numStrings; 
StifKarp karplus[numStrings];
Smooth smf[numStrings]; // 3 smoothers

// initialization for karplus strings
for (0 => int i; i < numStrings; ++i) {
    // connect each string to dac
    karplus[i] => dac.right;
    // initial frequency
    60 => Std.mtof => karplus[i].freq;
    // set time constant
    smf[i].setTimeConstant((fft.size() * 5)::samp); 
}

// instantiate a smoother to smooth tracker results
Smooth sma;
 // set time constant
sma.setTimeConstant((fft.size() * 2)::samp);


// setGainAndFreq(): on karplus[i]
fun void setGainAndFreq(int i) {
    // apply smoothed value to gain and frequency
    karplus[i].pluck(sma.getLast());
    karplus[i].freq(smf[i].getLast());
}

0 => int ctr;
// inf-loop
while(true) {
    // hop in time by overlap amount
    (fft.size() * hop)::samp => now;
    // then we've gotten our first bufferful
    // compute the FFT and RMS analyses
    rms.upchuck(); 
    rms.fval(0) => float a;
    Math.rmstodb(a) => float db;
    // boost the sensitity
    30 + db => db;
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
    (where $ float) / fft.size() * samplerate => float f;
    // convert it to MIDI pitch
    f => Std.ftom => float p; 
    // round off fraction (integer)
    Math.floor(p) => p;
    // make it an even integer 
    if (p % 2 == 1) {
        1 -=> p;
    }
    // prevents notes too low
    Math.max(20, p) => p;
    ctr++;
    // restrict to active input
    if(db > 30.0) {
        // usually not
        0 => int pluckSomething;
        // but pick a smoother and update anyway    
        smf[ctr % numStrings].setNext(Std.mtof(p));          
        // rare event, make sure it doesn't favor one instrument
        if(ctr % 2 == 0) {
            1 => pluckSomething;
        }
        // check condition and call control function
        if (pluckSomething == 1) {
            // pick an instrument and pluck it
            setGainAndFreq(ctr % numStrings); 
        }
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
