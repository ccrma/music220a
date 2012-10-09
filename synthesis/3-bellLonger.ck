// longer tones to hear "bell-ness" from envelopes

2 => int nChans;

TubeBell ch[nChans];

for (0=>int c; c<nChans; c++) 
{
    new TubeBell @=> ch[c];
    ch[c].gain(0.0);
    ch[c] => dac.chan(c);
}

0.2 => float amp;

fun void beep( int n )
{
   n-1 => int c;
   for (0=>int i; i<n; i++) 
   {
     ch[c].noteOn(1.0); 
     ch[c].gain(amp);
     1000::ms => now;  // longer tone
     ch[c].gain(0.0);
     100::ms => now;
   }
   500::ms => now;
}

while (true) for (1=>int n; n<=nChans; n++) beep(n);

