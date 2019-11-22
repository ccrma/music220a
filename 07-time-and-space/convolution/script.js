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
  {key: 'big-church', url: '../../sound/ir/big-church.mp3'},
  {key: 'reverse-gate', url: '../../sound/ir/reverse-gate.mp3'},
];
let bufferMap = null;

const context = new AudioContext();
const bufferSource = new AudioBufferSourceNode(context);
const reverb = new ConvolverNode(context);
const wet = new GainNode(context);
const dry = new GainNode(context);

bufferSource.connect(dry).connect(context.destination);
bufferSource.connect(reverb).connect(wet).connect(context.destination);

const playBuffer = (audioBuffer, irBuffer, mix) => {
  reverb.buffer = irBuffer;
  wet.gain.value = mix;
  dry.gain.value = 1 - mix;

  bufferSource.buffer = audioBuffer;
  bufferSource.loop = true;
  bufferSource.start();
};

const setup = async () => {
  bufferMap = await Util.createBufferMap(context, SampleDataCollection);
};

ER.defineButton(
    'button-start',
    () => playBuffer(bufferMap['guitar'], bufferMap['big-church'], 1.0),
    'once');
ER.start(setup);
