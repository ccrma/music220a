// copy/paste into terminal: 
// java -jar /usr/ccrma/web/html/courses/220a-fall-2009/java/javaosc/lib/javaoscfull.jar

// then hit button in GUI: Set Address
// and hit: All On

SinOsc mod => blackhole;
SinOsc car => dac;
car.gain(0.2);

slider sl;                  // instantiate a slider instance, defined below

while (true)
{
  sl.last(0) * 4000.0 => float freq;
  sl.last(1) * 10.0 => float index;
  sl.last(2) => float ratio;

  mod.gain( freq * index ); 
  mod.freq( freq * ratio );
  car.freq( freq + mod.last() );
  1::samp => now;
}

class slider {              // access java slider example by receiving OSC events
  fun float javaRange( float f) { return ((f - 20.0) / 10000.0); } // its range
  3 => int numSliders;
  float val[numSliders];
  for ( 0 => int i; i < numSliders; i++ ) javaRange( 440.0) => val[i];
  OscRecv recv;             // chuck object for OSC
  57110 => recv.port;       // listen on localhost port 57110 
  recv.listen();            // start listening (launch thread)
  // java example transmits to OSC address /n_set, formatted "i s f"
  // create an address in the receiver, store in new variable
  recv.event( "/n_set, i s f" ) @=> OscEvent @ oe;
  
  fun void loop() 
  {
    while( true )
    {
      oe => now;            // wait for event to arrive
      while( oe.nextMsg() ) // grab the next message from the queue. 
      { 
        // fully parse message, must be done in this order
        oe.getInt() => int i; 
        oe.getString() => string s;
        oe.getFloat() => float f;
        javaRange(f) => val[i-1000];
      }
    }
  }
  spork ~ loop();                       // start the infinite event loop listening
  fun float last(int i) { return val[i]; }   // method to get current slider value
}
