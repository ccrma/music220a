// @title DBAP4.ck
// @author Hongchan Choi (hongchan@ccrma)
// @desc General purpose panner for 4-channel configuration. Based
//   on DBAP (distance based amplitude panning) method.
// @revision 2
// @version chuck-1.3.1.3


class DBAP4 extends Chubgraph
{
    // position of speakers: LF, RF, LR, RR (Z-config)
    [[-1.0, 1.0], [1.0, 1.0], [-1.0, -1.0], [1.0, -1.0]]
    @=> float _spks[][];
    
    // position of source
    float _x, _y;
    
    // UGens
    Envelope _in;
    Envelope _out[4];
    NRev _r[4];
    
    // initialization
    inlet => _in;
    20::ms => _in.duration;
    1.0 => _in.target;
    for (0 => int i; i < 4; ++i) {
        _in => _out[i] => r[i] => dac.chan(i);
        // NOTE: for binaural mixdown, use the line below
        // _in => _out[i] => r[i] => b4.pssp[i];
        20::ms => _out[i].duration;
        1.0 => _out[i].target;
        0.1 => r[i].mix;
    }
    
    // setPosition(): implements simple DBAP. the radius 
    // of sound is set to 2.0 by default.
    fun void setPosition(float x, float y) {
        x => _x;
        y => _y;
        for(0 => int i; i < 4; ++i) {
            _spks[i][0] - _x => float dx;
            _spks[i][1] - _y => float dy;
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
    
    // setReverb(): set overall reverb mix parameter
    fun void setReverb(float mix) {
        for (0 => int i; i < 4; ++i) {
            mix => _r[i].mix;
        }
    }
}