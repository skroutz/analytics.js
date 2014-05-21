unless Function::bind
  Function::bind = (oThis) ->
    # closest thing possible to the ECMAScript 5
    # internal IsCallable function
    if typeof this isnt "function"
      throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable")

    aArgs = Array::slice.call(arguments, 1)
    fToBind = this
    fNOP = ->
    fBound = ->
      fToBind.apply (if this instanceof fNOP and oThis then this else oThis), aArgs.concat(Array::slice.call(arguments))

    fNOP:: = @::
    fBound:: = new fNOP()
    fBound