// copy/paste into terminal: 
// java -jar ~/220a/java/javaosc/lib/javaoscfull.jar

// then hit button in GUI: Set Address
// and hit: All On

SinOsc s => dac;
s.gain(0.05);

slider sl;                  // instantiate a slider instance, defined below

class slider {              // access java slider example by receiving OSC events
  1 => int numSliders;
  float val[numSliders];
  Env env[numSliders];
  for (0 => int i; i<numSliders; i++) 440.0 => val[i];
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
        oe.getInt() - 1000 => int i; 
        oe.getString() => string s;
        oe.getFloat() => float f;
        env[i].setTarget(f);
      }
    }
  }
  spork ~ loop();                       // start the infinite event loop listening
  fun float last(int i) { return env[i].last(); }   // method to get current slider value
}

class Env
{ // does asymptotic enveloping
  0.001 => float exp; // depends on incoming "smoothness" -- update rate and resolution
  0.0 => float target;
  0.0 => float current;
  fun void loop () // towards target
  {     
    while( true )
    {
      target - current => float dif;
      (dif * exp) +=> current; 
      1::samp => now;
    }
  }
  fun void setTarget (float v) 
  { 
    target => current; // slam to last target
    v => target;
  }
  fun float last () { return current; }
  spork ~ loop();                       // start the infinite event loop listening
}

while (true)
{
  sl.last(0) * 5.0 => float freq;
  s.freq( freq );
  1::samp => now;
}
