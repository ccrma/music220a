// @title example-Binaural4.ck
// @author Hongchan Choi (hongchan@ccrma) 
// @desc A simple examplary usage of Binaural4 class
// @version chuck-1.3.1.3 / ma-0.2.2c
// @revision 1


// NOTE: do not set this to 0 if you have stereo setup!
1 => int BINAURAL_MIX;

SndBuf buf[4];
Binaural4 b4;

// NOTE: set your path otherwise the VM will fail you.
"___YOUR_PATH_HERE___" => buf[0].read;
"___YOUR_PATH_HERE___" => buf[1].read;
"___YOUR_PATH_HERE___" => buf[2].read;
"___YOUR_PATH_HERE___" => buf[3].read;

for(0 => int i; i < 4; ++i) {
    if (BINAURAL_MIX == 1) {
        buf[i] => b4.input[i];
    } else {
        buf[i] => dac.chan(i);
    }
}

1::minute => now;