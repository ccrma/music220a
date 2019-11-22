/**
 * Copyright (C) 2019 Center for Computer Research in Music and Acoustics
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

import ER from '../../lib/ExampleRunner.js';

const fundamental = 220;
const numberOfHarmonics = 50;
const frequencies = [];
const amplitudes = [];
const durationFactor = 0.02;

for (let i = 1; i <= numberOfHarmonics; ++i) {
  frequencies[i-1] = fundamental * i;
  amplitudes[i-1] = 1.0 / i;
}

const context = new AudioContext();
const master = new GainNode(context, {gain: 1.0 / numberOfHarmonics});
master.connect(context.destination);
const osc = [];
const amp = [];

for (let i = 0; i < numberOfHarmonics; ++i) {
  osc.push(new OscillatorNode(context, {frequency: frequencies[i]}));
  amp.push(new GainNode(context, {gain: 0.0}));
  osc[i].connect(amp[i]).connect(master);
}

const addUp = () => {
  const now = context.currentTime;
  const later = context.currentTime + numberOfHarmonics * durationFactor;
  for (let i = 0; i < numberOfHarmonics; ++i) {
    osc[i].start(now + i * durationFactor);
    osc[i].stop(later);
    amp[i].gain.value = amplitudes[i];
  }
};

ER.defineButton('button-start', addUp, 'once');
ER.start();
