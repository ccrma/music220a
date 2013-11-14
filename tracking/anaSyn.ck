1 => int nChans;
FFT fft[nChans];
for (0=>int c; c<nChans; c++) adc.chan(0) => fft[c] => blackhole;
IFFT ifft[nChans];
for (0=>int c; c<nChans; c++) ifft[c]=> dac;

0.5 => float hop;
1.0 => float inGain;
for (0=>int c; c<nChans; c++) ifft[c].gain(hop/inGain);
for (0=>int c; c<nChans; c++) 2048 => fft[c].size;
for (0=>int c; c<nChans; c++) 2048 => ifft[c].size;
complex s[nChans][fft[0].size()/2];

second / samp => float srate;
srate/fft[0].size() => float binFreq;
fun void ana(int c)
{
  while( true )
  {
    (fft[c].size()*hop)::samp => now;
    //(fft[c].size()*hop)::samp/second +=> chunk;
    fft[c].upchuck();
    for (0=>int i; i<fft[c].size()/2; i++) fft[c].cval(i).re => s[c][i].re;
    for (0=>int i; i<fft[c].size()/2; i++) fft[c].cval(i).im => s[c][i].im;
    ifft[c].transform( s[c] );
    //for (0=>int i; i<fft[c].size()/2; i++) 
    //  Math.sqrt(s[c][i].re*s[c][i].re + s[c][i].im*s[c][i].im) => spect[c][1][i];
  }
} for (0=>int c; c<nChans; c++) spork ~ana(c);
1::day=>now;
