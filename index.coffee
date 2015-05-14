# Relay is a pattern introduced by facebook
# https://facebook.github.io/react/blog/2015/02/20/introducing-relay-and-graphql.html
# https://facebook.github.io/react/blog/2015/03/19/building-the-facebook-news-feed-with-relay.html
# https://gist.github.com/staltz/868e7e9bc2a7b8c1f754

extend = require 'extend'
layers = require 'odo-layers'
cache = require 'odoql-exe/cache'

module.exports = (el, component, exe) ->
  _scene = null
  _memory = {}
  _state = layers()
  
  update = ->
    return Relay.mount() if !_scene?
    _scene.update _state.get(), _memory
  
  cache = cache exe
  cache.on 'ready', update
  cache.on 'result', _state.apply
  
  Relay =
    mount: ->
      _scene = component.mount el, _state.get(), _memory
    update: (params) ->
      extend _memory, params
      cache.run component.query _memory
    layer: _state.layer
    params: -> _memory
    state: -> _state.get()
    unmount: ->
      _scene.unmount()
      _scene = null
  Relay
