/**
 * Copyright (C) 2021 Center for Computer Research in Music and Acoustics
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 **/

import webson from './lib/webson.js';
import d3 from './lib/webson.d3.js';

/**
 * Basic settings for your sonification
 **/ 
const DataFile = './data/bts.csv';
const FrequencyRange = [110, 1680];
const Duration = 5;

/**
 * A filter function for the data validation/selection. This function
 * will be applied row by row until the end of the array.
 * @param {Array} row A row from the 2D array, parsed from CSV.
 * @return {Array} A filtered row by the function logic.
 */
const dataFilter = (row) => {
  // The target data set has 2 columns. Skip the row otherwise.
  if (row.length !== 2) return null;

  // Arranges the given row into a preferred form.
  const filteredRow = {
    // The first column is a date in decimal.
    date: Date.parse(row[0]),
    // The second column is the actual value.
    value: parseFloat(row[1])
  };

  // Sanitizing; if the row contains a value that is negative or not a number, remove it
  // from the dataset.
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
  // A simple synth with a triangle oscillator.
  const osc = new OscillatorNode(context, { type: "triangle" });
  const amp = new GainNode(context, { gain: 0.25 });
  osc.connect(amp).connect(context.destination);

  // Parameter scaling/mapping through D3's helper functions. See the D3
  // documentation for more info: https://github.com/d3/d3-scale
  let timeline = d3
    .scaleLinear()
    .domain(d3.extent(data, (datum) => datum.date))
    .range([0, Duration]);
  let freq = d3
    .scaleLinear()
    .domain(d3.extent(data, (datum) => datum.value))
    .range(FrequencyRange);

  // Play the synth with the processed data.
  const now = context.currentTime;
  const later = now + Duration;
  osc.start(now);
  osc.stop(later);
  data.forEach((datum) => {
    osc.frequency.exponentialRampToValueAtTime(
      freq(datum.value),
      now + timeline(datum.date)
    );
  });
};

// Displays a modal to be clicked, then call a function with an active
// AudioContext for the sonification. Also draw the visualization for fun.
webson.displayActivationModal(async (audioContext) => {
  const data = await d3.getCsvData(DataFile, dataFilter);
  d3.drawLineGraph(data);
  sonifyData(audioContext, data);
});
