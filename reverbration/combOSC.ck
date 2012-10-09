// demo of a comb filter (IIR) with slider

// copy/paste into terminal: 
// java -jar /usr/ccrma/web/html/courses/220a-fall-2010/java/javaosc/lib/javaoscfull.jar

// then hit button in GUI: Set Address
// and hit: All On

adc => DelayL d => dac;
Gain fb => d => fb;

class slider {              // access java slider example by receiving OSC events
  fun float javaRange( float f) { return ((f - 20.0) / 10000.0); } // its range
  javaRange( 440.0) => float topVal;  // top-most horizontal slider initial val
  OscRecv recv;             // chuck object for OSC
  57110 => recv.port;       // listen on localhost port 57110 
  recv.listen();            // start listening (launch thread)
  // java example transmits to OSC address /n_set, formatted "i s f"
  // create an address in the receiver, store in new variable
  recv.event( "/n_set, i s f" ) @=> OscEvent @ oe;
  
  fun void loop() {         // infinite event loop
    while( true )
    {
      oe => now;            // wait for event to arrive
      while( oe.nextMsg() ) // grab the next message from the queue. 
      { 
            // getInt fetches the expected int (as indicated by "i")
        oe.getInt() => int i; 
            // getString fetches the expected int (as indicated by "s")
        oe.getString() => string s;
            // getFloat fetches the expected int (as indicated by "f")
        oe.getFloat() => float f;
            // <<< "got (from javaosc):", i, s, f >>>;
        if (i == 1000) {    // this is the top slider ID in java example
                            // <<< "(top):", f >>>; 
          javaRange(f) => topVal; // scale to 0.0 - 1.0 range
          }
                            // not using the mid or bottom sliders so just print
        else if (i == 1001) <<< "(mid):", f >>>;
        else if (i == 1002) <<< "(bot):", f >>>;
      }
    }
  }
  spork ~ loop();                       // start the infinite event loop listening
  public float last() { return topVal; }   // method to get current slider value
}

slider sl;                  // instantiate a slider instance

// try different values of delay and gain
0.8=> fb.gain;

while (true)
{
  sl.last() => float delay; // get current slider, 0.0 t0 1.0 range
  delay * 1000::samp => d.delay;
  0.001::second => now;
}
