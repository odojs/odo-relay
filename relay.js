// Generated by CoffeeScript 1.8.0
var async, extend, layers, parallelqueries, ql;

extend = require('extend');

parallelqueries = require('./parallelqueries');

ql = require('odoql/ql');

layers = require('./layers');

async = require('odo-async');

module.exports = function(el, component, stores) {
  var Relay, pq, update, _layers, _memory, _query, _scene, _state;
  _scene = null;
  _memory = {};
  _query = {};
  _state = layers();
  _layers = [];
  update = function() {
    if (_scene == null) {
      Relay.mount();
      return;
    }
    return _scene.update(_state.get(), _memory);
  };
  pq = parallelqueries(5, function(timings) {
    var key, _, _timings;
    if ((typeof window !== "undefined" && window !== null ? window.hub : void 0) != null) {
      _timings = {};
      for (key in timings) {
        _ = timings[key];
        _timings[key] = timings[key];
      }
      window.hub.emit('queries completed', _timings);
    }
    return update();
  });
  Relay = {
    mount: function() {
      return _scene = component.mount(el, _state.get(), _memory);
    },
    update: function(params) {
      var diff, newquery;
      extend(_memory, params);
      newquery = component.query(_memory);
      diff = ql.diff(_query, newquery);
      _query = newquery;
      if (Object.keys(diff).length === 0) {
        return update();
      }
      if ((typeof window !== "undefined" && window !== null ? window.hub : void 0) != null) {
        window.hub.emit('queries starting', {
          diff: diff,
          description: ql.desc(diff)
        });
      }
      return async.delay(function() {
        var q, _fn, _i, _len;
        diff = ql.build(diff, stores);
        _fn = function(q) {
          return pq.add(q.keys, function(cb) {
            return q.query(function(err, results) {
              if ((err != null) && ((typeof window !== "undefined" && window !== null ? window.hub : void 0) != null)) {
                window.hub.emit('query error {err}', {
                  err: err
                });
              }
              return cb(err, function(keys) {
                var key, updates, _j, _len1;
                updates = {};
                for (_j = 0, _len1 = keys.length; _j < _len1; _j++) {
                  key = keys[_j];
                  updates[key] = results[key];
                }
                return _state.apply(updates);
              });
            });
          });
        };
        for (_i = 0, _len = diff.length; _i < _len; _i++) {
          q = diff[_i];
          _fn(q);
        }
        return pq.exec();
      });
    },
    layer: _state.layer,
    params: function() {
      return _memory;
    },
    state: function() {
      return _state.get();
    },
    unmount: function() {
      _scene.unmount();
      return _scene = null;
    }
  };
  return Relay;
};
