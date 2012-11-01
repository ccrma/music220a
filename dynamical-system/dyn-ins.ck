// dyn-ins.ck
// demo of dynamical system tones

// uses the same iterated map on a second-order
// polynomial function as in dyn-notes.ck

class MapTick
{
// implement the map in unit generaros
// a0 + (a1 * x) + (a2 * x * x);
// chuck-1.2.0.8 disallows duplicate input connections

	Gain x => Gain x1;
	x => Gain x2;
	x => Gain x2b => x2;

// multiply inputs
	3 => x1.op; 
	3 => x2.op;

	Step c; // provide a constant signal of 1.0
	c => Gain a0 => Gain out;
	c => Gain a1 => x1 => out;
	c => Gain a2 => x2 => out;
		
	out => Envelope e => dac => x;

	fun void startNote( float c)
	// modify a0 coefficient
	{
		c => a0.gain;
		-0.7 => a1.gain;
		2.0 => a2.gain;
		e.keyOn();
		50::ms => dur t => e.duration;
	}
	fun void stopNote()
	{
		e.keyOff();
	}
}

// to write soundfile specify file name
string writeName;
"/zap/dyn.wav" => writeName;
if (writeName!="")
{
	dac => WvOut o => blackhole;
	writeName => o.wavFilename;
}


// how many tones to play in the demo
15 => int numTones;
// instantiate one MapTick object, call it "ins"
MapTick ins;

// loop by one tone at a time
for( int ctr; ctr < numTones; ctr++ )
{
// calculate a ramp that increases over the demo
	(((ctr)$float)/(numTones-1$float)) => float ramp;
// ramp the a0 coefficient and print
	-0.3 + (ramp * (-0.7 - -0.3)) => float a0;
    	<<< "a0:", a0 >>>;
	ins.startNote(a0);
	400::ms => now;
	ins.stopNote();
	100::ms => now;
}
