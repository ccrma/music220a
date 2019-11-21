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

const Util = {

  createBufferMap: async (audioContext, sampleDataCollection) => {
    const bufferMap = {};
    for (const index in sampleDataCollection) {
      if (Object.prototype.hasOwnProperty.call(sampleDataCollection, index)) {
        const sampleData = sampleDataCollection[index];
        try {
          const response = await fetch(sampleData.url);
          const arrayBuffer = await response.arrayBuffer();
          const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
          bufferMap[sampleData.key] = audioBuffer;
        } catch (error) {
          throw new Error(`[Util.CreateBufferMap] ${error}`);
        }
      }
    }

    return bufferMap;
  },

  /**
   * Clamps a number into a range specified by min and max.
   * @param {Number} value Value to be clamped
   * @param {Number} min Range minimum
   * @param {Number} max Range maximum
   * @return {Number} Clamped value
   */
  clamp: (value, min, max) => {
    return Math.min(Math.max(value, min), max);
  },

  /**
   * Generates a floating point random number between min and max.
   * @param {Number} min Range minimum
   * @param {Number} max Range maximum
   * @return {Number} A floating point random number
   */
  random2f: (min, max) => {
    return min + Math.random() * (max - min);
  },

  /**
   * Generates an integer random number between min and max.
   * @param {Number} min Range minimum
   * @param {Number} max Range maximum
   * @return {Number} An integer random number
   */
  random2: (min, max) => {
    return Math.round(min + Math.random() * (max - min));
  },

  /**
   * Converts a MIDI pitch number to frequency.
   * @param {Number} midiPitch MIDI pitch (0 ~ 127)
   * @return {Number} Frequency (Hz)
   */
  mtof: (midiPitch) => {
    if (midiPitch <= -1500) {
      return 0;
    }
    if (midiPitch > 1499) {
      return 3.282417553401589e+38;
    }
    return 440.0 * Math.pow(2, (Math.floor(midiPitch) - 69) / 12.0);
  },

  /**
   * Converts frequency to MIDI pitch.
   * @param {Number} frequency Frequency
   * @return {Number} MIDI pitch
   */
  ftom: (frequency) => {
    return Math.floor(frequency > 0 ?
        Math.log(frequency/440.0) / Math.LN2 * 12 + 69 : -1500);
  },

  /**
   * Converts linear amplitude to decibel.
   * @param {Number} linearAmp Linear amplitude
   * @return {Number}  Decibel
   */
  lintodb: (linearAmp) => {
    // if below -100dB, set to -100dB to prevent taking log of zero
    return 20.0 * (linearAmp > 0.00001 ?
        (Math.log(linearAmp) / Math.LN10) : -5.0);
  },

  /**
   * Converts decibel to linear amplitude. Useful for dBFS conversion.
   * @param {Number} decibel  Decibel
   * @return {Number} Linear amplitude
   */
  dbtolin: (decibel) => {
    return Math.pow(10.0, decibel / 20.0);
  },

};

export default Util;
