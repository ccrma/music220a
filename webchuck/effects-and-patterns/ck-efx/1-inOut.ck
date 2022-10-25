// hook a mic to speaker through chuck

adc.chan(0) => dac.chan(0); // connect left channels
while( true ) 1::samp => now;
