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
const biquad = new BiquadFilterNode(context);
const amp = new GainNode(context);
const lfo = new OscillatorNode(context);
const depth = new GainNode(context);

osc.connect(biquad).connect(amp).connect(context.destination);
lfo.connect(depth).connect(biquad.frequency);

osc.frequency.value = 100;
osc.type = 'sawtooth';
biquad.frequency.value = 1000;

lfo.frequency.value = 8;
lfo.type = 'sine';
depth.gain.value = 100;
biquad.Q.value = 10;

const startFilterModulation = () => {
  const now = context.currentTime;
  const later = now + 6;
  osc.start(now);
  osc.stop(later);
  lfo.start(now);
  lfo.stop(later);

  lfo.frequency.setValueAtTime(2, now);
  lfo.frequency.exponentialRampToValueAtTime(20, later);
  depth.gain.setValueAtTime(50, now);
  depth.gain.linearRampToValueAtTime(3500, later);
  biquad.frequency.setValueAtTime(200, now);
  biquad.frequency.exponentialRampToValueAtTime(10000, later);
};

ER.defineButton('button-start', startFilterModulation, 'once');
ER.start();
