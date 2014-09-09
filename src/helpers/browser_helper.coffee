define ['settings', 'promise'], (Settings, Promise)->

  ###
    BrowserHelper Class

    A collection of helper methods to interact with DOM.
  ###
  class BrowserHelper

    ###
      Adds callbacks to check if cookies are enabled

      @see BrowserHelper._thirdPartyCookiesEnabled()

      @param [Object] base_obj The Settings.actions_queue
      @param [Promise] promise The promise to check if 3rd party cookies are
        enabled
    ###
    @_setUpCallbacks: (base_obj, promise)->
      base_obj.step1_complete = -> BrowserHelper._createScript(Settings.url.utils.third_party_step2())
      base_obj.step2_complete = (status)-> promise.resolve(status)

    ###
      Deletes helper callbacks

      @param [Object] base_obj The Settings.actions_queue
    ###
    @_cleanUpCallbacks: (base_obj)->
      delete base_obj.step1_complete
      delete base_obj.step2_complete

    ###
      Adds a new <script> element to the DOM

      @param [String] url The value of the src attribute
    ###
    @_createScript: (url)->
      element = document.createElement('script')
      element.src = url

      sibling = document.getElementsByTagName('script')[0]
      sibling.parentNode.insertBefore(element, sibling)

    ###
      Checks if 1st party cookies are enabled for the current browser

      @return [Boolean] True if 1st party cookies are enabled or else false
    ###
    @_firstPartyCookiesEnabled: ->
      document.cookie = "TemporaryTestCookie=yes;";
      cookies_enabled = document.cookie.indexOf("TemporaryTestCookie=") isnt -1
      document.cookie = "TemporaryTestCookie=; expires=Thu, 01 Jan 1970 00:00:00 GMT";
      return cookies_enabled

    ###
      Checks if 3rd party cookies are enabled for the current browser

      @return [Promise] The promise to check if 3rd party cookies are supported
    ###
    @_thirdPartyCookiesEnabled: ->
      promise = new Promise()

      BrowserHelper._setUpCallbacks Settings.actions_queue, promise
      BrowserHelper._createScript Settings.url.utils.third_party_step1()

      promise.then -> BrowserHelper._cleanUpCallbacks Settings.actions_queue

    ###
      Checks whether 1st and 3rd party cookies are enabled for the current
        browser or not.

      @return [Promise] The promise to check for 1st and 3rd party cookies
        support.
    ###
    @checkCookies: ->
      promise = new Promise()

      BrowserHelper._thirdPartyCookiesEnabled().then (third_enabled)->
        promise.resolve
          first: Utils._firstPartyCookiesEnabled()
          third: third_enabled

      promise

    ###
      Checks if <img> elements are enabled for the current browser

      @note: Browser compatibility:
        IE < v8 do not support inline images.
        IE >= v8 support inline images, so we listen to the onload event.
        Other browsers: Watching the .complete attr is sufficient.
        The .readyState check depends on the src attribute been set before the
        appending of the img element.

      @return [Promise] The promise to check if <img> elements are supported
    ###
    @checkImages: ->
      promise     = new Promise()
      img_enabled = false

      parent = document.getElementsByTagName('head')[0]
      src  = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'

      img = document.createElement('img')
      img.onload = img.onerror = -> img_enabled = true
      img.src = src

      parent.appendChild img

      setTimeout (->
        promise.resolve(img.complete or img_enabled)
        parent.removeChild img
      ), 0

      promise


  return BrowserHelper
