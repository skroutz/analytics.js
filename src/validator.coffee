class ValidationError extends Error
  ###
  @param [String] message Error message
  @param [Object] reason Reporting friendly error cause
  ###
  constructor: (@message, @reason) ->
    @name = 'ValidationError'

    # Fill the stack field
    # More info: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error#Custom_Error_Types
    if Error.captureStackTrace # Maintains proper stack trace for where our error was thrown (only available on V8)
      Error.captureStackTrace(@, ValidationError)
    else
      @stack = (new Error).stack

define ->

  ###
  Validates a given Object or JSON string.
  ###
  class Validator
    ###
    Creates a Validator for the specified data.
    @param [Object, String] data Object or JSON string to be validated
    @param [String] action (optional) Name of the action that was being executed; context for debugging/reporting
    @throws ValidationError If data is neither an Object or a JSON string
    ###
    constructor: (@data, @action = '') ->
      (try @data = JSON.parse(@data)) if typeof @data == 'string'

      if typeof @data != 'object'
        throw new ValidationError(
          'Invalid JSON object' + (if @action then " in '#{@action}' action" else '') + ":\n" + @data,
          { error: 'invalid_object', @action }
        )

    ###
    Validates that the specified keys are present in data.
    A key is present if is not missing, null, undefined, or whitespace-only string.
    @param [String...] keys Strings with key names
    @throws ValidationError If any of the specified keys is not present
    ###
    present: (keys...) ->
      for key in keys
        if @data[key] == undefined or @data[key] == null or @data[key].trim?() == ''
          throw new ValidationError(
            "Missing or empty '#{key}'" + (if @action then " in '#{@action}' action" else ''),
            { error: 'not_present', key, @action }
          )

      @

  Validator
