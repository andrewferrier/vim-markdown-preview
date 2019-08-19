#!/usr/bin/env node

'use strict'

function readFile (encoding, callback) {
  // read from stdin
  var chunks = []

  process.stdin.on('data', function (chunk) {
    chunks.push(chunk)
  })

  process.stdin.on('end', function () {
    return callback(null, Buffer.concat(chunks).toString(encoding))
  })
}

readFile('utf8', function (err, input) {
  var output, md

  if (err) {
    console.error(err.stack || err.message || String(err))
    process.exit(1)
  }

  md = require('markdown-it')({
    html: true,
    typographer: true
  })

  try {
    output = md.render(input)
  } catch (e) {
    console.error(e.stack || e.message || String(e))
    process.exit(1)
  }

  process.stdout.write(output)
})
