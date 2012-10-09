// reads mono file and processes with cubic non-linearity while writing mono file

string filename0;
"/usr/ccrma/web/html/courses/220a/jukebox/simulationNot.wav" => filename0;
string filename1;
"/zap/test.wav" => filename1;
<<< "processing mono sound file ",filename0," into ",filename1>>>;

SndBuf w0 => Gain g => WvOut w1 => blackhole;
3=>w1.op; // multiply inputs -- see below
g => w1; // times itself
g => w1; // again
g.gain(1.5); // depends on input, might need boost
filename0 => w0.read;
filename1 => w1.wavFilename;

w0.length() => dur l;
now + l + 1::second => time then; // 1 second tail
while( now < then )
{
100::samp => now;
}

w1.closeFile();

/*
# op(int) (of type int): set/get operation at the UGen. Values:

    * 0 : stop - always output 0
    * 1 : normal operation, add all inputs (default)
    * 2 : normal operation, subtract inputs starting from the earliest connected
    * 3 : normal operation, multiply all inputs
    * 4 : normal operation, divide inputs starting from the earlist connected
    * -1 : passthru - all inputs to the ugen are summed and passed directly to output

*/


