4 => int nChans;

SndBuf ch[nChans];
 
for (0=>int i; i<nChans; i++) 
{
  string tname;
  if(i==0) "RF" => tname;
  else if(i==1) "LF" => tname;
  else if(i==2) "LR" => tname;
  else "RR" => tname;
  "/usr/ccrma/web/html/courses/220a-fall-2011/jukebox/turenas4ch/turenas"+tname+".wav" => string Xname;
<<<Xname>>>;
    new SndBuf @=> ch[i];
    Xname => ch[i].read;
    ch[i] => dac.chan(i);
    ch[i].pos(48000*40); // to advance the position further into the file -- 40 secs
}

while(true){1::day=>now;};

