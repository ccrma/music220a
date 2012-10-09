// reads mono file and processes with PitShift while writing mono file
// can be run much faster than real time with
// chuck --silent pitFile.ck

// set your own file names before running this

string filename0;
"/usr/ccrma/web/html/courses/220a/jukebox/simulationNot.wav" => filename0;
string filename1;
"/zap/test.wav" => filename1; // your other name here
<<< "processing mono sound file ",filename0," into ",filename1>>>;

SndBuf w0 => PitShift p => WvOut w1 => blackhole;
filename0 => w0.read;
filename1 => w1.wavFilename;

1.0 => p.mix;
2.5 => p.shift;

w0.length() => dur l;
now + l => time then;
while( now < then )
{
100::samp => now;
}

w1.closeFile();




