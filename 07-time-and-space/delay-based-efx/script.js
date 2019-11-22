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
const delay = new DelayNode(context);
const feedback = new GainNode(context);
const amp = new GainNode(context);
bufferSource.connect(delay).connect(feedback).connect(delay);
delay.connect(amp).connect(context.destination);

const lfo = new OscillatorNode(context);
const depth = new GainNode(context);
lfo.connect(depth).connect(delay.delayTime);
lfo.start();

// Flanging (range: 1~10ms)
delay.delayTime.value = 0.005;
feedback.gain.value = 0.85;
lfo.frequency.value = 0.1;
depth.gain.value = 0.004;

// Chrous (range: 5~30ms)
// delay.delayTime.value = 0.012;
// feedback.gain.value = 0.55;
// lfo.frequency.value = 0.2;
// depth.gain.value = 0.006;

// Doubling (range: 20~100ms)
// delay.delayTime.value = 0.060;
// feedback.gain.value = 0.45;
// lfo.frequency.value = 0.1;
// depth.gain.value = 0.010;

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
