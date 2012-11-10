// @title fft2ifft.ck
// @author Chris Chafe (cc@ccrma)
// @desc creating a sinusoid using ifft
// @version chuck-1.3.1.3 / ma-0.2.2c
// @revision 1


// IMPORTANT NOTE: this patch is designed to use microphone.
// If you're using speakers and your microphone at the same time,
// you might experience serious feedback. Make sure to use 
// the headphone or earbuds to avoid it.


// pipe input into analysis
adc => FFT fft => blackhole;

// inverse FFT (overlap/add) to output
IFFT ifft => dac;
ifft.gain(0.35);

// choose high-quality transform parameters
4096 => fft.size => ifft.size;
Windowing.hann(fft.size() / 2) => fft.window;
Windowing.hann(ifft.size() / 2) => ifft.window;
20 => int overlap;
0 => int ctr;

// spectrum storage
complex spectrum[fft.size()/2];


// inf-loop
while(true) {
    // hop in time by overlap amount
    (fft.size() / overlap)::samp => now; 
    // then we've gotten our first bufferful
    if (ctr > overlap) {
        // compute the analysis (run UAnan chain)
        fft.upchuck(); 
        // get the spectrum: fft => spectrum
        fft.spectrum(spectrum);
        // transform back to time domain and add into output buffer
        // spectrum => ifft
        ifft.transform(spectrum); 
    }
    ctr++;
}