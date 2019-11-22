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
const panner = new PannerNode(context);
const amp = new GainNode(context);
bufferSource.connect(panner).connect(amp).connect(context.destination);

panner.panningModel = 'HRTF';
panner.positionY.value = 0.01; // being at y = 0 can be tricky

// Creates a circular motion for HRTF panning
let x = 0;
let z = 0;
const moveInCircle = () => {
  const later = context.currentTime + 0.016; // 1 frame is ~16ms
  panner.positionX.linearRampToValueAtTime(Math.sin(x), later);
  panner.positionZ.linearRampToValueAtTime(Math.cos(z), later);
  x += 0.01; // speed of x-axis movement
  z += 0.01; // speed of z-axis movement
  requestAnimationFrame(moveInCircle);
};

const playBuffer = (audioBuffer) => {
  bufferSource.buffer = audioBuffer;
  bufferSource.loop = true;
  bufferSource.start();
  moveInCircle();
};

const setup = async () => {
  bufferMap = await Util.createBufferMap(context, SampleDataCollection);
};

ER.defineButton('button-start', () => playBuffer(bufferMap['guitar']), 'once');
ER.start(setup);
