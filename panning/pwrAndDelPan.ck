// combined power and delay panning

adc => DelayL left => dac.left;
adc => DelayL right => dac.right;

class Dizzy { // up/down sweeping in range 0.0 to 1.0
  TriOsc t => Gain sum => blackhole;  // triangle wave -1.0 to 1.0
  Step u => sum;                      // add offset from Step UG
  1.0 => u.next;                      // offset is 1.0, range now 0.0 to 2.0
  0.5 => sum.gain;                    // scale gain output, now 0.0 to 1.0
  public float freq( float f )  { f => t.freq; }
  public float last() { return sum.last(); }
}

Dizzy lfo;
0.5 => lfo.freq;                    // set lfo to 2 second cycle

while (true)
{
  lfo.last() => float pan;          // get pan from most recent lfo value
  // ITD
  1.0 => float width;               // 1ms for headphones, less for speakers
  pan * width * 1::ms => left.delay;
  (1.0 - pan) * width * 1::ms => right.delay;
  ( pi / 2.0 ) *=> pan;             // range 0.0 to pi/2
  // IID
  Math.cos( pan )=> left.gain;
  Math.sin( pan ) => right.gain;
  0.001::second => now;
}
