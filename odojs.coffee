# Apply the relay method as a plugin on an odojs component so the following are equivalent:
#
# # without plugin
# scene = relay el, component, stores
#
# # with plugin
# scene = component.relay el, stores
relay = require './relay'

module.exports = (component, spec) ->
  return if !spec.query?
  component.relay = (el, stores) ->
    relay el, component, stores