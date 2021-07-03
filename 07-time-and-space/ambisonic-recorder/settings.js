/**
 * Copyright (C) 2021 Center for Computer Research in Music and Acoustics
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

// TODO: Add 4 monophinic audio files, that are your own creations
// and then edit the initial position as needed.

const sourceFilePath = [
  'resources/cube-sound.wav',
  'resources/speech-sample.wav',
  'resources/music.wav',
  'resources/bird.wav',
];

const initialPosition = [
  {x: 0.25, y: 0.25},
  {x: 0.75, y: 0.25},
  {x: 0.25, y: 0.75},
  {x: 0.75, y: 0.75},
];

export default {
  sourceFilePath: sourceFilePath,
  initialPosition: initialPosition,
};
