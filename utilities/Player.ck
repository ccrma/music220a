// @title Player.ck
// @author Hongchan Choi (hongchan@ccrma) 
// @desc An utility class for sonification of time series data. 
//   based on Chris Chafe's implementation.
// @note The example below requires "DataReader" class to be declared
//   in VM.
// @version chuck-1.3.1.3
// @revision 2



// name:: EnvGen
// desc:: envelope generator
class EnvGen
{
    200.0 => float _rampTime;
    Step _s => Envelope _e => blackhole;
    _rampTime::ms => _e.duration;
    
    fun void setRampTime(float rampTime) {
        rampTime => _rampTime;
    }
    
    fun void target(float val) {
        _e.target(val);
    }
    
    fun float getSample() {
        return _e.last();
    }
} // END: class EnvGen 


// name:: Player
// desc:: simple sound player using EnvGen class
class Player
{
    SinOsc _s => NRev _rev => dac;
    _rev.mix(0.05);
    EnvGen _amp, _freq;
    
    fun void setAmp(float amp) {
        _amp.target(amp);
    }
    
    fun void setFreq(float freq) {
        _freq.target(freq);
    }
    
    fun void setRampTime(float rampTime) {
        _amp.setRampTime(rampTime);
        _freq.setRampTime(rampTime);
    }

    fun void _run() {
        while(true) {
            _amp.getSample() => _s.gain;
            _freq.getSample() => _s.freq;
            1::samp => now;
        }
    } spork ~ _run(); // run immediately
} // END: class Player 


// -----------------------------------------------------
"[put_your_file_path_here]" => string mydata;

DataReader dr;
dr.load(mydata);
if (!dr.isValid()) me.exit();
<<< "[Player] Now playing :", mydata >>>;

Player ply;
200.0 => float rampTime;
ply.setRampTime(rampTime);

while(dr.next()) {
   dr.getNormalized() => float w;
   ply.setAmp(0.5 * Math.pow(w, 2.0));
   ply.setFreq(Std.mtof(80.0 + w * 20.0));
   
   rampTime::ms => now;
}