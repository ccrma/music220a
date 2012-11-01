// dyn-notes.ck
// demo of dynamical system melodies

// uses this iterated map, a second-order
// polynomial function 
fun float mapTick( float  x, float  a0)
{
// set the constants in the polynomial
	-0.7 => float a1;
	2.0 => float a2;
// return the next value of the map
	return a0 + (a1 * x) + (a2 * x * x);
}

// to write soundfile specify file name
string writeName;
"/zap/dyn.wav" => writeName;
if (writeName!="")
{
	dac => WvOut o => blackhole;
	writeName => o.wavFilename;
}

public class Clarenv
{
// STK Clarinet with envelope
	Clarinet m => Envelope e => dac;
// method to play
	fun void startNote( float f)
	{
	        f => m.freq;
		1.0 => m.startBlowing;
		e.keyOn();
		50::ms => dur t => e.duration;
	}
// method to stop
	fun void stopNote()
	{
		e.keyOff();
		1.0 => m.stopBlowing;
	}
}

// how many phrases to play in the demo
15 => int numRiffs;
// instantiate one Clare object, call it "ins"
Clarenv ins;

// loop by one phrase at a time
for( int ctr; ctr < numRiffs; ctr++ )
{
// calculate a ramp that increases from 0 to 1 over the phrases
	(((ctr)$float)/(numRiffs-1$float)) => float ramp;
// set the initial condition the same for each phrase
	0.1 => float x;
// ramp the a0 coefficient and print it
	-0.3 + (ramp * (-0.7 - -0.3)) => float a0;
    	<<< "a0:", a0 >>>;
// play a 10-note phrase with melody based on iterated map
	for( int i; i < 10; i++ )
	{
		mapTick(x, a0) => x;
		Math.min (Math.max ( (440.0 + (x * 220.0)), 50.0), 4000.0) => float freq;
		ins.startNote(freq);
	        100::ms => now;
		ins.stopNote();
	}
	500::ms => now;
}
