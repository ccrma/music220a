// reads mono file and processes with Chorus while writing mono file

string filename0;
"/usr/ccrma/web/html/courses/220a/jukebox/simulationNot.wav" => filename0;
string filename1;
"/zap/test.wav" => filename1;
<<< "processing mono sound file ",filename0," into ",filename1>>>;

SndBuf w0 => Chorus c => WvOut w1 => blackhole;
filename0 => w0.read;
filename1 => w1.wavFilename;

0.9 => c.mix;
10.0 => c.modFreq;
0.1 => c.modDepth;

w0.length() => dur l;
now + l + 1::second => time then; // 1 second tail
while( now < then )
{
100::samp => now;
}

w1.closeFile();




