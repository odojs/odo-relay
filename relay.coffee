# Relay is a pattern introduced by facebook
# https://facebook.github.io/react/blog/2015/02/20/introducing-relay-and-graphql.html
# https://facebook.github.io/react/blog/2015/03/19/building-the-facebook-news-feed-with-relay.html
# https://gist.github.com/staltz/868e7e9bc2a7b8c1f754

extend = require 'extend'
parallelqueries = require './parallelqueries'
ql = require 'odoql/ql'
layers = require './layers'
async = require 'odo-async'

# Stores are an object of functions
# Each function takes a query and a callback and returns a cancel function
# The callback is normal error, result
#
# e.g.
# stores =
#   json: (query, cb) ->
#     handle = dosomething query, cb
#     -> handle.cancel()
module.exports = (el, component, stores) ->
  _scene = null
  
  _memory = {}
  _query = {}
  _state = layers()
  
  _layers = []
  
  update = ->
    if !_scene?
      Relay.mount()
      return
    _scene.update _state.get(), _memory
  
  pq = parallelqueries 5, (timings) ->
    if window?.hub?
      _timings = {}
      for key, _ of timings
        _timings[key] = timings[key]
      window.hub.emit 'queries completed', _timings
    update()
  
  # TODO: Eventually support optimistic updates - data changes that are temp applied on top of state while an ajax request is processing, eventually merging into state once the request has finished or removed from state if the request failed. Similar to a copy on write file system.
  Relay =
    mount: ->
      _scene = component.mount el, _state.get(), _memory
    
    update: (params) ->
      extend _memory, params
      newquery = component.query _memory
      diff = ql.diff _query, newquery
      _query = newquery
      # no query still need to update based off params
      return update() if Object.keys(diff).length is 0
      if window?.hub?
        window.hub.emit 'queries starting',
          diff: diff
          description: ql.desc diff
      
      async.delay ->
        diff = ql.build diff, stores
        for q in diff
          do (q) ->
            pq.add q.keys, (cb) ->
              q.query (err, results) ->
                if err? and window?.hub?
                  window.hub.emit 'query error {err}', err: err
                cb err, (keys) ->
                  updates = {}
                  for key in keys
                    updates[key] = results[key]
                  _state.apply updates
        pq.exec()
    
    layer: _state.layer
    
    params: -> _memory
    state: -> _state.get()
    
    unmount: ->
      _scene.unmount()
      _scene = null
  
  Relay