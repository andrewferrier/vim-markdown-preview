#!/usr/bin/env node

'use strict'

const md = require('markdown-it')({
  html: true,
  typographer: true
})

// See https://github.com/markdown-it/markdown-it/issues/117#issuecomment-109386469
md.renderer.rules.table_open = function (tokens, idx) {
  return '<table class="table">'
}

md.use(require('markdown-it-table-of-contents'), {
  includeLevel: [1, 2, 3]
})

md.use(require('markdown-it-anchor'))

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
  var output

  if (err) {
    console.error(err.stack || err.message || String(err))
    process.exit(1)
  }

  try {
    output = md.render(input)
  } catch (e) {
    console.error(e.stack || e.message || String(e))
    process.exit(1)
  }

  process.stdout.write(output)
})
