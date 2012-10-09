// @title StereoRecorder.ck
// @arguments [seconds]
// @author Chris Chafe (cc@ccrma), Hongchan Choi(hongchan@ccrma)
// @desc Record the stereo output from dac.chan(0, 1)
// @note Add this code into VM to capture the audio output of dac.
// @version chuck-1.3.1.3
// @revision 1


// default duration of audio file you'll create: 
10.0 => float seconds;
if (me.args()) {
    me.arg(0) => Std.atof => seconds;  
}

// files will be written into current directory
"earL.wav" => string filename0; 
"earR.wav" => string filename1;
<<< "[StereoRecorder] Recording mono sound files... ", filename0, "|", filename1 >>>;

// pull samples from the dac
dac.chan(0) => WvOut w0 => blackhole;
dac.chan(1) => WvOut w1 => blackhole;

// assign file name to Ugens
filename0 => w0.wavFilename;
filename1 => w1.wavFilename;

// advance time
now + seconds::second => time later;
while( now < later ) {
    100::ms => now;
}

// close files
w0.closeFile();
w1.closeFile();

// end messages
<<<"[StereoRecorder] Done recording! ">>>;
<<<"OSX: To mix them into stereo, use Audacity and merge them into stereo:" >>>;
<<<"CCRMA Linux: To mix them into stereo, run the following command in a terminal:" >>>;
<<<"sox -M earL.wav earR.wav Stereo.wav">>>;