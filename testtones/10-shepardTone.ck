7 => int NUMOSC;
fun void shep (float initfreq, float freqmultiplier, float pan, dur speed) 
{
  SinOsc oct[NUMOSC];
  int i;
  float currentfreq;
  0 => int lowestosc;
  std.ftom(initfreq) => float omcf;  // Original Midi Center Frequency
  float newvolume;   
  for (0=>i; i<oct.cap(); i++) 
  {
    oct[i] => Pan2 p1 => dac;
    pan => p1.pan;
    std.mtof( omcf+(12*(i-(NUMOSC-1)/2)) )=> oct[i].freq;
  }
  while (true) 
  {
    for (0=>i; i<oct.cap(); i++) 
    {
	  oct[i].freq()*freqmultiplier=>currentfreq;
	  currentfreq => oct[i].freq;
	  std.fabs(omcf-std.ftom(currentfreq)) => newvolume;
	  1.0-(newvolume/40.0) => newvolume;
	  if (newvolume<0) 
      {
		if (i==lowestosc) 
        {
		  if (lowestosc==0)
		    oct[(oct.cap()-1)].freq()*2*freqmultiplier=>currentfreq;
		  else
		    oct[(i-1)].freq()*2=>currentfreq;
		    currentfreq => oct[i].freq;
		    std.fabs(omcf-std.ftom(currentfreq))/2.0 => newvolume;
		    newvolume/20.0 => newvolume;
		    1-newvolume => newvolume;
		    if (newvolume<0) 0=>newvolume;
		    newvolume/4 => oct[i].gain;
		    lowestosc+1 => lowestosc;
		    if (lowestosc==oct.cap()) 0=>lowestosc;
		  }
		else
		  0=>newvolume;
	  } 
        else 
	      newvolume/4 => oct[i].gain;
	}
	speed=>now;
  }
}

spork ~ shep(440,0.995,0,20::ms);

while (true){
    4::second=>now;
}
