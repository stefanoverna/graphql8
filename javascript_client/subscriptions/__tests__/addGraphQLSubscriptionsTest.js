addGraphQL8Subscriptions = require("../addGraphQL8Subscriptions")

describe("addGraphQL8Subscriptions", () => {
  it("delegates to the subscriber", () => {
    var state = {}
    var subscriber = {
      subscribe: function(req, handler) {
        state[req] = handler
        return req + "/" + handler
      },
      unsubscribe(id) {
        var key = id.split("/")[0]
        delete state[key]
      }
    }

    var dummyNetworkInterface = addGraphQL8Subscriptions({}, {subscriber: subscriber})

    var id = dummyNetworkInterface.subscribe("abc", "def")
    expect(id).toEqual("abc/def")
    expect(Object.keys(state).length).toEqual(1)
    expect(state["abc"]).toEqual("def")
    dummyNetworkInterface.unsubscribe(id)
    expect(Object.keys(state).length).toEqual(0)
  })
})
