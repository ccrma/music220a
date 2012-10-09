// panning and distance envelopes (with pitch shifter, but no doppler envelope)
// demonstrates intensity panning via interaural intensity difference (IID) and
// square-law distance effect (direct / reverb) and
// some effect of interaural time delay (IID)

string filename0;
"/usr/ccrma/web/html/courses/220a/jukebox/simulationNot.wav" => filename0;
4 => int nChans;
SndBuf w0 => PitShift p => Gain direct;
w0 => NRev r => Gain rev => dac;
0.001 => rev.gain;
1.0::ms => dur width;               // time delay across ears for motion
DelayL itd[nChans];
for (0 => int i; i < nChans; i++) direct => itd[i] => dac.chan(i);
for (0 => int i; i < nChans; i++) itd[i].delay(width); // set here in case not set later
float chLoc[nChans];
for (0 => int i; i < nChans; i++) (4-i)*pi/2 => chLoc[i];

1.0 => p.mix;
1.0 => p.shift;    // change for moving voice differing from reverb voice
// 4.5 => p.shift; // very odd...

// new class to manage envelopes
class Env
{
  Step s => Envelope e => blackhole; // feed constant into env
  fun void current (float val) { e.value(val); }
  fun void target (float val) { e.target(val); }
  fun void duration (dur val) { e.duration(val); }
}

class Distance extends Env // for gain
{
  fun void run() // sample loop to smoothly update gain
  { 
    while (true)
    {
      direct.gain( Math.pow(e.last(), 2.0) );
      1::samp => now;
    }
  }
  spork ~ run(); // run run
};
Distance distanceMotion;

class Pan extends Env // for gain
{
  fun void run() // sample loop to smoothly update gain
  { 
    while (true)
    {
      e.last() * 0.5 * pi => float angle;
      for (0 => int i; i < nChans; i++) 
      {
        Math.max(0.0, Math.cos(angle + chLoc[i])) => float tmp;
        itd[i].gain( tmp );                             // interaural intensity difference
        itd[i].delay( width * Math.asin(1.0 - tmp) );   // interaural time delay
      }
      1::samp => now;
    }
  }
  spork ~ run(); // run run
};
Pan panMotion;

1 => int close; // like in, I'm close
distanceMotion.current(close);
0 => int spkr;  // like in, I'm on the left
panMotion.current(spkr);
while (true)    // loop input file
{
  filename0 => w0.read;             // read file again
  w0.length() => dur l;             // how long file lasts
// comment out these two distance lines if you just want rotation
  distanceMotion.duration(l);       // is how long to ramp distance
  distanceMotion.target(!close);    // move me close or far
  !close => close;                  // alternating-ly -- is that a word?
  panMotion.duration(l);            // ditto angle panning
  panMotion.target((spkr+1)%nChans);// move me clockwise one speaker
  (spkr+1)%nChans => spkr;          // in a loop
  l => now;
}