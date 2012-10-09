// derived from bowls.ck
// using sines, custom additive synthesis instrument AdditiveSynthBell
// new class to fake a UGen that doesn't already exist in chuck

2 => int nChans;

ChanBells ch[nChans];

for (0=>int c; c<nChans; c++) 
{
    new ChanBells @=> ch[c];
    ch[c].initOnChan(c);
}

fun void beep( int n )
{
   n-1 => int c;
   for (0=>int i; i<n; i++) 
   {
     ch[c].bell[i].noteOn(); 
     1000::ms => now;
    }
   500::ms => now;
}

while (true) for (1=>int n; n<=nChans; n++) beep(n);

class ChanBells
{
  nChans => int myBells; // max number of bells is number of channels
  AdditiveSynthBell bell[myBells]; // so make an array big enough for highest channel
  int myChan; 
  fun void initOnChan(int chan) // function to initialize this instance
  {
    chan => myChan;        // e.g., chan 0
    myChan + 1 => myBells; //       has 1 bell
    for (0=>int b; b<myBells; b++)
    {
        new AdditiveSynthBell @=> bell[b];
        ( 220.0 + (b*3.0) ) => bell[b].baseFreq; // detune slightly, e.g. 220.0 + 3.0
        bell[b].stretchPartials( 2.15 ); // exp
        bell[b].out => dac.chan(myChan);
        bell[b].out.gain(1.0/nChans); // scale according to most populous channel
    }
  }
}


class AdditiveSynthBell
{
  5 => int nSins;
  SinOsc s[nSins];
  ADSR e[nSins];
  Gain out;
  220.0 => float baseFreq;
  for (0=>int i; i<nSins; i++) 
  {
    new SinOsc @=> s[i];
    new ADSR @=> e[i];
    s[i] => e[i] => out;
    1.0/(i + 2) => float rollOff;
    e[i].keyOff();
    e[i].set( 1::ms, rollOff*7::second, 0.001, 10::ms );
    s[i].gain(Math.pow(rollOff, 0.7));
    stretchPartials(1.0);
  }
  fun void noteOn()
  {
    for (0=>int i; i<nSins; i++)  e[i].keyOn();
  }
  fun void stretchPartials(float exp)
  {
    for (0=>int i; i<nSins; i++) s[i].freq(baseFreq + baseFreq * Math.pow(i+1,exp));
  }
}
