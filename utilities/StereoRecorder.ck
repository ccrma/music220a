// @title StereoRecorder.ck
// @arguments [seconds]
// @author Chris Chafe (cc@ccrma), Hongchan Choi(hongchan@ccrma)
// @desc Record the stereo output from dac.chan(0, 1)
// @note Add this code into VM to capture the audio output of dac.
// @version chuck-1.3.2.0
// @revision 2

// use the command line or miniAudicle to specify recording length
// for example, one minute of recording: StereoRecorder.ck:60
// otherwise, this is the default duration of audio file you'll create: 
10.0 => float seconds;
if (me.args()) {
    me.arg(0) => Std.atof => seconds;  
}

// MODIFY THIS: destination path, must be specified in order to run
// for example: 
"/tmp/tmp" => string myPath;
// "[your_file_path_here]" => string myPath;
myPath + ".wav" => string filename; 
<<< "[StereoRecorder] Recording stereo sound file... ", filename >>>;

// pull samples from the dac
dac => WvOut2 w => blackhole;

// assign file name to Ugens
filename => w.wavFilename;

// advance time
now + seconds::second => time later;
while( now < later ) {
    1::ms => now;
}

// close files
w.closeFile();

// end messages
<<<"[StereoRecorder] Finished!">>>;
