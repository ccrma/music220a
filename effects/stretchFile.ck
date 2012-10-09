// reads mono file and extends with PitShift up and rate down while writing mono file

string filename0;
"/usr/ccrma/web/html/courses/220a-fall-2010/jukebox/simulationNot.wav" => filename0;
string filename1;
"/zap/test.wav" => filename1;
<<< "processing mono sound file ",filename0," into ",filename1>>>;

SndBuf w0 => PitShift p => WvOut w1 => blackhole;
filename0 => w0.read;
filename1 => w1.wavFilename;

1.0 => p.mix;
2.0 => p.shift; // double
0.5 => w0.rate; // half
w0.length() / w0.rate() => dur l; // extend
now + l => time then;
while( now < then )
{
100::samp => now;
}

w1.closeFile();




