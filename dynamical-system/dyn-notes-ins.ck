// dyn-notes-ins.ck
// use same dynamical system for tones as for pitches
// based on dyn-notes.ck and dyn-del-ins.ck

fun float map( float  x, float  a0)
{
	-0.7 => float a1;
	2.0 => float a2;
	return a0 + (a1 * x) + (a2 * x * x);
}

public class MapTick
{

	Gain x => Gain x1;
	x => Gain x2;
	x => Gain x2b => x2;
	3 => x1.op; 
	3 => x2.op;
// clarinet-like pitches, envelope moved to map
	Step c => Envelope e => Gain a0 => Gain out;
	c => Gain a1 => x1 => out;
	c => Gain a2 => x2 => out;
		
	out => dac => DelayL d => OneZero lpf => Gain loop => x;

	fun void startNote( float f, float a)
	{
		1.0::second/f => d.delay;
		a => a0.gain;
		-0.7 => a1.gain;
		2.0 => a2.gain;
		0.95 => loop.gain;
		150::ms => dur t => e.duration;
		e.keyOn();
	}
	fun void stopNote()
	{
		0.0 => loop.gain;
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

MapTick ins;
15 => int numRiffs;

for( int ctr; ctr < numRiffs; ctr++ )
{
	(((ctr)$float)/(numRiffs-1$float)) => float ramp;
	0.1 => float x;
	-0.3 + (ramp * (-0.7 - -0.3)) => float a0;
    	<<< "a0:", a0 >>>;
	for( int i; i < 10; i++ )
	{
		map(x, a0) => x;
		Math.min (Math.max ( (440.0 + (x * 220.0)), 50.0), 4000.0) => float freq;
		ins.startNote(freq, -0.4);
	        100::ms => now;
		ins.stopNote();
	}
	500::ms => now;
}
