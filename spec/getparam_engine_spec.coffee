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

  beforeEach ->
    @resolve_spy = sinon.spy()
    @reject_spy = sinon.spy()

  afterEach ->
    @resolve_spy.reset()
    @reject_spy.reset()
    @extract_stub.reset()

  describe '.contructor', ->
    beforeEach ->
      @instance = new @engine()
      return

    it 'returns its own instance', ->
      expect(@instance).to.be.an.instanceof @engine

    it 'creates a promise', ->
      expect(@instance.promise).to.be.an.instanceof @promise

    it 'tries to extract analytics_session from the url\'s params', ->
      expect(@extract_stub).to.be.calledWith @settings.params.analytics_session

  describe '#then', ->
    beforeEach ->
      @instance = new @engine()
      return

    it 'returns the @promise', ->
      ret = @instance.then (-> undefined), (-> undefined)
      expect(ret).to.equal @instance.promise

  describe 'Param extraction', ->
    context 'when url contains the analytics_session param', ->
      beforeEach ->
        @extract_stub.returns @analytics_session
        @instance = new @engine()
        @instance.then @resolve_spy, @reject_spy
        return

      it 'resolves the promise', ->
        expect(@resolve_spy).to.be.calledOnce

      it 'resolves the promise with the param\'s value', ->
        expect(@resolve_spy).to.be.calledWith @analytics_session


    context 'when url does not contain the analytics_session param', ->
      beforeEach ->
        @extract_stub.returns null
        @instance = new @engine()
        @instance.then @resolve_spy, @reject_spy
        return

      it 'rejects the promise', ->
        expect(@reject_spy).to.be.calledOnce

      it 'rejects the promise with error message', ->
        expect(@reject_spy).to.be.calledWith 'Analytics_session does not exist'
