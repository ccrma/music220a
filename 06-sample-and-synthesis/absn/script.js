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

const context = new AudioContext();
let bufferMap = null;

const playBuffer = (buffer) => {
  const source = new AudioBufferSourceNode(context);
  source.connect(context.destination);

  source.buffer = buffer;
  source.loop = true;

  const now = context.currentTime;

  // Playing with |.loopStart| and |.loopEnd| properties
  // source.loopStart = buffer.duration * 0.01;
  // source.loopEnd = buffer.duration * 0.02;

  // Playing with |.playbackRate| AudioParam
  // source.playbackRate.setValueAtTime(1, now);
  // source.playbackRate.linearRampToValueAtTime(0.1, now + 2.5);
  // source.playbackRate.linearRampToValueAtTime(2, now + 5);
  // source.playbackRate.linearRampToValueAtTime(1, now + 7.5);

  source.start(now);
  source.stop(now + 10);
};

const setup = async () => {
  bufferMap = await Util.createBufferMap(context, [
    {key: 'loop-1', url: '../../sound/loop/loop-1.wav'},
    {key: 'loop-2', url: '../../sound/loop/loop-2.wav'},
  ]);
};

ER.defineButton('button-start', () => playBuffer(bufferMap['loop-1']));
ER.start(setup);
