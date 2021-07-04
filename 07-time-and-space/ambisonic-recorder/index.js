import StereoRecorderNode from './js/StereoRecorderNode.js';
import WaveExporter from './js/WaveExporter.js';
import ToggleButton from './js/ToggleButton.js';
import CanvasControl from './js/CanvasControl.js';
import Settings from './settings.js';

/* global ResonanceAudio */

let audioContext;
let stereoRecorder;
let canvasControl;
let scene;
let audioElements = [];
let soundSources = [];
let sourceIds = [
  'btn-play-source-1',
  'btn-play-source-2',
  'btn-play-source-3',
  'btn-play-source-4'
];
let dimensions = {
  small: {
    width: 1.5, height: 2.4, depth: 1.3,
  },
  medium: {
    width: 4, height: 3.2, depth: 3.9,
  },
  large: {
    width: 8, height: 3.4, depth: 9,
  },
  huge: {
    width: 20, height: 10, depth: 20,
  },
};
let materials = {
  brick: {
    left: 'brick-bare', right: 'brick-bare',
    up: 'brick-bare', down: 'wood-panel',
    front: 'brick-bare', back: 'brick-bare',
  },
  curtains: {
    left: 'curtain-heavy', right: 'curtain-heavy',
    up: 'wood-panel', down: 'wood-panel',
    front: 'curtain-heavy', back: 'curtain-heavy',
  },
  marble: {
    left: 'marble', right: 'marble',
    up: 'marble', down: 'marble',
    front: 'marble', back: 'marble',
  },
  outside: {
    left: 'transparent', right: 'transparent',
    up: 'transparent', down: 'grass',
    front: 'transparent', back: 'transparent',
  },
};
let sizeSelection = 'small';
let materialSelection = 'brick';
let audioReady = false;

/**
 * @private
 */
function selectRoomProperties() {
  if (!audioReady)
    return;

  sizeSelection = document.getElementById('room-size-options').value;
  materialSelection = document.getElementById('wall-material-options').value;
  scene.setRoomProperties(dimensions[sizeSelection],
    materials[materialSelection]);
  canvasControl.invokeCallback();
}

/**
 * @param {Object} elements
 * @private
 */
function updatePositions(elements) {
  if (!audioReady)
    return;

  for (let i = 0; i < elements.length; i++) {
    let x = (elements[i].x - 0.5) * dimensions[sizeSelection].width / 2;
    let y = 0;
    let z = (elements[i].y - 0.5) * dimensions[sizeSelection].depth / 2;
    if (i < elements.length - 1) {
      soundSources[i].setPosition(x, y, z);
    } else {
      scene.setListenerPosition(x, y, z);
    }
  }
}

/**
 * @private
 */
async function initAudio() {
  if (audioReady)
    return;

  audioContext = new AudioContext();
  await audioContext.audioWorklet.addModule('./js/StereoRecorderProcessor.js');
  stereoRecorder = new StereoRecorderNode(audioContext);

  let audioSources = Settings.sourceFilePath;
  let audioElementSources = [];
  for (let i = 0; i < audioSources.length; i++) {
    audioElements[i] = document.createElement('audio');
    audioElements[i].src = audioSources[i];
    audioElements[i].crossOrigin = 'anonymous';
    audioElements[i].load();
    audioElements[i].loop = true;
    audioElementSources[i] =
      audioContext.createMediaElementSource(audioElements[i]);
  }

  // Initialize scene and create Source(s).
  scene = new ResonanceAudio(audioContext, {ambisonicOrder: 1});
  for (let i = 0; i < audioSources.length; i++) {
    soundSources[i] = scene.createSource();
    audioElementSources[i].connect(soundSources[i].input);
  }
  scene.output.connect(stereoRecorder).connect(audioContext.destination);

  audioReady = true;
}

const createDownloadLink = () => {
  const use32Bit = false;
  const recordedBuffer = stereoRecorder.getRecordedBuffer();
  const blob = WaveExporter.createWavBlobFromChannelData(
      recordedBuffer, audioContext.sampleRate, use32Bit);
  const anchorElement = document.createElement('a');
  anchorElement.className = 'file-download-link';
  anchorElement.href = window.URL.createObjectURL(blob);
  anchorElement.textContent = 'Right click and Save Link as';
  anchorElement.download =
      'export-' + (use32Bit ? '32bit' : '16bit') + '-'
      + (new Date()).toJSON() + '.wav';
  document.getElementById('audio-download-link').appendChild(anchorElement);
};

const handleToggleOn = (buttonEl) => {
  buttonEl.textContent = 'Stop';
  stereoRecorder.start();
};

const handleToggleOff = (buttonEl) => {
  stereoRecorder.stop();
  audioContext.suspend();
  buttonEl.textContent = 'Stopped';
  buttonEl.disabled = true;
  createDownloadLink();
};

const loadAudioFiles = async (files) => {
  console.assert(files.length === 4);

  await initAudio();

  for (let i = 0; i < audioElements.length; i++) {
    const fileObjectUrl = URL.createObjectURL(files[i]);
    audioElements[i].src = fileObjectUrl;
    audioElements[i].crossOrigin = 'anonymous';
    audioElements[i].load();
    audioElements[i].loop = true;
  }
};

const handleFileInputChange = (event) => {
  let areFilesValid = true;
  let errorMessage = '';

  const container = document.getElementById('file-selector-container');
  const messageDiv = document.getElementById('file-selector-message');
  container.style.backgroundColor = '#eceff1';
  messageDiv.textContent = '';

  const files = event.target.files;

  if (files.length !== 4) {
    areFilesValid = false;
    errorMessage = '4 files are required.';
  }
  
  if (!areFilesValid) { 
    container.style.backgroundColor = '#ef9a9a';
    messageDiv.textContent = errorMessage;
  } else {
    loadAudioFiles(files);
    container.style.backgroundColor = '#a5d6a7';
  }
};

let onLoad = function() {
  document.getElementById('file-selector').addEventListener(
      'change', handleFileInputChange);

  document.getElementById('room-size-options').addEventListener(
    'change', function(event) {
      selectRoomProperties();
  });

  document.getElementById('wall-material-options').addEventListener(
    'change', function(event) {
      selectRoomProperties();
  });

  // Initialize play button functionality.
  for (let i = 0; i < sourceIds.length; i++) {
    let button = document.getElementById(sourceIds[i]);
    button.addEventListener('click', async (event) => {
      switch (event.target.textContent) {
        case `Play`:
          if (!audioReady) {
            await initAudio();
          }
          event.target.textContent = `Pause`;
          audioElements[i].play();
          break;
        case 'Pause':
          event.target.textContent = `Play`;
          audioElements[i].pause();
          break;
        default:
          console.error('NOTREACHED');
      }
    });
  }

  const toggleButton = new ToggleButton(
      document.getElementById('btn-toggle-record'),
      handleToggleOn,
      handleToggleOff
  );
  toggleButton.set('Record', false);

  let canvas = document.getElementById('canvas-sound-space');
  canvas.width = 480;
  canvas.height = 480;
  canvas.style.width = '480px';
  canvas.style.height = '480px';

  const position = Settings.initialPosition;
  let elements = [
    {
      icon: 'source-icon-1',
      x: position[0].x,
      y: position[0].y,
      radius: 0.04,
      alpha: 0.75,
      clickable: true,
    },
    {
      icon: 'source-icon-2',
      x: position[1].x,
      y: position[1].y,
      radius: 0.04,
      alpha: 0.75,
      clickable: true,
    },
    {
      icon: 'source-icon-3',
      x: position[2].x,
      y: position[2].y,
      radius: 0.04,
      alpha: 0.75,
      clickable: true,
    },
    {
      icon: 'source-icon-4',
      x: position[3].x,
      y: position[3].y,
      radius: 0.04,
      alpha: 0.75,
      clickable: true,
    },
    {
      icon: 'listener-icon',
      x: 0.5,
      y: 0.5,
      radius: 0.04,
      alpha: 0.75,
      clickable: true,
    },
  ];

  canvasControl = new CanvasControl(canvas, elements, updatePositions);
  selectRoomProperties();
};

window.addEventListener('load', onLoad);