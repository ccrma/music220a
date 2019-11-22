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
osc.start();
amp.gain.value = 0.0;

const setup = () => {
  // The slider and its text label
  const slider = document.querySelector('#slider-frequency');
  const text = document.querySelector('#text-value');
  slider.disabled = true;
  slider.addEventListener('input', () => {
    text.textContent = slider.value + 'Hz';
    osc.frequency.exponentialRampToValueAtTime(
        slider.value, context.currentTime + 0.04);
  });
  osc.frequency.value = slider.value;
  text.textContent = slider.value + 'Hz';
  text.style.opacity = 0.25;

  // The toggle button
  const toggle = document.querySelector('#button-toggle');
  toggle.state = false;
  toggle.textContent = 'ON';
  toggle.addEventListener('click', () => {
    toggle.state = !toggle.state;
    if (toggle.state) {
      amp.gain.linearRampToValueAtTime(1.0, context.currentTime + 0.1);
      toggle.textContent = 'OFF';
      slider.disabled = false;
      text.style.opacity = 1.0;
    } else {
      amp.gain.linearRampToValueAtTime(0.0, context.currentTime + 0.1);
      toggle.textContent = 'ON';
      slider.disabled = true;
      text.style.opacity = 0.25;
    }
  });
};

ER.start(setup);
