// Apply the relay method as a plugin on an odojs component so the following are equivalent:

// # without plugin
// scene = relay el, component, stores

// # with plugin
// scene = component.relay el, stores
const relay = require('./relay')

module.exports = (component, spec) => {
  if (spec.query == null) return
  component.relay = (el, exe, options) =>
    relay(el, component, exe, options)
}
