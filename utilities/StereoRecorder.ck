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

// MODIFY THIS: destination path
// "[your_file_path_here]" => string myPath;
(now / 1000::ms) $ int => Std.itoa => string timetag;
myPath + "L_" + timetag + ".wav" => string filename0; 
myPath + "R_" + timetag + ".wav" => string filename1;
myPath + "Stereo_" + timetag + ".wav" => string final;
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
<<<"[StereoRecorder] Finished! run the following command in a terminal:">>>;
<<<"sox -M "+ filename0 + " " + filename1 + " " + final>>>;