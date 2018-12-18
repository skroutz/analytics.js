class ValidationError extends Error
  constructor: (message, reason) ->
    @message = message
    @reason = reason
    @name = "ValidationError"

define ->
  ValidationHelper =
    ensure_valid_object: (data, action=null, error_message=null) ->
      if typeof data == "string"
        try
          data = JSON.parse data
        catch
          # pass
      if typeof data == "object"
        return data

      error_message ||= 'Invalid JSON object'+(if action then " in \"#{action}\" action:\n" else ':\n')+data
      throw new ValidationError error_message, {failed_test: 'ensure_valid_object', action}

    ensure_key: (data, key, action=null, error_message=null) ->
      if not data[key]
        error_message ||= "Missing \"#{key}\""+(if action then " in \"#{action}\" action" else '')
        throw new ValidationError error_message, {failed_test: 'ensure_key', key, action}
      data

    ensure_not_empty_string: (data, key, action=null, error_message=null) ->
      if /^\s*$/.test(data[key])
        error_message ||= "Empty \"#{key}\""+(if action then " in \"#{action}\" action" else '')
        throw new ValidationError error_message, {failed_test: 'ensure_not_empty_string', key, action}
      data

  ValidationHelper
