// reads mono file and processes with NRev while writing mono file

string filename0;
"/usr/ccrma/web/html/courses/220a/jukebox/simulationNot.wav" => filename0;
string filename1;
"/zap/test.wav" => filename1;
<<< "processing mono sound file ",filename0," into ",filename1>>>;

SndBuf w0 => NRev r => WvOut w1 => blackhole;
filename0 => w0.read;
filename1 => w1.wavFilename;

0.1 => r.mix;

w0.length() => dur l;
now + l + 1::second => time then; // 1 second tail
while( now < then )
{
100::samp => now;
}

w1.closeFile();




