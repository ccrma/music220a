// Nrev, IR to file

dac => WvOut o => blackhole;
"/zap/test.wav" => o.wavFilename;

// make an impulse
Impulse I;
1.0 => I.gain;

6 => int NCOMB;         // number of combs
6 => int NAP;           // all-passes

0.6 => float apc;
0.7 => float lpc;
I => Gain direct => dac;
I => Gain reverb;
0.5 => direct.gain;     // direct amount
0.1 => reverb.gain;     // reverb amount
0.9999 => float R;      // radius, affects reverb time

float L[NCOMB];
1433.0 => L[0];
1601.0 => L[1];
1867.0 => L[2];
2053.0 => L[3];
2251.0 => L[4];
2399.0 => L[5];
float A[NAP];
347.0 => A[0];
113.0 => A[1];
37.0 => A[2];
59.0 => A[3];
53.0 => A[4];
43.0 => A[5];
Gain combOut;

fun void combs (int nComb) 
{
    DelayL d[nComb];
    Gain fb[nComb];	
    int i; 
    for (0=>i; i<nComb; i++) {
        reverb => d[i] => combOut;
        fb[i] => d[i] => fb[i];
        L[i]::samp => d[i].delay;
        Math.pow( R, L[i] ) => fb[i].gain;
    }
}
DelayL dap[NAP];
Gain apIn[NAP];
Gain ff[NAP];	
Gain fbap[NAP];
Gain apOut[NAP]; 
fun void allpasses (int nAP) 
{   
    int i; 
    for (0=>i; i<nAP; i++) {
apIn[i] => dap[i] => apOut[i];
apIn[i] => ff[i] => apOut[i];
fbap[i] => dap[i] => fbap[i];
        A[i]::samp => dap[i].delay;
        -apc => fbap[i].gain;
        apc => ff[i].gain;
    }
}

combs(NCOMB);
allpasses(NCOMB);
combOut => apIn[0];
apOut[0] => apIn[1];
apOut[1] => apIn[2];
apOut[2] => OnePole lpf => apIn[3];
apOut[3] => apIn[4];
apOut[3] => apIn[5];
apOut[4] => dac.left;
apOut[5] => dac.right;
lpc => lpf.a1;
1.0 - lpc => lpf.b0;

1::ms => now;
1.0 => I.next;    // set the current sample/impulse
3::second => now;
