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
  {key: 'cauldron', url: '../../sound/efx/cauldron.wav'},
  {key: 'ticking', url: '../../sound/efx/ticking.wav'},
];

const context = new AudioContext();
let bufferMap = null;

const playGrain = (buffer) => {
  const source = new AudioBufferSourceNode(context);
  const amp = new GainNode(context);
  source.connect(amp).connect(context.destination);
  source.buffer = buffer;
  
  const now = context.currentTime;
  const duration = buffer.duration * Util.random2f(0.01, 0.02);
  amp.gain.setValueAtTime(0.0, now);
  amp.gain.linearRampToValueAtTime(
      Util.random2f(0.25, 0.5), now + duration * 0.1);
  amp.gain.exponentialRampToValueAtTime(0.0001, now + duration);
  source.playbackRate.value = Util.random2f(0.01, 0.2);
  source.start(now + Util.random2f(0.1, 0.4),
               buffer.duration * Util.random2f(0.3, 0.71),
               duration);
};

const generateGrains = () => {
  // Genearates 4 gains per frame (~16.7ms)
  for (let i = 0; i < 4; ++i)
    playGrain(bufferMap[Math.random() > 0.5 ? 'cauldron' : 'ticking']);
  requestAnimationFrame(generateGrains);
};

const setup = async () => {
  bufferMap = await Util.createBufferMap(context, SampleDataCollection);
  ER.defineButton('button-start', generateGrains, 'once');
};

ER.start(setup);