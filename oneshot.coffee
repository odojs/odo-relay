split = require 'odoql-exe/split'
build = require 'odoql-exe/buildqueries'

module.exports = (exe, component, params, cb) ->
  queries = component.query params
  queries = split exe, queries
  queries = queries.local
  run = build exe, queries
  run (err, state) ->
    return cb err if err?
    html = component.stringify state, params
    cb null,
      params: params
      queries: queries
      state: state
      html: html