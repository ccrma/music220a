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
const osc = new OscillatorNode(context);
const amp = new GainNode(context);
osc.connect(amp).connect(context.destination);

const beep = () => {
  const now = context.currentTime;
  osc.start(now);
  osc.stop(now + 1);
};

ER.defineButton('button-start', beep, 'once');
ER.start();
