// @title ifft.ck
// @author Chris Chafe (cc@ccrma), Hongchan Choi (hongchan@ccrma) 
// @desc creating a sinusoid using ifft
// @version chuck-1.3.1.3 / ma-0.2.2c
// @revision 1


// inverse FFT (overlap / add) to output
IFFT ifft => dac;
0.35 => ifft.gain;

// set up iFFT: choose high-quality transform parameters
4096 => ifft.size;
Windowing.hann(ifft.size() / 2) => ifft.window;
20 => int overlap;

// make a spectrum with one sinusoid
complex spectrum[ifft.size() / 2];

// frequency of sinusoid
440.0 => float frequency; 
// get samplerate (cf: dur/dur => float)
second / samp => float samplerate;
// range(bandwidth) of frequency bin
samplerate / ifft.size() => float bandwidth;
// get bin index of frequency
frequency / bandwidth => float binIndex;
// casting bin index to integer
Math.round(binIndex) $ int => int i;
// set magintude of selected bin
0.1 => spectrum[i].re;


// inf-loop
while(true) {
    // hop in time by overlap amount
    (ifft.size() / overlap)::samp => now;
    // add in a buffer of time samples
    ifft.transform(spectrum); 
}