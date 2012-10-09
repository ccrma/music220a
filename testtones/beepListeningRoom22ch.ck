// test all 22 channels in Listening Room

[0,1,2,3,4,5,6,7, 8,9,10,11,12,13,14, 16,17,18,19,20,21,22] @=> int chanMap[];
//[0,1,2,3,4,5,6,7, 8,9,10] @=> int chanMap[]; // mid ring of 8
//[8,9,10,11,12,13,14] @=> int chanMap[]; // hi ring of 6 then zenith
// skip [15] @=> int chanMap[];
//[16,17,18,19,20,21,22] @=> int chanMap[]; // lo ring of 6 then anti-zenith
chanMap.cap() => int nChans;
fun void beep(int n)
{ 
  SinOsc s => dac.chan(  chanMap[((n-1)%nChans)]  );
  for (0=> int i; i<n; i++)
  {
     s.gain(.2); // gain up
     50::ms => now;  // stall
     s.gain(0.0); // gain down
     50::ms => now;  // stall
  }
}

fun void test()
{
  while (true)
  {
    for (1=> int i; i<=nChans; i++)
    {
      spork ~ beep(i);
      2.5::second - (nChans-i)*.1::second => now;
    }
//  1::second => now;
  }
}

spork ~ test();

1::day => now;
<<<"bye">>>;
