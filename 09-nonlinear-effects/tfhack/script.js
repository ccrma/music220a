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
const waveshaper = new WaveShaperNode(context);
const amp = new GainNode(context);
osc.connect(waveshaper).connect(amp).connect(context.destination);

waveshaper.oversample = '4x';
amp.gain.value = 0.25; // Let's go easy on ears

const buildTransferFunction = () => {
  const data = new Float32Array(2048);
  const inc = 2.0 / data.length;
  for (let i = 0, x = -1; i < data.length; i++, x += inc) {
    // Passthrough
    data[i] = x;

    // Harmonics with Chebyshev Polynomial
    // data[i] = 2 * Math.pow(x, 2) - 1;
    // data[i] = 4 * Math.pow(x, 3) - 3 * x;
    // data[i] = 8 * Math.pow(x, 4) - 8 * Math.pow(x, 2) + 1;
    
    // Overdrive/saturation
    // data[i] = x + x * Math.sin(Math.PI * x) / 5;
    // data[i] = Math.tanh(4 * Math.PI * x);
    
    // Expansion
    // data[i] = Math.pow(x, 5);
    
    // Weird stuffs (be careful with the volume)
    // data[i] = Math.sign(Math.sin(Math.PI * x));
    // data[i] = 1 / x;
    // data[i] = Math.tan((Math.PI * x + Math.PI) / 2);
  }
    
  waveshaper.curve = data;
};

const setup = async () => {
  buildTransferFunction();
  ER.defineButton('button-start', () => osc.start(), 'once');
};

ER.start(setup);
