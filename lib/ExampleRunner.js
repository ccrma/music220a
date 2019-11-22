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

/**
 * @description Various helper functions for code examples.
 */

const ButtonRegistry = [];

const PageLoadCallbacks = [];

const Internal = {};

Internal._setButton = (buttonEntry) => {
  const buttonElement = document.getElementById(buttonEntry.elementId);
  buttonElement.disabled = true;
  buttonElement.actionType = buttonEntry.actionType;
  buttonElement.addEventListener('click', () => {
    buttonEntry.callback();
    if (buttonElement.actionType === 'once') {
      buttonElement.disabled = true;
    }
  }, {once: buttonElement.actionType});
  buttonElement.disabled = false;
};

Internal._registerOnLoad = () => {
  window.addEventListener('load', async () => {
    for (const onLoadCallback of PageLoadCallbacks) {
      await onLoadCallback();
    }
    ButtonRegistry.forEach((buttonEntry) => {
      Internal._setButton(buttonEntry);
    });
  }, {once: true});
};

Internal._injectViewSource = () => {

};

const ExampleRunner = {

  /**
   * Adds a button definition to the registry. It does not access the target
   * div element directly, so it is safe to call this function before |onload|
   * event.
   * 
   * @param {string} targetButtonId
   * @param {function} callback
   * @param {string} actionType
   */
  defineButton: (targetButtonId, callback, actionType) => {
    ButtonRegistry.push({
      elementId: targetButtonId,
      callback: callback,
      actionType: actionType,
    });
  },

  /**
   * Starts the example application after the page is loaded completely.
   *
   * @param {function} onPageLoadCallback window.onload callback function.
   *   Can be an async function.
   */
  start: (onPageLoadCallback) => {
    if (typeof onPageLoadCallback === 'function') {
      PageLoadCallbacks.push(onPageLoadCallback);
    }
    Internal._registerOnLoad();
  },

};

export default ExampleRunner;
