// probe HID's

// for linux, first need to get permission for all input devices
// it requires sudo or root privileges, so not for CCRMA machines
// sudo chmod a+r /dev/input/event*
// after which you may need to restart miniAudicle
// (note -- you cannot issue a root command like sudo on a CCRMA machine)

// test your device with example hid/keyboard-organ.ck
// once you know the device number

Hid hid;
for (0 => int kbd; kbd < 100; kbd++) // some large number
{
  if(!hid.openKeyboard(kbd)) 
  {
    <<<"...so exactly",kbd,"devices are available numbered from 0">>>;
    me.exit();
  }
  <<< kbd, hid.name(), "ready">>>;
}

// example output from fedora 23
// in this case, 11 is the keyboard for kbd.ck example
/*
0 HDA Intel PCH Headphone ready 
1 HDA Intel PCH Dock Headphone ready 
2 HDA Intel PCH Mic ready 
3 HDA Intel PCH Dock Mic ready 
4 HDA Intel HDMI HDMI/DP,pcm=8 ready 
5 HDA Intel HDMI HDMI/DP,pcm=7 ready 
6 HDA Intel HDMI HDMI/DP,pcm=3 ready 
7 Integrated Camera ready 
8 ThinkPad Extra Buttons ready 
9 Video Bus ready 
10 Video Bus ready 
11 AT Translated Set 2 keyboard ready 
12 Power Button ready 
13 Sleep Button ready 
14 Lid Switch ready
*/