# Layered state
# Layers are created independently, and can be committed or rolled back

extend = require 'extend'

module.exports = (initialState) ->
  _state = {}
  _layers = []
  
  if initialState?
    extend yes, _state, initialState
  
  apply: (diff) ->
    extend yes, _state, diff
  
  clear: ->
    _state = {}
  
  get: ->
    result = {}
    extend result, _state
    for layer in _layers
      extend yes, result, layer
    result
  
  layer: (layer) ->
    _layers.push layer
    rollback: ->
      index _layers.indexOf layer
      _layers.splice index, 1
    commit: ->
      index _layers.indexOf layer
      _layers.splice index, 1
      extend _state, layer