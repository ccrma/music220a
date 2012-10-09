// reads mono file and processes with ResonZ while writing mono file

string filename0;
"/usr/ccrma/web/html/courses/220a/jukebox/simulationNot.wav" => filename0;
string filename1;
"/zap/test.wav" => filename1;
<<< "processing mono sound file ",filename0," into ",filename1>>>;

SndBuf w0 => ResonZ r => WvOut w1 => blackhole;

r.freq(3000.0); // resonance freq
r.Q(300.0); // sharpness
r.gain(30.0); // might need boost

filename0 => w0.read;
filename1 => w1.wavFilename;

w0.length() => dur l;
now + l + 1::second => time then; // 1 second tail
while( now < then )
{
100::samp => now;
}

w1.closeFile();

