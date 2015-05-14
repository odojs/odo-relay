// Generated by CoffeeScript 1.9.1
var build, split;

split = require('odoql-exe/split');

build = require('odoql-exe/buildqueries');

module.exports = function(exe, component, params, cb) {
  var queries, run;
  queries = component.query(params);
  queries = split(exe, queries);
  queries = queries.local;
  run = build(exe, queries);
  return run(function(err, state) {
    var html;
    if (err != null) {
      return cb(err);
    }
    html = component(state, params);
    return cb(null, {
      params: params,
      queries: queries,
      state: state,
      html: html
    });
  });
};
