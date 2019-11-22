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

const context = new AudioContext();
const osc = new OscillatorNode(context);
const amp = new GainNode(context);
const analyser = new AnalyserNode(context);
osc.connect(amp).connect(context.destination);
amp.connect(analyser);

osc.type = 'square';
osc.frequency.value = 100;
amp.gain.value = 0.75;

let canvas = null;
let context2D = null;
const waveformData = new Float32Array(2048);
const frequencyData = new Float32Array(2048);

const renderWaveform = () => {
  analyser.getFloatTimeDomainData(waveformData);
  const inc = canvas.width / waveformData.length;
  context2D.beginPath();
  context2D.moveTo(0, canvas.height * 0.5);
  for (let x = 0, i = 0; x < canvas.width; x += inc, ++i) {
    context2D.lineTo(x, (waveformData[i] * 0.5 + 0.5) * canvas.height);
  }
  context2D.stroke();
};

const renderSpectrum = () => {
  analyser.getFloatFrequencyData(frequencyData);
  const inc = canvas.width / (frequencyData.length * 0.5);
  context2D.beginPath();
  context2D.moveTo(0, canvas.height);
  // frequency data: 0.0dBFS ~ -200dbFS
  for (let x = 0, i = 0; x < canvas.width; x += inc, ++i) {
    context2D.lineTo(x, -frequencyData[i]);
  }
  context2D.stroke();
};

const render = () => {
  context2D.clearRect(0, 0, canvas.width, canvas.height);
  renderWaveform();
  renderSpectrum();
  requestAnimationFrame(render);
};

const start = () => {
  osc.start();
  render();
};

const setup = () => {
  canvas = document.querySelector('#visualization');
  context2D = canvas.getContext('2d');
};

ER.defineButton('button-start', start, 'once');
ER.start(setup);
