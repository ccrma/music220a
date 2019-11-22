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

const mod = new OscillatorNode(context);
const dev = new GainNode(context);
const car = new OscillatorNode(context);
const amp = new GainNode(context);

const modIndex = 1;
mod.frequency.value = 100;
dev.gain.value = mod.frequency.value * modIndex;
car.frequency.value = 100;
amp.gain.value = 0.5;

mod.connect(dev).connect(car.frequency);
car.connect(amp).connect(context.destination);

const startFMSynth = () => {
  const now = context.currentTime;
  const later = context.currentTime + 5;
  mod.start(now);
  car.start(now);
  mod.stop(later);
  car.stop(later);
  dev.gain.setValueAtTime(mod.frequency.value * 1, now);
  dev.gain.linearRampToValueAtTime(mod.frequency.value * 16, later);
};

ER.defineButton('button-start', startFMSynth, 'once');
ER.start();
