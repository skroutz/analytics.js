define ->
  class Promise
    @all: (promises) ->
      promise_all = new Promise()
      rejected = false

      done_count = promises.length
      if done_count is 0
        promise_all.resolve(true)
        return promise_all

      success = -> promise_all.resolve(true) if --done_count is 0
      fail = ->
        unless rejected
          promise_all.reject(false)
          rejected = true

      promise.then(success, fail) for promise in promises
      promise_all

    constructor: ->
      @state = 'pending'
      @_thens = []

    then: (on_resolve, on_reject) ->
      @_thens.push resolve: on_resolve, reject: on_reject
      @

    resolve: (val) ->
      @_complete 'resolve', val
      @

    reject: (val) ->
      @_complete 'reject', val
      @

    _already: -> throw new Error('Promise already completed.')

    _complete: (which, arg) ->
      resolver = (res, rej) =>
        res(arg)
        @

      rejecter = (res, rej) =>
        rej(arg)
        @
      if which is 'resolve'
        @state = 'fulfilled'
        @then = resolver
      else
        @state = 'rejected'
        @then = rejecter

      @resolve = @reject = @_already

      fulfilment[which]?(arg) for fulfilment in @_thens

      delete @_thens

  return Promise
