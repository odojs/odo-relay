# Relay is a pattern introduced 

extend = require 'extend'
parallelqueries = require './parallelqueries'
ql = require 'odoql/ql'

module.exports = (el, component, stores) ->
  scene = null
  
  memory = {}
  query = {}
  state = {}
  
  update = ->
    if !scene?
      Relay.mount()
      return
    scene.update state, memory
  
  pq = parallelqueries 5, (timings) ->
    times = Object.keys query
      .map (prop) ->
        "  #{prop} in #{timings[prop]}ms"
      .join '\n'
    console.log "√ completed\n#{times}"
    update()
  
  # TODO: Eventually support optimistic updates - data changes that are temp applied on top of state while an ajax request is processing, eventually merging into state once the request has finished or removed from state if the request failed. Similar to a copy on write file system.
  Relay =
    mount: ->
      scene = component.mount el, state, memory
    
    update: (params) ->
      extend memory, params
      newquery = component.query memory
      diff = ql.diff query, newquery
      query = newquery
      # no query still need to update based off params
      return update() if Object.keys(diff).length is 0
      console.log ql.describe diff
      diff = ql.build diff, stores
      for q in diff
        do (q) ->
          pq.exec q.keys, (cb) ->
            q.query (err, results) ->
              if err?
                console.log "! #{err}"
              cb err, (keys) ->
                for key in keys
                  state[key] = results[key]
    
    params: -> memory
    
    unmount: ->
      scene.unmount()
      scene = null
  
  Relay