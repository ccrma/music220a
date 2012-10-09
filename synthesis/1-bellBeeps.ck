// derived from testTones/dacBeeps.ck
// FM bell 
// Stk instrument 
// has stretched partials and envelope to give bell sound
// noteOn at beginning, beeps fade out

2 => int nChans;

TubeBell ch[nChans];

for (0=>int c; c<nChans; c++) 
{
    new TubeBell @=> ch[c];
    ch[c].gain(0.0);
    ch[c].noteOn(1.0); // strike, full velocity
    ch[c] => dac.chan(c);
}

0.2 => float amp;

// function to beep the channel number
fun void beep( int n )
{
   n-1 => int c; 
   for (0=>int i; i<n; i++) 
   {
     ch[c].gain(amp);
     100::ms => now;
     ch[c].gain(0.0);
     100::ms => now;
   }
   500::ms => now;
}

// go around channels, beeping the channel number
// infinite loop
while (true) for (1=>int n; n<=nChans; n++) beep(n);

