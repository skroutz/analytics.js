define ->
  UID = 1

  class Promise
    @all: (promises) ->
      promise_all = new Promise()
      rejected = false

      results = {}
      done_count = promises.length
      if done_count is 0
        promise_all.resolve(true)
        return promise_all

      create_ordered_array = (results)->
        arr = []
        for promise_id, data of results
          arr[data.order] = data.result
        return arr

      success = (result)->
        results[this._id].result = result
        if --done_count is 0
          promise_all.resolve(create_ordered_array(results))
      fail = ->
        unless rejected
          promise_all.reject(false)
          rejected = true

      i = 0
      for promise in promises
        results[promise._id] = {order: i++}

        binded_success = ((success, promise)->
          return -> success.apply promise, arguments
        )(success, promise)

        promise.then(binded_success, fail)

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
