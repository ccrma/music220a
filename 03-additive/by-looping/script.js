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
const master = new GainNode(context);
master.connect(context.destination);

const numberOfOscillators = 40;
const fundamental = 400;
const volume = 1.0;
master.gain.value = 1.0;

const playPartial = (n) => {
  const osc = new OscillatorNode(context, {frequency: fundamental * n});
  const amp = new GainNode(context, {gain: volume / n});
  osc.connect(amp).connect(master);
  osc.start();
  osc.stop(context.currentTime + 1.0);
};

const playSawtooth = () => {
  for (let i = 1; i <= numberOfOscillators; ++i) {
    playPartial(i);
  }
};

ER.defineButton('button-start', playSawtooth, 'once');
ER.start();
