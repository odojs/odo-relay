// Relay is a pattern introduced by facebook
// https://facebook.github.io/react/blog/2015/02/20/introducing-relay-and-graphql.html
// https://facebook.github.io/react/blog/2015/03/19/building-the-facebook-news-feed-with-relay.html
// https://gist.github.com/staltz/868e7e9bc2a7b8c1f754
const extend = require('extend')
const layers = require('odo-layers')
const cache = require('odoql-exe/cache')

module.exports = (el, component, exe, options) => {
  // needs async checking
  let _scene = null
  let _memory = {}
  const _state = layers()
  let log = () => {}
  if (options != null && options.hub != null)
    log = (message) => options.hub.emit('[odo-relay] {message}', { message: message })
  const update = () => {
    if (_scene == null) {
      log('mounting')
      return Relay.mount()
    }
    log('updating')
    _scene.update(_state.get(), _memory, options != null ? options.hub : void 0)
    return log('updated')
  }
  const _cache = cache(exe, options)
  _cache.on('ready', update)
  _cache.on('result', _state.apply)
  if ((options != null ? options.queries : void 0) != null) {
    _cache.apply(options.queries)
  }
  if ((options != null ? options.state : void 0) != null) {
    _state.apply(options.state)
  }
  const Relay = {
    mount: () => {
      _scene = component.mount(el, _state.get(), _memory, options != null ? options.hub : void 0, options)
    },
    update: params => {
      extend(_memory, params)
      _cache.run(component.query(_memory))
    },
    layer: _state.layer,
    params: () => _memory,
    clearParams: () => {
      _memory = {}
    },
    hub: () => options != null
      ? options.hub
      : null,
    state: () => _state.get(),
    unmount: () => {
      _scene.unmount()
      _scene = null
    },
    refreshQueries: queries => {
      const queriesDictionary = {}
      for (let query of queries)
        queriesDictionary[query] = null
      _cache.apply(queriesDictionary)
    }
  }
  return Relay
}

