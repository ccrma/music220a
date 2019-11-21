// const fs = require('fs');
const path = require('path');
const recRead = require('recursive-readdir');
const prependFile = require('prepend-file');

const targetDirectories = [
  '01-orientation',
  '02-waa-basics',
  '03-additive',
  '04-subtractive',
  '05-modulation',
  '06-sample-and-synthesis',
  '07-time-and-space',
  '08-user-interaction',
  '09-nonlinear-effects',
];

const onComplete = (htmlFiles, jsFiles) => {
  console.log(`Completed! (HTML: ${htmlFiles.length} , JS: ${jsFiles.length})`);
};

const prependLicenseToFiles = (htmlFiles, jsFiles) => {
  for (let i = 0; i < htmlFiles.length; ++i) {
    prependFile.sync(htmlFiles[i], HTMLLicense);
  }
  for (i = 0; i < jsFiles.length; ++i) {
    prependFile.sync(jsFiles[i], JSLicense);
  }
  onComplete(htmlFiles, jsFiles);
};

const searchTargetDirectories = async () => {
  const htmlFiles = [];
  const jsFiles = [];
  for (const directory in targetDirectories) {
    if (Object.prototype.hasOwnProperty.call(targetDirectories, directory)) {
      const items = await recRead(targetDirectories[directory]);
      for (let i = 0; i < items.length; ++i) {
        switch (path.extname(items[i])) {
          case '.html':
            htmlFiles.push(items[i]);
            break;
          case '.js':
            jsFiles.push(items[i]);
            break;
        }
      }
    }
  }
  prependLicenseToFiles(htmlFiles, jsFiles);
};

searchTargetDirectories();


/**
 * LICENSE TEXT
 */

const HTMLLicense =
`<!--
 Copyright (C) 2019 Center for Computer Research in Music and Acoustics

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 -->

`;

const JSLicense =
`/**
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

`;
