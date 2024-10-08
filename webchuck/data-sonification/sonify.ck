//---------------------------------------------------------------------
// name: sonify.ck
// desc: CO2 sonification
//---------------------------------------------------------------------

// data file, don't forget to upload it first
"co2_mm_mlo_2024.csv" => string filename;

// file input output object
FileIO fio;

// open the data file
fio.open( filename, FileIO.READ );

// ensure it's ok
if( !fio.good() )  {
  <<< "couldn't open file", filename >>>;
  me.exit();
} else <<< filename, "opened ok" >>>;

// read 1st line
fio.readLine() => string header;

// count how many rows of data remain
0 => int rows;
while (!fio.eof()) {
  fio.readLine();
  rows++;
}
<<< filename, "has", rows, "rows with columns of", header >>>;

// declare arrays to hold the data points
float date[rows];
float val[rows];

// re-open the data file now that we've counted the rows
fio.open( filename, FileIO.READ );
fio.readLine() => header; // skip over the header
for (0 => int i; i < rows; i++) { // parse each row
  fio.readLine() => string csvLine;
  StringTokenizer strtok; // tokenizer uses space separated values
  csvLine.replace( ",", " " ); // so replace commas
  strtok.set(csvLine); // hand the line to tokenizer
  string dateString, valString; // temporary storage
  strtok.next( dateString ); // next token is date
  strtok.next( valString ); // next is value
  // convert strings to float numbers and store in arrays
  Std.atof( dateString ) => date[i];
  Std.atof( valString ) => val[i];
}

SinOsc osc => dac; // play the data with a sine wave
for (0 => int i; i < rows; i++) { // loop through the data
  osc.freq(val[i]); // assign co2 ppm to frequency
  10::ms => now; // wait 10 ms
}

// when done playing, get the max value and print it
-9999.0 => float maxVal;
for (0 => int i; i < rows; i++) {
  if (val[i] > maxVal) val[i] => maxVal;
}
<<< "maxVal", maxVal >>>;

