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
  {key: 'guitar', url: '../../sound/loop/guitar-160bpm.wav'},
  {key: 'plate', url: '../../sound/ir/plate.mp3'},
  {key: 'cabinet', url: '../../sound/ir/amp-cabinet.wav'},
];
let bufferMap = null;

const context = new AudioContext();
const waveshaper = new WaveShaperNode(context);
const send = new GainNode(context);
const delay = new DelayNode(context);
const feedback = new GainNode(context);
const plate = new ConvolverNode(context);
const cabinet = new ConvolverNode(context);
const amp = new GainNode(context);

waveshaper.connect(cabinet).connect(amp);
waveshaper.connect(send);
send.connect(delay).connect(feedback).connect(delay);
delay.connect(plate).connect(cabinet);
amp.connect(context.destination);

waveshaper.oversample = '4x';
send.gain.value = 0.5;
delay.delayTime.value = 0.07;
feedback.gain.value = 0.4;
amp.gain.value = Util.dbtolin(6);

const buildTransferFunction = () => {
  // The curve data has 2048 points be default.
  const curveData = new Float32Array(2048);
  const inc = 2.0 / curveData.length;

  // For overdrive effect
  for (let i = 0, x = -1; i < curveData.length; i++, x += inc) {
    curveData[i] = Math.tanh(4 * Math.PI * x);
  }

  waveshaper.curve = curveData;
};

const playBuffer = (buffer) => {
  const bufferSource = new AudioBufferSourceNode(context);
  bufferSource.buffer = buffer;
  bufferSource.loop = true;

  // Run by a WaveShaper,
  bufferSource.connect(waveshaper);
  // Or passthrough.
  // bufferSource.connect(context.destination);

  bufferSource.start();
};

const setup = async () => {
  bufferMap = await Util.createBufferMap(context, SampleDataCollection);
  plate.buffer = bufferMap['plate'];
  cabinet.buffer = bufferMap['cabinet'];
  buildTransferFunction();
};

ER.defineButton('button-start', () => playBuffer(bufferMap['guitar']), 'once');
ER.start(setup);
