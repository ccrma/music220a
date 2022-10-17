// -------------------------------------------------------------
// @class ISO
// a monophonic 4 against 3 pattern
// @author 2022 CC
public class ISO
{ 
// -------------------------------------------------------------
// array to hold midi pitches (key numbers) 
// these will be converted into the carrier frequencies
[60, 62, 64, 65] @=> int keyNum[];

// how many pitches are in the array
keyNum.cap() => int nPitches;

// -------------------------------------------------------------
// against a cycle of a different length which we'll use to vary 
// instrument parameters
nPitches - 1 => int nInstruments;

// arrays to hold modulation frequency, timing of modulation envelope, 
// and timing/gain of carrier ADSRs
// really, anything that we want to use to break the repeating pitches
// into multiple streams

// FMFS is a custom class, "FM From Scratch"
// instantiate nInstruments instances of the class
// make arrays for carrier amplitude & carrier amplitude envelope breakpoints, 
// and modulation frequency ratio & index & modulation envelope breakpoints
// ADSR stands for "Attack-Decay-Sustain-Release"
FMFS fm[nInstruments];
float carrierAmp[nInstruments];
float carrierADSR[nInstruments][0]; // 2d array, second dimension will hold an array of float values for ADSR
float pitchRatio[nInstruments];
float modulationRatio[nInstruments];
float modulationIndex[nInstruments];
float modulatorADSR[nInstruments][0];
for (0 => int i; i < nInstruments; i++) 
{
    [1.0,2.0,4.0] @=> pitchRatio;
    1.5 + Math.pow(i,3.1) => modulationRatio[i];
    Math.pow(i,3) => modulationIndex[i];
    [1.0,.04,.5,.1] @=> carrierADSR[i];
    [0.01,.4,1.0,.1] @=> modulatorADSR[i];
    fm[i].out => dac.chan(i%2);
    <<<"instrument",i,": pitchRatio", pitchRatio[i],"  modulationRatio", modulationRatio[i],"  modulationIndex", modulationIndex[i]>>>;
}

// -------------------------------------------------------------
// global parameters

// set a common note duration
100::ms => dur duration;
// initial interOnsetInterval (inverse of tempo)
800::ms => dur interOnsetInterval;
160::ms => dur minInterOnsetInterval;
// index for which pitch is next
0 => int p;
// index for which instrument is next                         
0 => int i;


// accelerate to this smallest interOnsetInterval 

  fun void go(dur howLong, float accel, dur minInterOnsetInterval) {
    now => time beg;
    beg + howLong => time end;
    while (now < end) {
      <<< "Pitch (",p,") keyNum =", keyNum[p], "\tInstrument(", i, ")">>>;
      Std.mtof(keyNum[p]+12.0) => float carrierFreq;
    // play the note
      spork ~fm[i].playFM(duration, carrierFreq, pitchRatio[i], carrierADSR[i], modulationRatio[i], modulationIndex[i], modulatorADSR[i]);
    // increment pitch and instrument
      p++;
      i++;
    // cycle pitches through full array
      nPitches %=> p;
    // cycle instruments through full array
      nInstruments %=> i;
    
    // advance time by interOnsetInterval and calculate the next interval
      interOnsetInterval => now;
    // accelerate
      if (interOnsetInterval > minInterOnsetInterval) 
        interOnsetInterval * accel => interOnsetInterval;
      else
    // can't go faster than minInterOnsetInterval 
        minInterOnsetInterval => interOnsetInterval;
    }
  }
} // end of ISO class definition 

