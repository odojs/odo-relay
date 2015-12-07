(function() {
  var cache, extend, layers;

  extend = require('extend');

  layers = require('odo-layers');

  cache = require('odoql-exe/cache');

  module.exports = function(el, component, exe, options) {
    var Relay, log, update, _cache, _memory, _scene, _state;
    _scene = null;
    _memory = {};
    _state = layers();
    log = function() {};
    if ((options != null ? options.hub : void 0) != null) {
      log = function(message) {
        return options.hub.emit('[odo-relay] {message}', {
          message: message
        });
      };
    }
    update = function() {
      if (_scene == null) {
        log('mounting');
        return Relay.mount();
      }
      log('updating');
      return _scene.update(_state.get(), _memory, options != null ? options.hub : void 0);
    };
    _cache = cache(exe, options);
    _cache.on('ready', update);
    _cache.on('result', _state.apply);
    if ((options != null ? options.queries : void 0) != null) {
      _cache.apply(options.queries);
    }
    if ((options != null ? options.state : void 0) != null) {
      _state.apply(options.state);
    }
    Relay = {
      mount: function() {
        return _scene = component.mount(el, _state.get(), _memory, options != null ? options.hub : void 0, options);
      },
      update: function(params) {
        extend(_memory, params);
        return _cache.run(component.query(_memory));
      },
      layer: _state.layer,
      params: function() {
        return _memory;
      },
      hub: function() {
        return options != null ? options.hub : void 0;
      },
      state: function() {
        return _state.get();
      },
      unmount: function() {
        _scene.unmount();
        return _scene = null;
      },
      refreshQueries: function(queries) {
        var queriesDictionary, query, _i, _len;
        queriesDictionary = {};
        for (_i = 0, _len = queries.length; _i < _len; _i++) {
          query = queries[_i];
          queriesDictionary[query] = null;
        }
        return _cache.apply(queriesDictionary);
      }
    };
    return Relay;
  };

}).call(this);
