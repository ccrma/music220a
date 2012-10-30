// @title DBAP4.ck
// @author Hongchan Choi (hongchan@ccrma)
// @desc General purpose panner for 4-channel configuration. Based
//   on DBAP (distance based amplitude panning) method.
// @version chuck-1.3.1.3 / ma-0.2.2c
// @revision 5


public class DBAP4 extends Chubgraph
{
    // sanity check
    if (dac.channels() < 4) {
        cherr <= "[DBAP4] Insufficient output ports.\n";
        me.exit();
    }
    
    // position of speakers: LF, RF, LR, RR (Z-config)
    [[-1.0, 1.0], [1.0, 1.0], [-1.0, -1.0], [1.0, -1.0]]
    @=> float _spks[][];
    
    // position of source
    float _x, _y;
    
    // UGens
    Envelope _in;
    Envelope _out[4];
    
    // initialization
    inlet => _in;
    20::ms => _in.duration;
    1.0 => _in.target;
    for (0 => int i; i < 4; ++i) {
        // NOTE: for plain 4-ch setup, use this code
        _in => _out[i] => dac.chan(i);
        // NOTE: for binaural mixdown, use the line below
        // b4 is an instance of Binaural4 class
        // _in => _out[i] => b4.pssp[i];
        20::ms => _out[i].duration;
        0.0 => _out[i].target;
    }
    
    // setPosition(): implements simple DBAP. the radius 
    // of sound is set to 2.0 by default.
    fun void setPosition(float x, float y) {
        x => _x;
        y => _y;
        for(0 => int i; i < 4; ++i) {
            _spks[i][0] - x => float dx;
            _spks[i][1] - y => float dy;
            dx * dx => dx;
            dy * dy => dy;
            Math.sqrt(dx + dy) => float dist;
            Math.max(0.0, 2.0 - dist) => dist;
            dist => _out[i].target;
        }
    }
    
    // setGain(): set overall gain
    fun void setGain(float gain) {
        gain => _in.target;
    }
} // END OF CLASS: DBAP4