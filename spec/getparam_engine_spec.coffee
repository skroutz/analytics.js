describe 'GetParam Session Retrieval Engine', ->
  before (done) ->
    @analytics_session = 'dummy_analytics_session_hash'

    window.__requirejs__.clearRequireState()
    requirejs.undef 'helpers/url_helper'

    @extract_stub = sinon.stub()
    @urlhelper_mock = { extractGetParam: @extract_stub }

    define 'helpers/url_helper', [], => @urlhelper_mock

    require [
      'settings'
      'promise'
      'session_engines/get_param_engine'
      'helpers/url_helper'
    ], (Settings, Promise, GetParamEngine, URLHelper) =>
      @urlhelper = URLHelper
      @settings = Settings
      @promise  = Promise
      @engine  = GetParamEngine
      done()
    return

  after ->
    requirejs.undef 'helpers/url_helper'
    window.__requirejs__.clearRequireState()

  afterEach ->
    @extract_stub.reset()

  describe '.contructor', ->
    beforeEach ->
      @instance = new @engine()
      return

    it 'returns its own instance', ->
      expect(@instance).to.be.an.instanceof @engine

    it 'creates a promise', ->
      expect(@instance.promise).to.be.an.instanceof @promise

    it 'always resolves the promise', ->
      expect(@instance.promise.state).to.equal 'fulfilled'

    it 'tries to extract analytics_session from the url\'s params', ->
      expect(@extract_stub).to.be.calledWith @settings.params.analytics_session

  describe '#then', ->
    beforeEach ->
      @instance = new @engine()
      return

    it 'returns the @promise', ->
      ret = @instance.then (->),(->)
      expect(ret).to.equal @instance.promise

    it 'triggers success callback by default', (done)->
      success = ->
        expect(true).to.equal(true)
        done()
      fail = ->
        expect(false).to.equal(true)
        done()

      @instance.then(success, fail)

  describe 'Param extraction', ->
    context 'when url contains the analytics_session param', ->
      it 'resolves the promise with the param\'s value', (done)->
        @extract_stub.returns @analytics_session
        new @engine().then (result)=>
          expect(result).to.equal @analytics_session
          done()

    context 'when url does not contain the analytics_session param', ->
      it 'resolves the promise with null', (done)->
        @extract_stub.returns null
        new @engine().then (result)=>
          expect(result).to.equal null
          done()

