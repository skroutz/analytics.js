define ->
  class Biskoto
    @get: (name) ->
      if document.cookie
        cookies = decodeURIComponent(document.cookie).split(/;\s/g)

        for cookie in cookies
          if cookie.indexOf(name) is 0
            return cookie.split('=')[1]

      return null

  return Biskoto
