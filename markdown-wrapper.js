#!/usr/bin/env node

/* eslint-env node */

"use strict";

const md = require("markdown-it")({
  "html": true,
  "typographer": true
});

// See https://github.com/markdown-it/markdown-it/issues/117#issuecomment-109386469
/* eslint camelcase: ["off"] */
md.renderer.rules.table_open = function table_open(tokens, idx) {
  return "<table class=\"table\">";
};

md.use(require("markdown-it-table-of-contents"), {
  /* eslint no-magic-numbers: ["error", { "ignore": [1, 2, 3] }] */
  "includeLevel": [2, 3]
});

md.use(require("markdown-it-anchor"));
md.use(require("markdown-it-checkbox"));

const readFile = (encoding, callback) => {
  // read from stdin
  const chunks = [];

  process.stdin.on("data", (chunk) => {
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
    output = md.render(input);
  } catch (err2) {
    const errMessage = err2.stack || err2.message || String(err2);

    throw new Error(errMessage);
  }

  process.stdout.write(output);
});
