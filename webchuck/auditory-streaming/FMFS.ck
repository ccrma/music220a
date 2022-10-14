// -------------------------------------------------------------
// @class FMFS
// fm implementation from scratch with envelopes
// @author 2015 Madeline Huberth, 2022 version by CC
public class FMFS
{ // two typical uses of the ADSR envelope unit generator...
    Step unity => ADSR envM => blackhole; //...as a separate signal
    SinOsc mod => blackhole;
    SinOsc car => ADSR envC => Gain out;  //...as an inline modifier of a signal
    car.gain(0.2);
    float freq, index, ratio; // the parameters for our FM patch
    fun void fm() // this patch is where the work is
    {
      while (true)
      {
        envM.last() * index => float currentIndex; // time-varying index
        mod.gain( freq * currentIndex );    // modulator gain (index depends on frequency)
        mod.freq( freq * ratio );           // modulator frequency (a ratio of frequency) 
        car.freq( freq + mod.last() );      // frequency + modulator signal = FM 
        1::samp => now;
      }
    }
    spork ~fm(); // run the FM patch

    // function to play a note on our FM patch
    fun void playFM( dur length, float pitch, float pitchRatio, float carrierADSR[], float modulationRatio, float mGain, float modulatorADSR[] ) 
    {
        // set patch values
        pitchRatio * pitch => freq;
        modulationRatio => ratio;
        mGain => index;
       // run the envelopes
        spork ~ playEnv( envC, length, carrierADSR );
        spork ~ playEnv( envM, length, modulatorADSR );
        length => now; // wait until the note is done
    }

    fun void playEnv( ADSR env, dur length, float adsrValues[] )
    {
        // set values for ADSR envelope depending on length
        length * adsrValues[0] => dur A;
        length * adsrValues[1] => dur D;
        adsrValues[2] => float S;
        length * adsrValues[3] => dur R;
        
        // set up ADSR envelope for this note
        env.set( A, D, S, R );
        // start envelope (attack is first segment)
        env.keyOn();
        // wait through A+D+S, before R
        length-env.releaseTime() => now;
        // trigger release segment
        env.keyOff();
        // wait for release to finish
        env.releaseTime() => now;
    }
    fun void playFMtestTone() 
    { 
      out => dac; // connect output
      playFM(0.9::second, 440.0, 1.0, [.01,.4,.5,.1], 1.0, 10.0, [.01,.4,1.0,.1]);
      out =< dac; // disconnect output
    }    
}  // end of FMFS class definition 

