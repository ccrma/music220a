/*
    define a functuon "clip" which is reused when spawning
    SndBuf .wav file readers in a sequence
    the main program (aka main shred) starts the sequence at time0 and 
    ends when it has nothing left to do
    LOOK FOR *Change Me* TO MAKE IT WORK FOR YOUR FILE NAMES AND DIRECTORIES
    for this demo DIRECTORY = 
*/

fun void clip(string name)         // define "clip" as a function
{
  SndBuf2 mySnd => dac;            // wire up a sound file reader and connect to the DAC
  mySnd.read(name);                // specify the file name
  mySnd.length() => dur myDur;     // get the duration
  now => time myBeg;
<<< name, "is playing at", myBeg/second, "for", myDur/second,"seconds">>>;
  myBeg + myDur => time myEnd;
  while (now < myEnd) 1::samp => now;
}

// start the sequence of clips
// each runs as an independent shred when sporked
now => time time0;
spork ~clip("test1-48panRev.wav"); // spork the first clip shred  // *Change Me*
3::second => now;	                 // advance time
spork ~clip("test2-48panRev.wav"); // spork another, etc. // *Change Me*
3::second => now;	
spork ~clip("test3-48.wav");       // *Change Me*
3::second => now;	
spork ~clip("test4panRev-48.wav"); // *Change Me*
12::second => now;                 // keep the main shred so it outputs as long as needed
me.yield(); // on this exact sample, yield main shred so last spork job can finish first

now => time time1; 

// last thing in this program is this print statement
<<<"clips played for",(time1-time0)/second,"seconds">>>;

// and with nothing left to do this program now exits 
