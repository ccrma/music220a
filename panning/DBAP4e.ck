// @title DBAP4e.ck
// @author Hongchan Choi (hongchan@ccrma)
// @desc General purpose panner for 4-channel configuration. Based
//   on DBAP (distance based amplitude panning) method. 
//   Some experimental effects are added to enhance spatial cues.
// @revision 1
// @version chuck-1.3.1.3


class DBAP4e extends Chubgraph
{
    // position of speakers: LF, RF, LR, RR (Z-config)
    [[-1.0, 1.0], [1.0, 1.0], [-1.0, -1.0], [1.0, -1.0]]
    @=> float _spks[][];
    
    // position of source
    float _x, _y;
    
    // UGens
    Envelope _in;
    Envelope _out[4];
    DelayA _d[4];
    NRev _r[4];
    
    // initialization
    inlet => _in;
    20::ms => _in.duration;
    1.0 => _in.target;
    for (0 => int i; i < 4; ++i) {
        _in => _out[i] => d[i] => r[i] => dac.chan(i);
        // NOTE: for binaural mixdown, use the line below
        // _in => _out[i] => d[i] => r[i] => b4.pssp[i];
        20::ms => _out[i].duration;
        1.0 => _out[i].target;
        20::ms => _d[i].max;
        0.1 => r[i].mix;
    }
    
    .5::ms => _d[0].delay;
    5::ms => _d[1].delay;
    13::ms => _d[2].delay;
    19::ms => _d[3].delay;            
    
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