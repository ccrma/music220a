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
let loopBuffer = null;

function playBuffer() {
  const source = new AudioBufferSourceNode(context);
  source.buffer = loopBuffer;
  source.connect(context.destination);
  const now = context.currentTime;
  source.start(now);
  source.stop(now + loopBuffer.duration);
}

const setup = async () => {
  const response = await fetch('../../sound/loop/loop-1.wav');
  const arrayBuffer = await response.arrayBuffer();
  loopBuffer = await context.decodeAudioData(arrayBuffer);

  // Useful when inspecting an object with lots of properties.
  console.table(loopBuffer);
};

ER.defineButton('button-start', playBuffer);
ER.start(setup);

