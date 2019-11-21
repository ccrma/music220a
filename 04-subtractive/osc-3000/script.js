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

import Osc3000 from './Osc3000.js';

const context = new AudioContext();

const o3k = new Osc3000(context);

function playBeeps() {
  const now = context.currentTime;
  o3k.playBeep(110, 0.1, now);
  o3k.playBeep(220, 0.2, now + 1);
  o3k.playBeep(330, 0.3, now + 2);
  o3k.playBeep(440, 0.4, now + 3);
  o3k.playBeep(550, 0.5, now + 4);
  o3k.playBeep(660, 0.6, now + 5);

  // This is fine... At least for now.
  setTimeout(() => o3k.stop(), 6000);
}

ER.defineButton('button-start', playBeeps, 'once');
ER.start();
