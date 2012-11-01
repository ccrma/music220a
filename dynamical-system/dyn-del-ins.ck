// dyn-del-ins.ck
// demo of dynamical system tones, same as dyn-ins.ck
// but with delay and low-pass filter in feedback

public class MapTick
{

	Gain x => Gain x1;
	x => Gain x2;
	x => Gain x2b => x2;
	3 => x1.op; 
	3 => x2.op;
	Step c;
	c => Gain a0 => Gain out;
	c => Gain a1 => x1 => out;
	c => Gain a2 => x2 => out;
		
	out => Envelope e => dac => DelayL d => OneZero lpf => Gain loop => x;

	fun void startNote( float f)
	{
// set delay to constant, 500 Hz = 2 msec
		2.0::ms => d.delay;
		f => a0.gain;
		-0.7 => a1.gain;
		2.0 => a2.gain;
		0.95 => loop.gain;
		10::ms => dur t => e.duration;
		e.keyOn();
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


MapTick ins;

20 => int numTones;

for( int ctr; ctr < numTones; ctr++ )
{
	(((ctr)$float)/(numTones-1$float)) => float ramp;
	-0.3 + (ramp * (-0.7 - -0.3)) => float a0;
    	<<< "a0:", a0 >>>;
	ins.startNote(a0);
	400::ms => now;
	ins.stopNote();
	100::ms => now;
}
