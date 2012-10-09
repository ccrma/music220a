// physical model from coupled waveguides, Stk instrument
// allow channels to persist, so 1 bell for ch 1, 2 for ch 2, etc.
// no noteOff, persistent state gives restrike detail

2 => int nChans;

// new class which contains it's own bells, defined below
ChanBells ch[nChans]; 

for (0=>int c; c<nChans; c++) 
{
    new ChanBells @=> ch[c];
    ch[c].initOnChan(c); // set up this instance of ChanBells
}

fun void beep( int n )
{
   n-1 => int c;
   for (0=>int i; i<n; i++) 
   {
     ch[c].bell[i].noteOn(1.0); 
     1000::ms => now;
    }
   500::ms => now;
}

while (true) for (1=>int n; n<=nChans; n++) beep(n);

class ChanBells
{
  nChans => int myBells; // max number of bells is number of channels
  BandedWG bell[myBells]; // so make an array big enough for highest channel
  int myChan; 
  fun void initOnChan(int chan) // function to initialize this instance
  {
    chan => myChan;        // e.g., chan 0
    myChan + 1 => myBells; //       has 1 bell
    for (0=>int b; b<myBells; b++)
    {
        new BandedWG @=> bell[b];
        bell[b].preset(3); // tibetan bowl
        bell[b] => dac.chan(myChan);
        bell[b].freq() + (b*3.0) => bell[b].freq; // detune slightly, e.g. 220.0 + 3.0
        bell[b].gain(1.0/nChans); // scale according to most populous channel
    }
  }
}

