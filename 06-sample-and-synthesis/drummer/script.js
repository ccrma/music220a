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
import Util from '../../lib/Util.js';

const SampleDataCollection = [
  {key: 90, url: '../../sound/drumkit/kick-1.wav'},
  {key: 88, url: '../../sound/drumkit/kick-2.wav'},
  {key: 67, url: '../../sound/drumkit/snare-1.wav'},
  {key: 86, url: '../../sound/drumkit/snare-2.wav'},
  {key: 66, url: '../../sound/drumkit/hihat-1.wav'},
  {key: 78, url: '../../sound/drumkit/hihat-2.wav'},
  {key: 77, url: '../../sound/drumkit/fillin.wav'},
];

const context = new AudioContext();
let bufferMap = null;

const handleKeyCode = (keyCode) => {
  if (!bufferMap || !(keyCode in bufferMap)) {
    console.log(
        `[handleKeyCode] No matching sample found. (keyCode: ${keyCode})`);
    return;
  }

  const now = context.currentTime;
  const buffer = bufferMap[keyCode];
  const source = new AudioBufferSourceNode(context);
  source.connect(context.destination);

  source.buffer = buffer;
  source.start(now);
  source.stop(now + buffer.duration);
};

const setup = async () => {
  bufferMap = await Util.createBufferMap(context, SampleDataCollection);
  document.addEventListener('keydown', (event) => {
    // But this triggers multiple notes until the key is up.
    // How can we fix that?
    handleKeyCode(event.keyCode);
  });
};

ER.start(setup);
