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

const saw = new OscillatorNode(context, {type: "sawtooth"});
const biquad = new BiquadFilterNode(context);
const amp = new GainNode(context);
saw.connect(biquad).connect(amp).connect(context.destination);

saw.frequency.value = 110;

function runSweep() {
  const now = context.currentTime;
  biquad.frequency.setValueAtTime(60, now);
  biquad.frequency.exponentialRampToValueAtTime(15000, now + 5);
  biquad.frequency.exponentialRampToValueAtTime(60, now + 10);
  biquad.Q.setValueAtTime(1, now);
  biquad.Q.linearRampToValueAtTime(12, now + 5);
  biquad.Q.linearRampToValueAtTime(1, now + 10);
  saw.start(now);
  saw.stop(now + 10);
}

ER.defineButton('button-start', runSweep, 'once');
ER.start();
