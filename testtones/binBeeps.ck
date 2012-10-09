// send to 4 psuedo-speaker channels
// must shred binaural.ck first

4 => int nChans;

SinOsc ch[nChans];

for (0=>int i; i<nChans; i++) 
{
    new SinOsc @=> ch[i];
    ch[i].gain(0.0);
    ch[i] => Binaural.pssp[i];
}

0.2 => float amp;

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

while (true) for (1=>int n; n<=nChans; n++) beep(n);

