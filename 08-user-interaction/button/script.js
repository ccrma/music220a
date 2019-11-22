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
const osc1 = new OscillatorNode(context);
const osc2 = new OscillatorNode(context, {type: 'sawtooth'});
const amp1 = new GainNode(context, {gain: 0.0});
const amp2 = new GainNode(context, {gain: 0.0});
osc1.connect(amp1).connect(context.destination);
osc2.connect(amp2).connect(context.destination);
osc1.start();
osc2.start();

const Color = {
  Black: '#000000',
  White: '#FFFFFF',
  Highlight: '#448AFF',
};

const setup = () => {
  // To unblock the autoplay policy
  window.addEventListener('click', () => context.resume(), {once: true});

  // Momentary button
  const moment = document.querySelector('#button-momentary');
  moment.textContent = 'MOMENT';
  moment.addEventListener('mousedown', () => {
    moment.style.color = Color.White;
    moment.style.backgroundColor = Color.Highlight;
    amp1.gain.linearRampToValueAtTime(0.75, context.currentTime + 0.04);
  });
  moment.addEventListener('mouseup', () => {
    moment.style.color = Color.Black;
    moment.style.backgroundColor = Color.White;
    amp1.gain.setTargetAtTime(0, context.currentTime, 0.01);
  });

  // Toggle button
  const toggle = document.querySelector('#button-toggle');
  toggle.state = false;
  toggle.textContent = 'TOGGLE';
  toggle.addEventListener('mousedown', () => {
    toggle.state = !toggle.state;
    if (toggle.state) {
      toggle.style.color = Color.White;
      toggle.style.backgroundColor = Color.Highlight;
      amp2.gain.linearRampToValueAtTime(0.75, context.currentTime + 0.04);
    } else {
      toggle.style.color = Color.Black;
      toggle.style.backgroundColor = Color.White;
      amp2.gain.setTargetAtTime(0, context.currentTime, 0.01);
    }
  });
};

ER.start(setup);
