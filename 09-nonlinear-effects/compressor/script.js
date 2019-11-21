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

const context = new AudioContext();
const compressor = new DynamicsCompressorNode(context);
const makeup = new GainNode(context);
compressor.connect(makeup).connect(context.destination);

// Passthrough
// compressor.threshold.value = 0;
// compressor.ratio.value = 1;

// Heavy compression
compressor.threshold.value = -48; // in dB
compressor.ratio.value = 18;
makeup.gain.value = Util.dbtolin(6); // 6dB boost to a linear amplitude
  
const playBuffer = (buffer) => {
  const bufferSource = new AudioBufferSourceNode(context);
  bufferSource.loop = true;
  bufferSource.buffer = buffer;
  bufferSource.connect(compressor);
  bufferSource.start();
};

const setup = async () => {
  const bufferMap = await Util.createBufferMap(context, SampleDataCollection);
  ER.defineButton(
      'button-start', () => playBuffer(bufferMap['guitar']), 'once');
};

ER.start(setup);
