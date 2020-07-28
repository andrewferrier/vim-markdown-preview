#!/usr/bin/env node

/* eslint-env node */

"use strict";

// # https://github.com/jonschlinkert/markdown-toc

const marked = require("marked");
const fs = require("fs");

const renderer = new marked.Renderer();

const newTableRenderer = function table(header, body) {
  if (body) body = "<tbody>" + body + "</tbody>";
  return (
    '<table class="table">\n' +
    "<thead>\n" +
    header +
    "</thead>\n" +
    body +
    "</table>\n"
  );
};

renderer.table = newTableRenderer;

const readFile = (encoding, callback) => {
  // read from stdin
  const chunks = [];

  process.stdin.on("data", chunk => {
    chunks.push(chunk);
  });

  process.stdin.on("end", () => {
    return callback(null, Buffer.concat(chunks).toString(encoding));
  });
};

readFile("utf8", (err, input) => {
  let output;

  if (err) {
    const errMessage = err.stack || err.message || String(err);

    throw new Error(errMessage);
  }

  try {
    const title = process.argv[2];
    const bootstrapFile = fs
      .readFileSync(
        __dirname + "/node_modules/bootstrap/dist/css/bootstrap.min.css"
      )
      .toString();
    const cssFile = fs
      .readFileSync(__dirname + "/markdown-preview.css")
      .toString();
    const html = marked(input, { renderer: renderer });

    const output =
      '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"/>' +
      '<meta http-equiv="X-UA-Compatible" content="IE=edge"/>' +
      '<style type="text/css">' +
      bootstrapFile +
      "</style>" +
      '<style type="text/css">' +
      cssFile +
      "</style>" +
      "<title>" +
      title +
      "</title>" +
      "</head><body>" +
      html +
      "</body></html>";

    process.stdout.write(output);
  } catch (err2) {
    const errMessage = err2.stack || err2.message || String(err2);

    throw new Error(errMessage);
  }
});
