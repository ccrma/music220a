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
import Util from '../../lib/Util.js';

const SampleDataCollection = [
  {key: 'guitar', url: '../../sound/loop/guitar.wav'},
];
let bufferMap = null;

const context = new AudioContext();
const bufferSource = new AudioBufferSourceNode(context);
const stereoPanner = new StereoPannerNode(context);
const amp = new GainNode(context);
bufferSource.connect(stereoPanner).connect(amp).connect(context.destination);

stereoPanner.pan.value = 0.0; // center

// For panning modulation:
// const lfo = new OscillatorNode(context, {frequency: 1});
// lfo.connect(stereoPanner.pan);
// lfo.start();

const playBuffer = (audioBuffer) => {
  bufferSource.buffer = audioBuffer;
  bufferSource.loop = true;
  bufferSource.start();
};

const setup = async () => {
  bufferMap = await Util.createBufferMap(context, SampleDataCollection);
};

ER.defineButton('button-start', () => playBuffer(bufferMap['guitar']), 'once');
ER.start(setup);
