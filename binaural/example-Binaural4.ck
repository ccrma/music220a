// @title example-Binaural4.ck
// @author Hongchan Choi (hongchan@ccrma) 
// @desc A simple examplary usage of Binaural4 class
// @version chuck-1.3.1.3 / ma-0.2.2c
// @revision 2

// IMPORTANT: add Binaural4 class first!

// load you audio files
SndBuf buf[4];

// NOTE: set your path here otherwise the VM will fail you.
"___YOUR_FILE_0___" => buf[0].read;
"___YOUR_FILE_1___" => buf[1].read;
"___YOUR_FILE_2___" => buf[2].read;
"___YOUR_FILE_3___" => buf[3].read;

for(0 => int i; i < 4; ++i) {
    buf[i] => Binaural4.input[i];
}

1::minute => now;