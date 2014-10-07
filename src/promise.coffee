define ->
  UID = 1

  class Promise
    @all: (promises) ->
      promise_all = new Promise()
      rejected = false

      results = []
      done_count = promises.length
      if done_count is 0
        promise_all.resolve(true)
        return promise_all

      success = (index, result)->
        results[index] = result
        if --done_count is 0
          promise_all.resolve(results)

      fail = ->
        unless rejected
          promise_all.reject(false)
          rejected = true

      for promise, index in promises
        bound_success = ((index)->
          return (args...)->
            args.unshift index
            success.apply null, args
        )(index)

        promise.then(bound_success, fail)

      promise_all

    constructor: ->
      @_id = UID++
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
        res and res(arg)
        @

      rejecter = (res, rej) =>
        rej and rej(arg)
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
