define [
  'settings'
  'promise'
  'helpers/browser_helper'
  'helpers/url_helper'
], (Settings, Promise, BrowserHelper, URLHelper)->

  # A unique number to append to each reported payload
  unique_id = 0

  ###
    Reporter Class

    A class to manipulate the data to be reported back to Analytics server.
  ###
  class Reporter

    ###
      Constructs a new Reporter object

      @param [Object] options

      @todo Remove options param?
    ###
    constructor: (options)->
      @transport = 'img'
      @transport_ready = @_determineTransport()

    ###
      Provides access to the current or eventual value or reason

      @param [Function] success The callback to invoke after promise is fulfilled
      @param [Function] fail The callback to invoke after promise is rejected
    ###
    then: (success, fail) -> @transport_ready.then(success, fail)

    ###
      Reports the data

      It constructs an array of promises out of the data and tries to resolve
      them.

      @param [String] url The base url to report to
      @param [Array] data_array The array with the actions to report
      @return [Promise] The promise to report all data
    ###
    report: (url, data_array) ->
      promises = []

      for data in data_array
        promise = new Promise()

        ((url, data, promise)=>
          @transport_ready.then =>
            @_handleJob url, data, promise
        )(url, data, promise)

        promises.push promise

      Promise.all(promises)

    ###
      Determines whether to use <script> or <img> elements as a transport method
        to report data.
    ###
    _determineTransport: ->
      BrowserHelper.checkImages().then (images_enabled) =>
        @transport = 'script' unless images_enabled

    ###
      Handles a report job

      Serialize the payload, construct the proper endpoint and pass them to
      build the report transport element.

      @todo Use chunks for constructed URLs that exceed the maximum
        allowed characters by different web browsers.

        @see http://stackoverflow.com/a/417184 Maximum length of URLs

      @param [String] url The base url to report to
      @param [Object] payload The payload to report
      @param [Promise] promise The promises that is associated with the job
    ###
    _handleJob: (url, payload, promise)->
      data = URLHelper.serialize(payload)

      url = URLHelper.appendData(url, data)

      @_createTransport(url, promise)

    ###
      Creates the proper transport element to report data

      @param [String] url The url with the payload to report
      @param [Promise] promise The promise that is associated with the current
        job.
      @return [Promise] The promise that is associated with the current job
    ###
    _createTransport: (url, promise) ->
      transport_options =
        buster: "#{+new Date()}_#{unique_id++}"

      transport_options.no_images = '' if @transport is 'script'

      element = document.createElement(@transport)
      element.onload = -> promise.resolve()
      element.onerror = -> promise.reject()
      element.src = URLHelper.appendData url, URLHelper.serialize(transport_options)

      sibling = document.getElementsByTagName('script')[0]
      sibling.parentNode.insertBefore(element, sibling)

      promise

  return Reporter
