// @title DataReader.ck
// @author Hongchan Choi (hongchan@ccrma) 
// @desc An utility class for sonification of time series data. Including
//   basic normalization process based on Chris Chafe's implementation.
// @note Use data file that -
//   1) each number separated by new line character (LF or CR/LF)
//   2) only contains numbers
// @version chuck-1.3.1.3
// @revision 2


// name:: DataReader
// desc:: general purpose data reader
public class DataReader
{
    FileIO _file;
    float _stream[0];
    int _curPos, _LOOP, _VALID;
    float _min, _max, _range;
    
    // load(): construction and more  
    fun int load(string filename) {
        // initial state
        0 => _curPos;
        0 => _LOOP;
        0 => _VALID;
        // open file and sanity check
        _file.open(filename, FileIO.READ);
        if( !_file.good() ) {
            <<< "[DataReader] Loading failed." >>>;
            return 0;
        }
        // parsing by line until eof   
        <<< "[DataReader] Parsing..." >>>;     
        while(_file.more()) {
            string line;
            _file => line;
            if( line.length() > 0 ) {
                Std.atof(line) => float f;
                _stream << f;
            }
        }
        // calibrating and get min/max
        if ( _stream.size() == 0 ) {
            <<< "[DataReader] Parsing failed (no valid data)" >>>;
            return 0;
        } else {   
            _stream[0] => _min => _max;
            for( 1 => int i; i < _stream.size(); ++i ) {
                _stream[i] => float s;
                if ( s < _min ) s => _min;
                if ( s > _max ) s => _max;
            }
            if ( _max == _min ) {
                <<< "[DataReader] min and max are same" >>>;
                1 => _range;
            } else {
                _max - _min => _range;
            }
            // data is ready to play
            1 => _VALID;
            // greeting
            <<< "[DataReader] Loaded successfully." >>>;
            <<< " +target=", filename, "-", _stream.size(), "points." >>>;
            <<< " +min=", _min, " +max=", _max, " +range=", _range >>>;
            
            return 1;
        }       
    }
    
    // next(): move one step forward in series
    fun int next() {
        _curPos++;
        if (_curPos >= _stream.size()) {
            if (_LOOP) {
                0 => _curPos;
                return 1;
            } else {
                _stream.size() - 1 => _curPos;
                return 0;
            }
        } else {
            return 1;
        }
    }
    
    // prev(): move one step backward in series
    fun int prev() {
        _curPos--;
        if (_curPos <= -1) {
            if (_LOOP) { 
                _stream.size() - 1 => _curPos;
                return 1;
            } else {
                0 => _curPos;
                return 0;
            }
        } else {
            return 1;
        }
    }
    
    // loop(): set loop swtich
    fun void loop(int bool) {
        if (bool == 0) {
            0 => _LOOP;
        } else {
            1 => _LOOP;
        }
    }
    
    // get(): return raw data at current position
    fun float get() {
        return _stream[_curPos];
    }
    
    // getNormalized(): return normalized data (0.0~1.0)
    fun float getNormalized() {
        return (_stream[_curPos] - _min) / _range;
    }
    
    // getCurrentPosition(): return current position
    fun int getCurrentPosition() {
        return _curPos;
    }
    
    // getLength(): return array length
    fun int getLength() {
        return _stream.size();
    }
    
    // setCurrentPosition(): move current position (random access)
    fun void setCurrentPosition(int pos) {
        if (pos > -1 && pos < _stream.size()) {
            pos => _curPos;
            return;
        } else {
            <<< "[DataReader] Invalid position." >>>;
            return;
        }
    }
    
    // reset(): reset transport parameters
    fun void reset() {
        0 => _curPos;
        0 => _LOOP;
    }
    
    // isValid(): is this data playable?
    fun int isValid() {
        return _VALID;
    }
} // END: class DataReader 