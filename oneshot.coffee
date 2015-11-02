split = require 'odoql-exe/split'
build = require 'odoql-exe/buildqueries'

module.exports = (exe, component, params, hub, cb) ->
  queries = component.query params
  queries = split exe, queries
  # only execute local queries
  # TODO some way to execute remote queries
  # but ignore queries that need to run in the browser
  # e.g. localstorage
  queries = queries.local
  run = build exe, queries
  run (err, state) ->
    return cb err if err?
    html = component.stringify state, params, hub
    cb null,
      hub: hub
      params: params
      queries: queries
      state: state
      html: html