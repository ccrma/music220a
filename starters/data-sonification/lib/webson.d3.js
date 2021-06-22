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

/* global d3 */

const ErrorMessages = {
  CSV_FETCH_PARSE_FAILURE:
    "[WebSon] getCsvData() failed due to fetch/parse failure."
};

// This code assumes the global instance of D3. This is not ideal, but
// it makes easier for students to submit homework by simplifying
// dependencies. (i.e. managing modules/pacakges)
const [
  area,
  line,
  axisBottom,
  axisLeft,
  csvParseRows,
  extent,
  scaleLinear,
  scalePow,
  scaleTime,
  select,
  time,
] = [
  d3.area,
  d3.line,
  d3.axisBottom,
  d3.axisLeft,
  d3.csvParseRows,
  d3.extent,
  d3.scaleLinear,
  d3.scalePow,
  d3.scaleTime,
  d3.select,
  d3.time,
];

/**
 * Fetch a CSV file and parse it to a JS array.
 * @param {string} url Target URL
 * @param {function} dataFilter a filter function
 * @return {Array}
 */
const getCsvData = async (url, dataFilter) => {
  try {
    const response = await fetch(url);
    const csvData = await response.text();
    const parsedArray = d3.csvParseRows(csvData, dataFilter);
    return parsedArray.length > 0 ? parsedArray : null;
  } catch (error) {
    throw Error(ErrorMessages.CSV_FETCH_PARSE_FAILURE + ` (${url})`);
  }
};

const drawAreaGraph = (data) => {
  let margin = { top: 50, right: 50, bottom: 50, left: 50 };
  let width = document.body.clientWidth - margin.left - margin.right;
  let height = 400 - margin.top - margin.bottom;
  let x = scaleTime()
    .domain(extent(data, (datum) => datum.date))
    .range([0, width]);
  let y = scaleLinear()
    .domain(extent(data, (datum) => datum.value))
    .range([height, 0]);
  let areaGraph = area()
    .x((data) => x(data.date))
    .y0(height)
    .y1((data) => y(data.value));
  let svg = select("body")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", `translate(${margin.left},${margin.top})`);
  svg
    .append("path")
    .datum(data)
    .attr("fill", "#cce5df")
    .attr("stroke", "#69b3a2")
    .attr("stroke-width", 1.5)
    .attr("d", areaGraph);
  svg
    .append("g")
    .attr("transform", `translate(0,${height})`)
    .call(axisBottom(x));
  svg.append("g").call(axisLeft(y));
};

const drawLineGraph = (data) => {
  let margin = { top: 50, right: 50, bottom: 50, left: 50 };
  let width = document.body.clientWidth - margin.left - margin.right;
  let height = 400 - margin.top - margin.bottom;
  let x = scaleTime()
    .domain(extent(data, (datum) => datum.date))
    .range([0, width]);
  let y = scaleLinear()
    .domain(extent(data, (datum) => datum.value))
    .range([height, 0]);
  let lineGraph = line()
    .x((data) => x(data.date))
    .y((data) => y(data.value));
  let svg = select("body")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", `translate(${margin.left},${margin.top})`);
  svg
    .append("path")
    .datum(data)
    .attr("fill", "none")
    .attr("stroke", "#69b3a2")
    .attr("stroke-width", 1.5)
    .attr("d", lineGraph);
  svg
    .append("g")
    .attr("transform", `translate(0,${height})`)
    .call(axisBottom(x));
  svg.append("g").call(axisLeft(y));
};

const drawMultiLineGraph = (data) => {
  let margin = { top: 50, right: 50, bottom: 50, left: 50 };
  let width = document.body.clientWidth - margin.left - margin.right;
  let height = 400 - margin.top - margin.bottom;
  let x = scaleLinear()
    .domain(extent(data, (datum) => datum.date))
    .range([0, width]);
  let jointExtent = extent(data, (datum) => datum.value1).concat(
    extent(data, (datum) => datum.value2)
  );
  let y = scaleLinear().domain(extent(jointExtent)).range([height, 0]);
  let lineGraph1 = line()
    .x((data) => x(data.date))
    .y((data) => y(data.value1));
  let lineGraph2 = line()
    .x((data) => x(data.date))
    .y((data) => y(data.value2));
  let svg = select("body")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", `translate(${margin.left},${margin.top})`);
  svg
    .append("path")
    .datum(data)
    .attr("fill", "none")
    .attr("stroke", "#69b3a2")
    .attr("stroke-width", 1.5)
    .attr("d", lineGraph1);
  svg
    .append("path")
    .datum(data)
    .attr("fill", "none")
    .attr("stroke", "#ef9a9a")
    .attr("stroke-width", 1.5)
    .attr("d", lineGraph2);
  svg
    .append("g")
    .attr("transform", `translate(0,${height})`)
    .call(axisBottom(x));
  svg.append("g").call(axisLeft(y));
};

export default {
  area,
  axisBottom,
  axisLeft,
  csvParseRows,
  extent,
  line,
  scaleLinear,
  scalePow,
  scaleTime,
  select,
  time,

  getCsvData,
  drawAreaGraph,
  drawLineGraph,
  drawMultiLineGraph
};
