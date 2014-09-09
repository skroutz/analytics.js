define ->

  # A unique incremental number assigned to each promise
  UID = 1

  ###
    Promise Class

    A tiny yet effective cross-browser implementation of Promises/A+ spec.
  ###
  class Promise

    ###
      Resolves a given set of promises

      The main promise will be fulfilled if all of the given promises get
      fulfilled. If at least one of the given promises get rejected then the
      main promise will get rejected too.

      @example Resolve many promises
        new Promise().all([
          new Promise(),
          new Promise()
        ])

      @param [Array] promises The array of promises to resolve
      @return [Promise] The main promise
    ###
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

        bound_success = ((success, promise)->
          return -> success.apply promise, arguments
        )(success, promise)

        promise.then(bound_success, fail)

      promise_all

    ###
      Constructs a new Promise object
    ###
    constructor: ->
      @_id = UID++
      @state = 'pending'
      @_thens = []

    ###
      Appends fulfilment and rejection handlers to the promise

      @param [Function] on_resolve The fulfilment handler of the promise
      @param [Function] on_reject The rejection handler of the promise
      @return [Promise] This promise
    ###
    then: (on_resolve, on_reject) ->
      @_thens.push resolve: on_resolve, reject: on_reject
      @

    ###
      Fulfillment handler of a promise

      @param [Object] val Arguments to invoke fulfilment handler with
      @return [Promise] This promise
    ###
    resolve: (val) ->
      @_complete 'resolve', val
      @

    ###
      Rejection handler of a promise

      @param [Object] val Arguments to invoke rejection handler with
      @return [Promise] This promise
    ###
    reject: (val) ->
      @_complete 'reject', val
      @

    ###
      Do not allow a promise to change state. If a promise that is already
      completed (resolved or rejected) tries to change its value, it throws an
      Error.
    ###
    _already: -> throw new Error('Promise already completed.')

    ###
      Marks a promise as fulfilled or rejected and invokes the proper handler
      with any arguments

      @param [String] ('resolve'|'reject') which Whether to fulfill or reject
        the promise.
      @param [Object] arg Arguments to pass to invoked callback
    ###
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
