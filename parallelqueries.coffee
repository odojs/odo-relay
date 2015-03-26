# Spin up to max number of parallel, cancellable tasks referenced by key. New tasks cancel and replace older tasks with the same key.
module.exports = (max, idle) ->
  _batch = {}
  _running = []
  _queued = []
  start = (entry) ->
    entry.startedAt = new Date().getTime()
    cancel = entry.task (err, cb) ->
      index = _running.indexOf entry
      _running.splice index, 1
      if !err?
        fin = new Date().getTime()
        for key in entry.keys
          _batch[key] = fin - entry.startedAt
        cb entry.keys
      next()
    # was synchronous, exit early
    return if _running.indexOf(entry) is -1
    # is async, create cancel method
    if typeof cancel isnt 'function'
      cancel = ->
    entry.cancel = cancel
    next()
  next = ->
    if idle? and _running.length is 0 and _queued.length is 0
      idle _batch
      _batch = {}
      return
    return if _queued.length is 0
    return if _running.length >= max
    start _queued.shift()
  result =
    cancel: (keys) ->
      _queued = _queued.filter (entry) ->
        entry.keys = entry.keys.filter (key) ->
          keys.indexOf(key) is -1
        return yes if entry.keys.length isnt 0
        return no
      _running = _running.filter (entry) ->
        entry.keys = entry.keys.filter (key) ->
          keys.indexOf(key) is -1
        return yes if entry.keys.length isnt 0
        entry.cancel()
        return no
    add: (keys, task) ->
      entry =
        keys: keys
        task: task
      result.cancel keys
      _queued.push entry
    exec: -> next()