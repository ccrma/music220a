import webson from "./lib/webson.js";
import d3 from "./lib/webson.d3.js";

// Should be replaced with a data file you found.
const dataFile = "./data/data_1.csv";

/**
 * A filter function for the data validation/selection. This function
 * will be applied row by row until the end of the array.
 * @param {Array} row A row from the 2D array, parsed from CSV.
 * @return {Array} A filtered row by the function logic.
 */
const dataFilter = (row) => {
  // The target data set has 3 columns. Skip the row otherwise.
  if (row.length !== 3) return null;

  // Arranges the given row into a preferred form.
  const filteredRow = {
    // The first column is a date in decimal.
    date: parseInt(row[0], 10),
    // The second column is the first target value.
    value1: parseFloat(row[1]),
    // The third column is the second target value.
    value2: parseFloat(row[2])
  };

  // Sanitizing; if the value is negative or not-a-number, remove them
  // from the filtered data.
  for (const column in filteredRow) {
    const value = filteredRow[column];
    if (value < 0 || isNaN(value)) return null;
  }

  return filteredRow;
};

/**
 * Sonifies a dataset (2D array) with a given BaseAudioContext.
 * @param {BaseAudioContext} context A BaseAudioContext instance.
 * @param {Array} data A 2D array.
 */
const sonifyData = (context, data) => {
  // Set up a synth; 2 oscillators for 2 data streams.
  const osc1 = new OscillatorNode(context, { type: "triangle" });
  const osc2 = new OscillatorNode(context, { type: "square" });
  const amp = new GainNode(context, { gain: 0.25 });
  osc1.connect(amp).connect(context.destination);
  osc2.connect(amp);

  // Parameter mapping through D3's helper functions. See the D3
  // documentation for more info: https://github.com/d3/d3-scale
  let duration = 10;
  let timeline = d3
    .scaleLinear()
    .domain(d3.extent(data, (datum) => datum.date))
    .range([0, duration]);
  let jointExtent = d3
    .extent(data, (datum) => datum.value1)
    .concat(d3.extent(data, (datum) => datum.value2));
  let freq = d3.scaleLinear().domain(d3.extent(jointExtent)).range([110, 1680]);

  // Play the synth with the mapped data.
  const now = context.currentTime;
  const later = now + duration;
  osc1.start(now);
  osc1.stop(later);
  osc2.start(now);
  osc2.stop(later);
  data.forEach((datum) => {
    osc1.frequency.exponentialRampToValueAtTime(
      freq(datum.value1),
      now + timeline(datum.date)
    );
    osc2.frequency.exponentialRampToValueAtTime(
      freq(datum.value2),
      now + timeline(datum.date)
    );
  });
};

// Displays a modal to be clicked, then call a function with an active
// AudioContext for the sonification. Also draw the visualization for fun.
webson.displayActivationModal(async (audioContext) => {
  const data = await d3.getCsvData(dataFile, dataFilter);
  d3.drawMultiLineGraph(data);
  sonifyData(audioContext, data);
});
