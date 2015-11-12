
class Today

  constructor: (@responder) ->

  record: (who, what) ->
    @responder.send who, what

module.exports = Today
