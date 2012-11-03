// @title DBAP4e.ck
// @author Hongchan Choi (hongchan@ccrma)
// @desc General purpose panner for 4-channel configuration. Based
//   on DBAP (distance based amplitude panning) method. 
//   Some experimental effects are added to enhance spatial cues.
// @note This class requires Binaural4.ck as a public class
//   https://github.com/hoch/music220a-ccrma/raw/master/binaural/Binaural4.ck
// @version chuck-1.3.1.3 / ma-0.2.2c
// @revision 4


public class DBAP4e extends Chubgraph
{
    // loading public class
    0 => int _BINAURAL;
    
    // warning
    if (dac.channels() < 4) {
        cherr <= "[DBAP4e] insufficient output ports - using binaural mixdown.\n";
        1 => _BINAURAL;
    } else {
        cherr <= "[DBAP4e] using 4-channel configuration.\n";
    }
    
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
        if (_BINAURAL == 0) {
            _in => _out[i] => _d[i] => _r[i] => dac.chan(i);
        } else {
            _in => _out[i] => _d[i] => _r[i] => Binaural4.input[i];
        }
        20::ms => _out[i].duration;
        0.0 => _out[i].target;
        20::ms => _d[i].max;
        0.1 => _r[i].mix;
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
            _spks[i][0] - x => float dx;
            _spks[i][1] - y => float dy;
            dx * dx => dx;
            dy * dy => dy;
            Math.sqrt(dx + dy) => float dist;
            Math.max(0.0, 2.0 - dist) => dist;
            dist => _out[i].target;
        }
    }
    
    // setGain(): set source gain
    fun void setGain(float gain) {
        gain => _in.target;
    }
    
    // setReverb(): set overall reverb mix parameter
    fun void setReverb(float mix) {
        for (0 => int i; i < 4; ++i) {
            mix => _r[i].mix;
        }
    }
    
    // setDelayTime(): set delay time for each delay
    // NOTE: an array of 4 floats between 0.5 ~ 20(ms)
    // ex) d4e.setDelayTime([0.5, 10, 5, 17]);
    fun void setDelayTime(float dt[]) {
        if (dt.cap() < 4) {
            cherr <= "[DBAP4e] invalid array.\n";
            return;
        } else {
            for(0 => int i; i < 4; ++i) {    
                dt[i]::ms => _d[i].delay;
            }
        }
    }
    
    // setMode(): set mode for plain 4 channels or binaural
    fun void setMode(string mode) {
        if (_BINAURAL == 1) {
            cherr <= "[DBAP4e] Can't use plain mode. Insufficient ports.\n";
            return;
        }
        if (mode == "plain") {
            for (0 => int i; i < 4; ++i) {
                _r[i] =< Binaural4.input[i];
                _r[i] => dac.chan(i);
            }
        } else if (mode == "binaural") {
            for (0 => int i; i < 4; ++i) {
                _r[i] => Binaural4.input[i];
                _r[i] =< dac.chan(i);
            }
        }
    }
} // END OF CLASS: DBAP4e