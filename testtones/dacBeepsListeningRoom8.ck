8 => int nChans;

// declare an array of oscillators
SinOsc ch[nChans];
[0, 1, 3, 5, 7, 6, 4, 2] @=> int mapChan[];
// for each
for (0=>int i; i<nChans; i++) 
{
    new SinOsc @=> ch[i]; // instantiate an oscillator
    ch[i].gain(0.0);      // mute it
    ch[i] => dac.chan(mapChan[i]); // connect it to a dac channel
}

0.2 => float amp; // overall level

// function to beep once for channel 0, twice for channel 1, etc.
fun void beep( int n )
{
   n-1 => int c;
   for (0=>int i; i<n; i++) 
   {
     ch[c].gain(amp); // unmute
     100::ms => now;  // stall
     ch[c].gain(0.0); // mute
     100::ms => now;  // stall
   }
   500::ms => now; // stall some more
}

// create an infinite pattern that rotates around the speakers
while (true) for (1=>int n; n<=nChans; n++) beep(n);

