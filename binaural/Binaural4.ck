// @title Binaural4.ck
// @author Chris Chafe (cc@ccrma), Hongchan Choi (hongchan@ccrma) 
// @desc Simulates the head being surrounded by 4 speakers and 
//   delivers tailored signals to each ear, as if coming from 
//   the speakers.
// @note Plug headphones into dac.chan(0-1) and start it after
//   it's started, other shreds can send their signals to 
//   pssp[0-3] which are the "psuedo speakers" in quad
//   formation. Impulse responses were made from each speaker 
//   to each ear using the nearfield quad setup in the CCRMA 
//   ballroom with help from Jonathan Abel.
// @version chuck-1.3.1.3
// @revision 5


// name:: Binaural4
// desc:: 4-channel binaural mixer
public class Binaural4
{
    // MODIFY THIS: file path for IR files
    "___YOUR_PATH_HERE___" => string _path;
    <<< "[BinauralMixer4] IR path:", _path >>>;

    // print startup message
    <<< "[BinauralMixer4] Starting..." >>>;
        
    // number of synthesized point sources which will be 
    // the number of speakers that produced impulse responses
    // NOTE: we are using Z-formation for quad setup (LF-RF-LR-RR)
    ["LeftFront", "RightFront", "LeftRear", "RightRear"] @=> string _channels[];
    _channels.cap() => int _numChannels;
    
    // mixer input: inlets exposed aka psuedo speakers
    Gain input[4];
    
    // convolute each source to one ear
    fun void mixSourceToEar(int channel, string ear) {
        // loading IR file
        _path + _channels[channel] + "_" + ear + ".wav" => string filename;
        SndBuf irbuf;
        filename => irbuf.read;
        50.0 => irbuf.gain; // ???
        
        FFT X;
        Delay dly;
        
        // patch input to fft
        if ((channel == 0) || (channel == 3)) {
            input[channel] => X => blackhole;
        } else { 
            // compensate rear angles a bit with ITD and IID
            input[channel] => dly => X => blackhole;
            0.5::ms => dur ITD;
            2.5 => float IID;
            if (channel == 1) {
                if (ear == "L") {
                    dly.delay(0::ms); 
                    dly.gain(IID); 
                } else {
                    dly.delay(ITD);
                    dly.gain(1.0 / IID);
                }
            } else {
                if (ear == "L") {
                    dly.delay(ITD);
                    dly.gain(1.0 / IID);
                } else {
                    dly.delay(0::ms);
                    dly.gain(IID);
                }                
            }
        }
        
        // patch impulse response to fft
        irbuf => FFT Y => blackhole;

        // patch output to dac
        0 => int output;
        if ( ear == "R" ) 1 => output;
        IFFT ifft => dac.chan(output);
        
        // set FFT parameters
        1024 => int FFT_SIZE;
        if (FFT_SIZE < irbuf.samples()) {
            <<< "[BinauralMixer4] Need longer FFT size:", FFT_SIZE, irbuf.samples() >>>;
        }
        FFT_SIZE => X.size => Y.size;
        FFT_SIZE / 4 => int HOP_SIZE;
        Windowing.hann(FFT_SIZE) => X.window;
        Windowing.rectangle(FFT_SIZE) => Y.window;
        Windowing.hann(FFT_SIZE) => ifft.window;

        // use this to hold contents
        complex Z[FFT_SIZE/2];
        
        // feed impulse response into fft buffer
        irbuf.samples()::samp + now => time ir; // zero pad
        while(now < ir) {
            FFT_SIZE::samp => now;
        }
        irbuf =< Y =< blackhole;
        // take ir's fft
        Y.upchuck();
        
        while(true) {
            // take incoming signal's fft
            X.upchuck();            
            // multiply
            for(0 => int i; i < X.size() / 2; ++i) {
                2 * Y.cval(i) * X.cval(i) => Z[i];
            }
            // take ifft
            ifft.transform( Z );
            // advance time
            HOP_SIZE::samp => now;
        }
    }
    
    // sporking mixing matrix
    for (0 => int i; i < _numChannels; ++i) {
        spork ~ mixSourceToEar(i, "L");
        spork ~ mixSourceToEar(i, "R");
    }
    
    // log message and start loop
    <<< "[BinauralMixer4] Launched successfully." >>>;
    while(true) {
        1::minute => now;
    }
} // END OF CLASS: Binaural4