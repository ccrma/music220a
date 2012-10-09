// @title DacBeeps.ck
// @author Chris Chafe (cc@ccrma), Hongchan Choi (hongchan@ccrma)
// @desc test tone generator for multichannel speaker setup
// @revision 1
// @version chuck-1.3.1.3


0.2 => float VOLUME; // overall volume

// fetching number of channels from system
dac.channels() => int nChans;
<<< "[DacBeeps] Number of channels =", nChans >>>;

// declare an array of oscillators
SinOsc sine[nChans];

// iterate on each channel
for (0 => int i; i < nChans; ++i) {
    // mute it
    0.0 => sine[i].gain;
    // connect it to a dac channel
    sine[i] => dac.chan(i);
}

// beep(): beep once for channel 0, twice for channel 1, etc.
fun void beepChannel(int id) {
    id - 1 => int channel;
    for (0 => int i; i < id; ++i) {
        sine[channel].gain(VOLUME); // unmute
        100::ms => now;  // stall
        0.0 => sine[channel].gain; // mute
        100::ms => now;  // stall
    }
}

// create an infinite pattern that rotates around the speakers
while(true) {
    for (1 => int i; i <= nChans; ++i) {
        beepChannel(i);
        500::ms => now; // wait for next beep
    }
}