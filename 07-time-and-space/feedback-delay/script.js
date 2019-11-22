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
const delay = new DelayNode(context);
const feedback = new GainNode(context);
const amp = new GainNode(context);
delay.connect(feedback).connect(delay);
delay.connect(amp).connect(context.destination);

delay.delayTime.value = 0.25;
feedback.gain.value = 0.5;

const playBuffer = (audioBuffer) => {
  const bufferSource = new AudioBufferSourceNode(context);
  bufferSource.connect(delay);
  bufferSource.buffer = audioBuffer;

  // Using offset and duration for partial playback
  bufferSource.start(context.currentTime, 0.569, 0.429);
};

const setup = async () => {
  bufferMap = await Util.createBufferMap(context, SampleDataCollection);
};

ER.defineButton('button-start', () => playBuffer(bufferMap['guitar']));
ER.start(setup);
