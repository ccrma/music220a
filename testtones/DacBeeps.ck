// @title DacBeeps.ck
// @author Chris Chafe (cc@ccrma), Hongchan Choi (hongchan@ccrma)
// @desc test tone generator for multichannel speaker setup
// @revision 2
// @version chuck-1.3.1.3


0.2 => float VOLUME; // overall volume

// fetching number of channels from system
dac.channels() => int nChans;
<<< "[DacBeeps] Number of channels =", nChans >>>;

// declare an array of oscillators
SinOsc sine[nChans];

// iterate on each channel
for (0 => int i; i < nChans; ++i) {
    880 => sine[i].freq;
    0.0 => sine[i].gain;
    sine[i] => dac.chan(i);
}

// beep(): beep once for channel 0, twice for channel 1, etc.
fun void beepChannel(int id) {
    id - 1 => int channel;
    for (0 => int i; i < id; ++i) {
        sine[channel].gain(VOLUME);
        100::ms => now;
        0.0 => sine[channel].gain;
        100::ms => now;
    }
}

// create an infinite pattern that rotates around the speakers
while(true) {
    for (1 => int i; i <= nChans; ++i) {
        <<< "Channel = ", i >>>;
        beepChannel(i);
        1000::ms => now;
    }
}