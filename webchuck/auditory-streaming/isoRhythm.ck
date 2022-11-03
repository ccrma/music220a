public class IsoRhythm {
// array to hold midi pitches (key numbers) 
// these will be converted into the carrier frequencies
  [60, 62, 64, 65] @=> int keyNum[];
// how many pitches are in the array
  keyNum.size() => int nPitches;
  3 => int nInsts;
  FM fm[nInsts];
  new FMVoices @=> fm[0];
  new PercFlut @=> fm[1];
  new Wurley @=> fm[2];
  Pan2 stereo[nInsts];
  for (0 => int i; i < nInsts; i++) fm[i] => stereo[i] => dac;
  100::ms => dur duration;
  fun void play(dur howLong, float accel, dur minInterOnsetInterval) {
// initial interOnsetInterval (inverse of tempo)
    800::ms => dur interOnsetInterval;
// index for which pitch is next
    0 => int p;
// index for which instrument is next                         
    0 => int i;
    now => time beg;
    beg + howLong => time end;
    while (now < end) {
      Std.mtof(keyNum[p]+12.0) => fm[i].freq;
      stereo[i].pan( (i%nInsts - 1) );
      fm[i].noteOn(1.0);
      duration => now;
      fm[i].noteOff(1.0);
// increment pitch and instrument
      p++;
      i++;
// cycle pitches through full array
      nPitches %=> p;
// cycle instruments through full array
      nInsts %=> i;
// advance time by interOnsetInterval and calculate the next interval
      interOnsetInterval => now;
// accelerate
      if (interOnsetInterval > minInterOnsetInterval) 
        interOnsetInterval * accel => interOnsetInterval;
      else
// can't go faster than minInterOnsetInterval 
        minInterOnsetInterval => interOnsetInterval;
    }
  }
} // end of isoRhythm class definition
