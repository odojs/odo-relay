// Generated by CoffeeScript 1.8.0
module.exports = function(max, idle) {
  var next, result, start, _batch, _queued, _running;
  _batch = {};
  _running = [];
  _queued = [];
  start = function(entry) {
    var cancel;
    entry.startedAt = new Date().getTime();
    cancel = entry.task(function(err, cb) {
      var fin, index, key, _i, _len, _ref;
      index = _running.indexOf(entry);
      _running.splice(index, 1);
      if (err == null) {
        fin = new Date().getTime();
        _ref = entry.keys;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          key = _ref[_i];
          _batch[key] = fin - entry.startedAt;
        }
        cb(entry.keys);
      }
      return next();
    });
    if (_running.indexOf(entry) === -1) {
      return;
    }
    if (typeof cancel !== 'function') {
      cancel = function() {};
    }
    entry.cancel = cancel;
    return next();
  };
  next = function() {
    if ((idle != null) && _running.length === 0 && _queued.length === 0) {
      idle(_batch);
      _batch = {};
      return;
    }
    if (_queued.length === 0) {
      return;
    }
    if (_running.length >= max) {
      return;
    }
    return start(_queued.shift());
  };
  return result = {
    cancel: function(keys) {
      _queued = _queued.filter(function(entry) {
        entry.keys = entry.keys.filter(function(key) {
          return keys.indexOf(key) === -1;
        });
        if (entry.keys.length !== 0) {
          return true;
        }
        return false;
      });
      return _running = _running.filter(function(entry) {
        entry.keys = entry.keys.filter(function(key) {
          return keys.indexOf(key) === -1;
        });
        if (entry.keys.length !== 0) {
          return true;
        }
        entry.cancel();
        return false;
      });
    },
    add: function(keys, task) {
      var entry;
      entry = {
        keys: keys,
        task: task
      };
      result.cancel(keys);
      return _queued.push(entry);
    },
    exec: function() {
      return next();
    }
  };
};
