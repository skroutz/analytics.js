describe 'XDomain Session Retrieval Engine', ->
  before (done) ->
    @type_create       = 'create'
    @type_connect      = 'connect'

    window.__requirejs__.clearRequireState()
    requirejs.undef 'easyxdm'

    # EasyXDM mockup
    @postMessage_spy = sinon.spy()
    @easyxdm_mock =
      Socket: =>
        return {
          postMessage: @postMessage_spy
        }
    @easyxdm_socket_spy = sinon.spy(@easyxdm_mock, 'Socket')
    define 'easyxdm', [], => @easyxdm_mock

    @yogurt_session    = 'dummy_yogurt_session_hash'
    @yogurt_user_id    = '1234'
    @shop_code         = 'shop_code_1'
    @analytics_session = 'dummy_analytics_session_hash'

    require [
      'settings'
      'promise'
      'session_engines/xdomain_engine'
    ], (Settings, Promise, XDomainEngine) =>
      @settings = Settings
      @promise  = Promise
      @xdomain_engine  = XDomainEngine
      done()
    return

  after ->
    requirejs.undef 'easyxdm'
    window.__requirejs__.clearRequireState()

  beforeEach ->
    @clock = sinon.useFakeTimers()

  afterEach ->
    @clock.restore()
    @easyxdm_socket_spy.reset()
    @postMessage_spy.reset()

  describe '.contructor', ->
    beforeEach ->
      @instance = new @xdomain_engine(@type_create)
      return

    it 'returns its own instance', ->
      expect(@instance).to.be.an.instanceof @xdomain_engine

    it 'creates a promise to notify when session is ready', ->
      expect(@instance.promise).to.be.an.instanceof @promise

    it 'creates a socket', ->
      expect(@instance.socket).to.exist

    it 'registers a timeout', ->
      expect(@instance.timeout).to.not.be.undefined

  describe '#then', ->
    beforeEach ->
      @instance = new @xdomain_engine(@type_create)
      return

    it 'returns the @promise', ->
      ret = @instance.then(@success, @fail)
      expect(ret).to.equal @instance.promise

    it 'triggers success callback argument on @promise.resolve()', (done)->
      success = ->
        expect(true).to.equal(true)
        done()
      fail = ->
        expect(false).to.equal(true)
        done()

      @instance.then(success, fail)
      @instance.promise.resolve()

    it 'triggers fail callback argument on @promise.reject()', (done)->
      success = ->
        expect(false).to.equal(true)
        done()
      fail = ->
        expect(true).to.equal(true)
        done()

      @instance.then(success, fail)
      @instance.promise.reject()

  describe 'Socket creation', ->
    it 'creates new easyXDM instance', ->
      @instance = new @xdomain_engine(@type_create)
      expect(@easyxdm_socket_spy).to.be.calledWithNew

    context 'when called with type "create"', ->
      beforeEach ->
        @instance = new @xdomain_engine(@type_create, @shop_code,
          @yogurt_session, @yogurt_user_id)
        return

      it 'opens "track/create" url', ->
        expect(@easyxdm_socket_spy.args[0][0].remote).to.contain 'track/create'

      it 'passes yogurt_session as a param to the socket url', ->
        url = "yogurt_session=#{@yogurt_session}"
        expect(@easyxdm_socket_spy.args[0][0].remote).to.contain url

      it 'passes yogurt_user_id as a param to the socket url', ->
        url = "yogurt_user_id=#{@yogurt_user_id}"
        expect(@easyxdm_socket_spy.args[0][0].remote).to.contain url

      it 'passes shop_code as a param to the socket url', ->
        url = "shop_code=#{@shop_code}"
        expect(@easyxdm_socket_spy.args[0][0].remote).to.contain url

    context 'when called with type "connect"', ->
      beforeEach ->
        @instance = new @xdomain_engine(@type_connect, @shop_code)
        return

      it 'opens "track/connect" url', ->
        expect(@easyxdm_socket_spy.args[0][0].remote).to.contain 'track/connect'

      it 'passes shop_code as a param to the socket url', ->
        url = "shop_code=#{@shop_code}"
        expect(@easyxdm_socket_spy.args[0][0].remote).to.contain url

  describe 'Socket behaviour', ->
    beforeEach ->
      @instance = new @xdomain_engine(@type_create)
      @timeout_spy = sinon.spy(window, 'clearTimeout')
      @resolve_spy = sinon.spy(@instance.promise, 'resolve')
      @reject_spy = sinon.spy(@instance.promise, 'reject')

    afterEach ->
      window.clearTimeout.restore()
      @timeout_spy.restore()
      @resolve_spy.restore()
      @reject_spy.restore()

    context 'when backend responds with a value', ->
      beforeEach ->
        @instance._onSocketMessage(@analytics_session, @settings.url.base)

      it 'clears @timeout', ->
        expect(@timeout_spy).to.be.calledOnce

      it 'resolves @promise with the given value', ->
        expect(@resolve_spy).to.be.calledWith @analytics_session

    context 'when backend responds with \'\'', ->
      beforeEach ->
        @instance._onSocketMessage('', @settings.url.base)
        return

      it 'clears @timeout', ->
        expect(@timeout_spy).to.be.calledOnce

      it 'rejects @promise ', ->
        expect(@reject_spy).to.be.calledOnce

      it 'rejects @promise and passes error message', ->
        expect(@reject_spy).to.be.calledWith 'Analytics_session does not exist'

    context 'when backend does not respond', ->
      it 'does not clear the timeout', ->
        expect(@timeout_spy).to.not.be.called

      context 'after "Settings.xdomain_session_timeout" time', ->
        beforeEach ->
          @clock.tick @settings.xdomain_session_timeout + 100

        it 'rejects @promise', ->
          expect(@reject_spy).to.be.calledOnce

        it 'rejects @promise with timeout error message', ->
          expect(@reject_spy).to.be
            .calledWith 'XDomain retrieval of analytics_session timed out'
