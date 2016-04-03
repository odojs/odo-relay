# Relay is a pattern introduced by facebook
# https://facebook.github.io/react/blog/2015/02/20/introducing-relay-and-graphql.html
# https://facebook.github.io/react/blog/2015/03/19/building-the-facebook-news-feed-with-relay.html
# https://gist.github.com/staltz/868e7e9bc2a7b8c1f754

extend = require 'extend'
layers = require 'odo-layers'
cache = require 'odoql-exe/cache'

module.exports = (el, component, exe, options) ->
  # needs async checking
  _scene = null
  _memory = {}
  _state = layers()

  log = ->
  if options?.hub?
    log = (message) -> options.hub.emit '[odo-relay] {message}', message: message

  update = ->
    if !_scene?
      log 'mounting'
      return Relay.mount()
    log 'updating'
    _scene.update _state.get(), _memory, options?.hub

  _cache = cache exe, options
  _cache.on 'ready', update
  _cache.on 'result', _state.apply

  _cache.apply options.queries if options?.queries?
  _state.apply options.state if options?.state?

  Relay =
    mount: ->
      _scene = component.mount el, _state.get(), _memory, options?.hub, options
    update: (params) ->
      extend _memory, params
      _cache.run component.query _memory
    layer: _state.layer
    params: -> _memory
    clearParams: -> _memory = {}
    hub: -> options?.hub
    state: -> _state.get()
    unmount: ->
      _scene.unmount()
      _scene = null
    refreshQueries: (queries) ->
      queriesDictionary = {}
      for query in queries
        queriesDictionary[query] = null
      _cache.apply queriesDictionary
  Relay
