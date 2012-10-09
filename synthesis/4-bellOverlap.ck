// use noteOff
// overlap requires multiple voices per channel
// assign output channel in the beep function

2 => int nChans;

// same number of UGens but they'll switch channels
TubeBell ch[nChans];

for (0=>int c; c<nChans; c++) 
{
    new TubeBell @=> ch[c];
    ch[c].gain(1.0/nChans); // automatically scale output
}

fun void beep( int n )
{
   n-1 => int c; 
   for (0=>int i; i<n; i++) 
   {
     ch[i] => dac.chan(c); // connect bells to this channel
     ch[i].noteOn(1.0); 
     1000::ms => now;
   }
   500::ms => now;
   for (0=>int i; i<n; i++) 
   {
     ch[i].noteOff(0.0);  // leave gain up, damp with noteOff
     1000::ms => now;
   }
   for (0=>int i; i<n; i++) ch[i] =< dac.chan(c); // disconnect bells from this channel
}

while (true) for (1=>int n; n<=nChans; n++) beep(n);

