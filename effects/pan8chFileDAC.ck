// tell how many DAC channels in your Chuck preferences
// choose a speaker pattern and whether to useITD (headphones)
// and / or useREV (for distance)
8 => int chansChuck;
false => int useITD; // only if using headphones
false => int useREV; // for distance effect, false = azimuth only

// panning and distance envelopes (no doppler envelope)
// demonstrates intensity panning via interaural intensity difference (IID) and
// square-law distance effect (direct / reverb) and
// some effect of interaural time delay (ITD)

string filename0;
"/usr/ccrma/web/html/courses/220a-fall-2010/jukebox/simulationNot.wav" => filename0;
//"/home/cc/220a/jukebox/simulationNot.wav" => filename0;

// speaker patterns, these examples for CCRMA rooms have speakers numbered in a Z pattern
[0, 1] @=> int stereo[];          // 2 chans
[0, 1, 3, 2] @=> int four4[];     // 4 chans in a 4 channel room -- Classroom, workstations
[0, 1, 3, 5, 7, 6, 4, 2] @=> int eight8[]; // 8 chans in any of the 8 channel rooms

[0, 1, 2, 3] @=> int four4circle[]; // Banff
[0, 1, 2, 3, 4, 5, 6, 7] @=> int eight8circle[]; // Banff
//[0, 1, 7, 6] @=> int four8Long[]; // 4 chans in 8 channel rectangular setup using front / back -- Stage
//[2, 3, 5, 4] @=> int four8Mid[];  // 4 chans in 8 channel rectangular setup using middle group -- Stage
//[0, 3, 7, 4] @=> int four8[];     // 4 chans in 8 channel -- Listening Room, Studios D & E

// choose a pattern from above
eight8 @=> int mapChan[];

mapChan.cap() => int nChans;        
1.0::ms => dur width;               // time travel across your head
0.03 => float revAmt;

for (nChans => int i; i < chansChuck; i++) dac.chan(i).gain(0.0);
for (0 => int i; i < nChans; i++) dac.chan(i).gain(1.0);
SndBuf src;
//SinOsc src;

class Move
{
  Gain direct;
  NRev rev;
  DelayL itd[nChans];     
  Gain g[nChans];       

SawOsc recede => blackhole;
recede.width(1.0);
recede.freq(0.125);
recede.phase(pi/4);

SawOsc rotate => blackhole;
rotate.width(1.0);
rotate.freq(0.125);
rotate.phase(pi/4);

  if (useREV) 
  {
    src => direct;
    src => rev => dac;
    rev.gain(revAmt);
  }
  if (useITD) 
  {
    if (useREV) 
      for (0 => int i; i < nChans; i++) direct => itd[i] => dac.chan(mapChan[i]);
    else
      for (0 => int i; i < nChans; i++) src => itd[i] => dac.chan(mapChan[i]);
    for (0 => int i; i < nChans; i++) itd[i].delay(width); // set here in case not set later
  } else {
    if (useREV) 
      for (0 => int i; i < nChans; i++) direct => g[i] => dac.chan(mapChan[i]);
    else
      for (0 => int i; i < nChans; i++) src => g[i] => dac.chan(mapChan[i]);
  }
  
  fun void run() 
  { 
    while (true)
    {
      (recede.last()+1.0) * 2.0 => float dist; // 0.0 - 1.0 - 2.0 inside head, speaker circle, distant
      //1.0 => dist; // for constant distance
      if (dist > 1.0) 
      {
          direct.gain( 1.0 / (dist*dist) );
          if (useREV) rev.gain(revAmt);
      } else {
          direct.gain(1.0);
          if (useREV) rev.gain(revAmt * Math.pow(dist,2.0));
      }
      (rotate.last()+1.0)*0.5 => float theta; // 0.0 - 1.0 for full rotation
      //0.3 => theta; // for constant angle
      //<<<theta>>>;
      Math.min(1.0, dist) => float distInside;
      for (0 => int i; i < nChans; i++) 
      {
        Math.sin(
          Math.max(0.0, 1.0 - 
            Math.fabs(
              Math.fmod(theta+0.5+(((nChans-i) $ float) /nChans), 1.0)
                - 0.5)
                  * (nChans*distInside))) * (distInside/2.0+0.5) => float chanAmp;
        if (useITD) 
        {
            itd[i].gain( chanAmp );                             // interaural intensity difference
            itd[i].delay( distInside * width * Math.asin(1.0 - chanAmp) );   // interaural time delay
        } else { 
            g[i].gain( chanAmp );
        }
      }
      10::ms => now;
    }
  }
  spork ~ run(); // run run
}
Move loc;

while (true)                    // loop input file
{
  filename0 => src.read;        // read file again
  src.length() => dur l;        // how long file lasts
  l => now;
}