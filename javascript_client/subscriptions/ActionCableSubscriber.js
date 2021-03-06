var printer = require("graphql8/language/printer")
var registry = require("./registry")

/**
 * Make a new subscriber for `addGraphQL8Subscriptions`
 * @param {ActionCable.Consumer} cable ActionCable client
*/
function ActionCableSubscriber(cable, networkInterface) {
  this._cable = cable
  this._networkInterface = networkInterface
}

/**
 * Send `request` over ActionCable (`registry._cable`),
 * calling `handler` with any incoming data.
 * Return the subscription so that the registry can unsubscribe it later.
 * @param {Object} registry
 * @param {Object} request
 * @param {Function} handler
 * @return {ID} An ID for unsubscribing
*/
ActionCableSubscriber.prototype.subscribe = function subscribeToActionCable(request, handler) {
  var networkInterface = this._networkInterface
  // unique-ish
  var channelId = Math.round(Date.now() + Math.random() * 100000).toString(16)

  var channel = this._cable.subscriptions.create({
    channel: "GraphqlChannel",
    channelId: channelId,
  }, {
    // After connecting, send the data over ActionCable
    connected: function() {
      var _this = this
      // applyMiddlewares code is inspired by networkInterface internals
      var opts = Object.assign({}, networkInterface._opts)
      networkInterface
        .applyMiddlewares({request: request, options: opts})
        .then(function() {
          var queryString = request.query ? printer.print(request.query) : null
          var operationName = request.operationName
          var operationId = request.operationId
          var variables = JSON.stringify(request.variables)
          var channelParams = Object.assign({}, request, {
            query: queryString,
            variables: variables,
            operationId: operationId,
            operationName: operationName,
          })
          // This goes to the #execute method of the channel
          _this.perform("execute", channelParams)
        })
    },
    // Payload from ActionCable should have at least two keys:
    // - more: true if this channel should stay open
    // - result: the GraphQL8 response for this result
    received: function(payload) {
      if (!payload.more) {
        registry.unsubscribe(this)
      }
      var result = payload.result
      if (result) {
        handler(result.errors, result.data)
      }
    },
  })
  var id = registry.add(channel)
  return id
}

/**
 * End the subscription.
 * @param {ID} id An ID from `.subscribe`
 * @return {void}
*/
ActionCableSubscriber.prototype.unsubscribe = function(id) {
  registry.unsubscribe(id)
}


module.exports = ActionCableSubscriber
