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

const targets = [
  29.0, 87.5, 116.0, 175.0, 233.0, 
  350.0, 524.0, 880.0, 1048, 1760,
  29.0, 87.5, 116.0, 175.0, 233.0,
  350.0, 524.0, 880.0, 1048, 1760,
  29.0, 87.5, 116.0, 175.0, 233.0,
  350.0, 524.0, 880.0, 1048, 1760
];
 
const initials = [];
const saws = [];
const amps = [];
const pans = [];
 
function playDeepNote() {
  const context = new AudioContext();

  for (let i = 0; i < 30; i++) {
    initials[i] = Math.random() * 600 + 200;
    saws[i] = new OscillatorNode(context);
    amps[i] = new GainNode(context);
    pans[i] = new StereoPannerNode(context);
    saws[i].type = 'sawtooth';
    saws[i].frequency.setValueAtTime(initials[i], 0.0);
    pans[i].pan.setValueAtTime(Math.random() * 2 - 1, 0.0);
    amps[i].gain.setValueAtTime(0.125, 0.0);
    saws[i].connect(amps[i]);
    amps[i].connect(pans[i]);
    pans[i].connect(context.destination);

    saws[i].start();
    saws[i].frequency.exponentialRampToValueAtTime(targets[i], 3.0);
    pans[i].pan.linearRampToValueAtTime(Math.random() * 2 - 1, 3.0);
    amps[i].gain.setValueAtTime(0.125, 6.0);
    amps[i].gain.linearRampToValueAtTime(0.0, 7.5);
    saws[i].stop(context.currentTime + 8);
  }
}
 
ER.defineButton('button-start', playDeepNote, 'once');
ER.start();
