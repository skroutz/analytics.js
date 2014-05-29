clear_all_cookies = ->
  document.cookie.split(/;\s/g).forEach (cookie)->
    document.cookie = "#{cookie.split('=')[0]}= ;expires=Wed, 28 May 2000 10:53:43 GMT"

describe 'Session', ->
  @timeout(0) # Disable the spec's timeout


  before (done) ->
    window.__requirejs__.clearRequireState()

    requirejs.undef 'easyxdm'

    @postMessage_spy = sinon.spy()
    @easyxdm_mock =
      Socket: =>
        return {
          postMessage: @postMessage_spy
        }
    @easyxdm_socket_spy = sinon.spy(@easyxdm_mock, 'Socket')

    define 'easyxdm', [], => @easyxdm_mock

    require [
      'session'
      'promise'
      'biskoto'
      'settings'
      'helpers/url_helper'
    ], (Session, Promise, Biskoto, Settings, URLHelper) =>
      @URLHelper = URLHelper
      @settings = Settings
      @biskoto  = Biskoto
      @promise  = Promise
      @session  = Session
      done()
    return

  after ->
    requirejs.undef 'easyxdm'
    window.__requirejs__.clearRequireState()

  afterEach ->
    @easyxdm_socket_spy.reset()
    @postMessage_spy.reset()

  describe '.contructor', ->
    it 'returns its own instance', ->
      @instance = new @session()
      expect(@instance).to.be.an.instanceof @session

    it 'registers @easyXDM', ->
      @instance = new @session()
      expect(@instance.easyXDM).to.not.equal(undefined)

    it 'creates a promise to notify when session is ready', ->
      @instance = new @session()
      expect(@instance.promise).to.be.an.instanceof @promise

  describe '#then', ->
    beforeEach ->
      @instance = new @session()
      @stub = sinon.stub @instance, '_extractAnalyticsSession'

    afterEach ->
      @stub.restore()

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

  describe 'Business logic', ->
    beforeEach ->
      clear_all_cookies()
      @yogurt_session    = 'dummy_yogurt_session_hash'
      @analytics_session = 'dummy_analytics_session_hash'

      @prev_cookies_enabled = @settings.cookies.first_party_enabled
      @prev_cookies_version = @settings.cookies.version

      @cookie_name = @settings.cookies.analytics.name
      @cookie_data =
        version: 1
        analytics_session: @analytics_session
      @cookie_options =
        expires: @settings.cookies.analytics.duration

      @setup_get_to_return = (ret)=>
        @extractGetParam_stub = sinon.stub(@URLHelper, 'extractGetParam').returns(ret)

      @setup_iframe_to_return = (ret)=>
        @extractFromIframe_stub = sinon.stub(@session.prototype, '_extractFromIframe').returns( new @promise().resolve(ret) )

    afterEach ->
      @extractFromIframe_stub?.restore()
      @extractGetParam_stub?.restore()

      @settings.cookies.version = @prev_cookies_version
      @settings.cookies.first_party_enabled = @prev_cookies_enabled

    context 'when we are inside yogurt (implied from "yogurt_session" cookie existance)', ->
      beforeEach ->
        @biskoto.set @settings.cookies.yogurt.name, @yogurt_session,
          expires: @settings.cookies.analytics.duration

      it 'gets "yogurt_session" from cookie', ->
        @instance = new @session()
        expect(@instance.yogurt_session).to.equal @yogurt_session

      it 'initializes XDomain socket', ->
        @instance = new @session()
        expect(@easyxdm_socket_spy).to.be.calledOnce

      it 'opens XDomain socket with "create" url', ->
        @instance = new @session()

        expect(@easyxdm_socket_spy.args[0][0]).to.contain
          remote: @settings.url.analytics_session.create(@yogurt_session)

      it 'extracts "analytics_session" from XDomain socket', (done)->
        test_analytics_session = 'another_analytics_session_hash'

        @instance = new @session()
        @.easyxdm_socket_spy.args[0][0].onMessage test_analytics_session, @settings.url.base

        @instance.then (analytics_session)->
          expect(analytics_session).to.equal(test_analytics_session)
          done()

      it 'fullfils @promise with analytics_session', (done)->
        test_analytics_session = 'another_analytics_session_hash'

        @instance = new @session()
        @.easyxdm_socket_spy.args[0][0].onMessage test_analytics_session, @settings.url.base

        @instance.promise.then (analytics_session)->
          expect(analytics_session).to.equal(test_analytics_session)
          done()

      describe 'first party cookie settings', ->
        context 'when first party cookies are enabled', ->
          beforeEach ->
            @settings.cookies.first_party_enabled = true

          it 'checks if first party cookie exists', ->
            @instance = new @session()
            expect(@instance.analytics_session).to.not.be.undefined

          context 'when first party cookie exists', ->
            beforeEach ->
              @biskoto.set @cookie_name, @cookie_data, @cookie_options

            it 'deletes cookie if cookie.version has changed', ->
              @settings.cookies.version = @prev_cookies_version + 1
              @instance = new @session()

              expect(@biskoto.get(@cookie_name)).to.be.null

            it 'replaces cookie data with results from XDomain socket', (done)->
              test_analytics_session = 'another_analytics_session_hash'

              @instance = new @session()
              @.easyxdm_socket_spy.args[0][0].onMessage test_analytics_session, @settings.url.base

              @instance.then =>
                expect(@biskoto.get(@cookie_name).analytics_session).to.equal test_analytics_session
                done()

          context 'when first party cookie does not exist', ->
            it 'creates first party cookie with "analytics_session"', (done)->
              test_analytics_session = 'another_analytics_session_hash'

              @instance = new @session()
              @.easyxdm_socket_spy.args[0][0].onMessage test_analytics_session, @settings.url.base

              @instance.then =>
                expect(@biskoto.get(@cookie_name).analytics_session).to.equal test_analytics_session
                done()

        context 'when first party cookies are disabled', ->
          beforeEach ->
            @settings.cookies.first_party_enabled = false

          it 'deletes cookie if one exists', ->
            @biskoto.set @cookie_name, @cookie_data, @cookie_options
            @instance = new @session()

            expect(@biskoto.get(@cookie_name)).to.be.null

          it 'does not set up a new cookie', ->
            prev_length = document.cookie.split(/;\s/g).length
            @instance = new @session()

            expect(document.cookie.split(/;\s/g).length).to.equal prev_length

    context 'when we are outside yogurt (implied from "yogurt_session" cookie absence)', ->
      it 'does not find "yogurt_session" in a cookie', ->
        @instance = new @session()
        expect(@instance.yogurt_session).to.equal null

      it 'initializes XDomain socket', ->
        @instance = new @session()
        expect(@easyxdm_socket_spy).to.be.calledOnce

      it 'opens XDomain socket with "connect" url', ->
        @instance = new @session()

        expect(@easyxdm_socket_spy.args[0][0]).to.contain
          remote: @settings.url.analytics_session.connect()

      describe 'retrieval process', ->
        context 'when neither XDomain socket nor GET param provide "analytics_session"', ->
          beforeEach ->
            @setup_get_to_return null
            @setup_iframe_to_return null
            @instance = new @session()

          it 'rejects the @promise', (done)->
            @instance.then ->
              expect(false).to.equal(true)
              done()
            , ->
              expect(true).to.equal(true)
              done()

          it 'does not create first party cookie with "analytics_session"', (done)->
            onEnd = =>
              expect(@biskoto.get(@cookie_name)).to.equal null
              done()

            @instance.then onEnd, onEnd

        context 'when only XDomain socket provides "analytics_session"', ->
          beforeEach ->
            @setup_iframe_to_return @analytics_session
            @setup_get_to_return null
            @instance = new @session()

          it 'fullfils @promise with "analytics_session" from XDomain socket', (done)->
            @instance.then (analytics_session)=>
              expect(analytics_session).to.equal(@analytics_session)
              done()
            , ->
              expect(false).to.equal(true)
              done()

        context 'when only GET param provides "analytics_session"', ->
          beforeEach ->
            @setup_iframe_to_return null
            @setup_get_to_return @analytics_session
            @instance = new @session()

          it 'fullfils @promise with "analytics_session" from GET param', (done)->
            @instance.then (analytics_session)=>
              expect(analytics_session).to.equal(@analytics_session)
              done()
            , ->
              expect(false).to.equal(true)
              done()

        context 'when both GET param and XDomain Socket provide "analytics_session"', ->
          beforeEach ->
            @setup_get_to_return @analytics_session + '1'
            @setup_iframe_to_return @analytics_session + '2'
            @instance = new @session()

          it 'fullfils @promise with XDomain socket value', (done)->
            @instance.then (analytics_session)=>
              expect(analytics_session).to.equal @analytics_session + '2'
              done()
            , ->
              expect(false).to.equal(true)
              done()

      describe 'first party cookie settings', ->
        context 'when first party cookies are enabled', ->
          beforeEach ->
            @settings.cookies.first_party_enabled = true

          it 'deletes cookie if cookie.version has changed', ->
            @settings.cookies.version = @prev_cookies_version + 1
            @instance = new @session()

            expect(@biskoto.get(@cookie_name)).to.be.null

          it 'checks if first party cookie exists', ->
            @instance = new @session()
            expect(@instance.analytics_session).to.not.be.undefined

          context 'when first party cookie exists', ->
            beforeEach ->
              @biskoto.set @cookie_name, @cookie_data, @cookie_options

            it 'does not initialize XDomain socket', ->
              @instance = new @session()
              expect(@easyxdm_socket_spy).to.not.be.called

            it 'extracts "analytics_session" from first party cookie', (done)->
              test_analytics_session = 'another_analytics_session_hash'
              cookie_data =
                version: 1
                analytics_session: test_analytics_session

              @biskoto.set @cookie_name, cookie_data, @cookie_options

              @instance = new @session()

              @instance.then (analytics_session)->
                expect(analytics_session).to.equal(test_analytics_session)
                done()

            it 'fullfils @promise with "analytics_session"', (done)->
              test_analytics_session = 'another_analytics_session_hash'
              cookie_data =
                version: 1
                analytics_session: test_analytics_session

              @biskoto.set @cookie_name, cookie_data, @cookie_options

              @instance = new @session()

              @instance.promise.then (analytics_session)->
                expect(analytics_session).to.equal(test_analytics_session)
                done()

          context 'when first party cookie does not exist', ->
            it 'creates first party cookie with "analytics_session"', (done)->
              test_analytics_session = 'another_analytics_session_hash'
              @setup_iframe_to_return test_analytics_session

              @instance = new @session()

              @instance.then =>
                expect(@biskoto.get(@cookie_name).analytics_session).to.equal test_analytics_session
                done()

        context 'when first party cookies are disabled', ->
          beforeEach ->
            @settings.cookies.first_party_enabled = false

          it 'deletes cookie if one exists', ->
            @biskoto.set @cookie_name, @cookie_data, @cookie_options
            @instance = new @session()

            expect(@biskoto.get(@cookie_name)).to.be.null

          it 'does not set up a new cookie', ->
            prev_length = document.cookie.split(/;\s/g).length
            @instance = new @session()

            expect(document.cookie.split(/;\s/g).length).to.equal prev_length
