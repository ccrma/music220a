// inclusion of a computer keyboard with
// hw4-9combineClarinetChaotic.ck
// type keys in a separate window (like an editor window) to hear the effects
/* key commands =
   `s' perturb the dynamical systems' states
   `o' basePitch down
   `p' basePitch up
*/

// first you should try
// probeHID.ck
// to determine your keyboard's device number
// Hid code below is borrowed from hid/keyboard-organ.ck

// once you know the device number add it below or as an argument to this script

// HID
Hid hi;
HidMsg msg;

// which keyboard
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// open keyboard (get device number from command line)
if( !hi.openKeyboard( device ) ) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;

// patch Clarinet to output
Clarinet clar => NRev rev => dac;
clar.noteOn(0.05);
clar.vibratoGain(0.0);
// set effect mix to full on
rev.mix(0.05);

// smoothing envelope to use for variation
Step unity => Envelope pitchEnv => blackhole;
     unity => Envelope pressEnv => blackhole;
150::ms => dur updateDur;
pitchEnv.duration(updateDur);
pressEnv.duration(updateDur);

// instantiate and initialize logistic maps
// slight differences are fun
Logistic pitch;
pitch.set(0.7, 3.3);
Logistic press;
press.set(0.7, 3.3);
60.0 => float basePitch;

fun void kbd()
{
  while( true )
  {
    // wait for event
    hi => now;

    // get message
    while( hi.recv( msg ) )
    {
        // check
        if( msg.isButtonDown() )
        {
            <<<(msg.which)>>>;
            if(msg.which == 31) // `s'
            { 
              pitch.setState(0.01);
              press.setState(0.66);
            } 
            else if(msg.which == 24) // `o'
            { 
              2.0 -=> basePitch;
            }
            else if(msg.which == 25) // `p'
            { 
              2.0 +=> basePitch;
            }
        }
    }
  }
}
spork ~kbd();

// spork an update function to vary shift amount smoothly
fun void smoothUpdates() 
{
  while( true )
  {
    clar.freq(Std.mtof(basePitch + 12.0 * pitchEnv.last()));
    clar.pressure( (.9 * pressEnv.last()) );
    1::samp => now;
  }
}
spork ~smoothUpdates();

// control loop
while( true )
{
    pitchEnv.target(pitch.tick());
    pressEnv.target(press.tick());
    updateDur => now;
}

class Logistic
{
    float _x, _r;
    false => int isSet;
    fun void set( float x, float r )
    {
        x => _x;
        r => _r;
        true => isSet;
    }
    fun void setState( float x )
    {
        x => _x;
    }
    fun float tick( )
    {
        if (!isSet) 
        {
            <<<"Logistic not set, quitting","\ntry adding something like... 
            <your_obj>.set(0.7, 3.1); 
            for initial x value and r coefficient">>>;
            me.exit();
        }
        (_r * _x) * (1.0 - _x) => _x;
        return _x;
    }
}
