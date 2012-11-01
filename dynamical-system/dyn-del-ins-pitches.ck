// dyn-del-ins.ck
// demo of dynamical system tones playing preset pitch sequence

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
// our notes
[ 61, 63, 65, 66, 68, 66, 65, 63 , 65, 66, 68, 66, 65, 63 , 65, 66, 68, 66, 65, 63 ] @=> int notes[];
notes.cap() => int numTones;

for( int ctr; ctr < numTones; ctr++ )
{
	(((ctr)$float)/(numTones-1$float)) => float ramp;
	-0.4 + (ramp * (-0.5 - -0.4)) => float a0;
    	<<< "a0:", a0 >>>;
	notes[ctr] => int keynum;
	ins.startNote(Std.mtof(keynum),a0);
	250::ms => now;
	ins.stopNote();
100::ms => now;
}
