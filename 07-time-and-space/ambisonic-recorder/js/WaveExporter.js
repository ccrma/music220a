const writeStringToArray = (string, typedArray, offset) => {
  for (let i = 0; i < string.length; ++i)
    typedArray[offset + i] = string.charCodeAt(i);
}

const writeInt16ToArray = (number, typedArray, offset) => {
  // const dataView = new DataView(typedArray.buffer);
  // dataView.setInt16(offset, Math.floor(number));
  number = Math.floor(number);
  typedArray[offset + 0] = number & 255;          // byte 1
  typedArray[offset + 1] = (number >> 8) & 255;   // byte 2
}

// Not thoroughly tested.
const writeInt32ToArray = (number, typedArray, offset) => {
  // const dataView = new DataView(typedArray.buffer);
  // dataView.setInt32(offset, Math.floor(number));
  number = Math.floor(number);
  typedArray[offset + 0] = number & 255;          // byte 1
  typedArray[offset + 1] = (number >> 8) & 255;   // byte 2
  typedArray[offset + 2] = (number >> 16) & 255;  // byte 3
  typedArray[offset + 3] = (number >> 24) & 255;  // byte 4
}

// Return the bits of the float as a 32-bit integer value. This
// produces the raw bits; no intepretation of the value is done.
const floatBits = (floatNumber) => {
  const arrayBuffer = new ArrayBuffer(4);
  (new Float32Array(arrayBuffer))[0] = floatNumber;
  const bits = (new Uint32Array(arrayBuffer))[0];
  return bits | 0;
}

const writeChannelDataToUint8Array =
    (channelData, uint8array, offset, bitDepth) => {
  console.assert(channelData.length > 0);
  console.assert(offset === 44);
  
  const channelCount = channelData.length;
  const frameLength = channelData[0].length;
  let sample = null;

  console.log(`[WaveExporter] channelData(${channelData.length})`);
  console.log(`[WaveExporter] frameLength = ${channelData[0].length}`);

  // Planar to interleaved.
  for (let index = 0; index < frameLength; ++index) {
    for (let channel = 0; channel < channelCount; ++channel) {
      const singleChannelData = channelData[channel];
      switch (bitDepth) {
        case 16:
          sample = singleChannelData[index] * 32768.0;
          if (sample < -32768) sample = -32768;
          else if (sample > 32767) sample = 32767;
          writeInt16ToArray(sample, uint8array, offset);
          offset += 2;
          break;
        case 32:
          sample = floatBits(singleChannelData[index]);
          writeInt32ToArray(sample, uint8array, offset);
          offset += 4;
          break;
        default:
          console.error('NOTREACHED');
      }
    }
  }
};

const createWavBlobFromChannelData =
    (channelData, sampleRate, as32BitFloat) => {
  console.assert(channelData.length > 0);
  
  const frameLength = channelData[0].length;
  const numberOfChannels = channelData.length;
  const bitsPerSample = as32BitFloat ? 32 : 16;
  const bytesPerSample = bitsPerSample / 8;
  const byteRate = sampleRate * numberOfChannels * bitsPerSample / 8;
  const blockAlign = numberOfChannels * bitsPerSample / 8;
  const waveDataByteLength = frameLength * numberOfChannels * bytesPerSample;
  const headerByteLength = 44;
  const totalLength = headerByteLength + waveDataByteLength;
  const subChunk1Size = 16;
  const subChunk2Size = waveDataByteLength;
  const chunkSize = 4 + (8 + subChunk1Size) + (8 + subChunk2Size);
  const waveFileData = new Uint8Array(totalLength);

  // Reference: http://soundfile.sapp.org/doc/WaveFormat/

  // Chunk ID (4)
  writeStringToArray('RIFF', waveFileData, 0);
  // ChunkSize (4)
  writeInt32ToArray(chunkSize, waveFileData, 4);
  // Format (4)
  writeStringToArray('WAVE', waveFileData, 8);
  // Subchuck1Id (4)
  writeStringToArray('fmt ', waveFileData, 12);
  // SubChunk1Size (4)
  writeInt32ToArray(subChunk1Size, waveFileData, 16);
  // AudioFormat (2): 3 means 32-bit float, 1 means integer PCM
  writeInt16ToArray(as32BitFloat ? 3 : 1, waveFileData, 20);
  // NumChannels (2)
  writeInt16ToArray(numberOfChannels, waveFileData, 22);
   // SampleRate (4)
  writeInt32ToArray(sampleRate, waveFileData, 24);
  // ByteRate (4)
  writeInt32ToArray(byteRate, waveFileData, 28);
  // BlockAlign (2)
  writeInt16ToArray(blockAlign, waveFileData, 32);
  // BitsPerSample (4)
  writeInt32ToArray(bitsPerSample, waveFileData, 34);
  // Subchunk2ID (4)
  writeStringToArray('data', waveFileData, 36);
  // SubChunk2Size (4)
  writeInt32ToArray(subChunk2Size, waveFileData, 40);
  // Write actual audio data starting at offset 44.
  writeChannelDataToUint8Array(channelData, waveFileData, 44, bitsPerSample);

  console.log('[WaveExporter.createWAVlobFromChannelData] Unit8Array(' +
              waveFileData.length + '})');
  // console.log(waveFileData);

  return new Blob([waveFileData], {type: 'audio/wave'});
}

export default {
  createWavBlobFromChannelData
};
