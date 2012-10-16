// @title Binaural4.ck
// @author Chris Chafe (cc@ccrma) 
// @desc Simulates the head being surrounded by 4 speakers and 
//   delivers tailored signals to each ear, as if coming from 
//   the speakers.
// @note Plug headphones into dac.chan(1-2) and start it after
//   it's started, other shreds can send their signals to 
//   Binaural.pssp[1-4] which are the "psuedo speakers" in quad
//   formation. Impulse responses were made from each speaker 
//   to each ear using the nearfield quad setup in the CCRMA 
//   ballroom with help from Jonathan Abel.
// @version chuck-1.3.1.3
// @revision 2

// name:: Binaural4
// desc:: 4-channel binaural simulator
public class Binaural4
{
    // number of synthesized point sources 
    // which will be the number of speakers that produced impulse responses
    ["ch1", "ch2", "ch3", "ch4"] @=> string azims[];
    ["e0"] @=> string elevs[];
    azims.cap() * elevs.cap() => int nChans;
    
    // psuedo speakers
    static Gain @ pssp[nChans];
    for (0 => int i; i < nChans; ++i) new Gain @=> pssp[i];
    
    // function to convolve 1 input with 1 ear
    fun void mixEar(int chan, int e) {
        string ear;
        if (!e) "l" => ear; else "r" => ear;
        azims[chan%azims.cap()] + ear => string name;
        
        // impulse response location
        "[your_IR_file_path_here]"+name+".wav" => string Yname;
        SndBuf Ybuf;
        Yname => Ybuf.read;
        Ybuf.gain(50.0);
        FFT X;
        Delay del;
        
        // patch input to fft
        if ((chan == 0) || (chan == 3)) {
            pssp[chan] => X => blackhole;
        } else { 
            // compensate rear angles a bit with ITD and IID
            pssp[chan] => del => X => blackhole;
            0.5::ms => dur ITD;
            2.5 => float IID;
            if (chan == 1) {
                if (e == 0) del.delay(0::ms); 
                else del.delay(ITD);
                if (e == 0) del.gain(IID); 
                else del.gain(1.0/IID);
            } else {
                if (e == 0) del.delay(ITD); 
                else del.delay(0::ms);
                if (e == 0) del.gain(1.0/IID); 
                else del.gain(IID);
            }
        }
        
        // patch impulse response to fft
        Ybuf => FFT Y => blackhole;
        // patch output to dac
        IFFT ifft => dac.chan(e);
        
        // set FFT size
        1024 => int FFT_SIZE;
        if (FFT_SIZE < (Ybuf.samples())) <<<"need longer fft ", FFT_SIZE, Ybuf.samples()>>>;
        FFT_SIZE => X.size => Y.size;
        // desired hop size
        FFT_SIZE / 4 => int HOP_SIZE;
        // set window and window size
        Windowing.hann(FFT_SIZE) => X.window;
        Windowing.rectangle(FFT_SIZE) => Y.window;
        Windowing.hann(FFT_SIZE) => ifft.window;
        // use this to hold contents
        complex Z[FFT_SIZE/2];
        
        // feed impulse response into fft buffer
        Ybuf.samples()::samp + now => time ir; // zero pad
        while(now < ir) FFT_SIZE::samp => now;
        Ybuf =< Y =< blackhole;
        // take ir's fft
        Y.upchuck();
        
        while(true) {
            // take incoming signal's fft
            X.upchuck();
            
            // multiply
            for(0 => int i; i < X.size()/2; ++i) {
                //Math.sqrt((Y.cval(i)$polar).mag) * X.cval(i) => Z[i]; // ask about this?
                2 * Y.cval(i) * X.cval(i) => Z[i];
            }
            
            // take ifft
            ifft.transform( Z );
            
            // advance time
            HOP_SIZE::samp => now;
        }
    }
    
    // mixing matrix 24x2
    for (0 => int i; i < nChans; ++i) {
        spork ~ mixEar(i,0);
        spork ~ mixEar(i,1);
    }
} // END OF CLASS: Binaural4