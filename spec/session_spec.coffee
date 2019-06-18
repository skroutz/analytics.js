clear_all_cookies = ->
  document.cookie.split(/;\s/g).forEach (cookie)->
    document.cookie = "#{cookie.split('=')[0]}= ;expires=Wed, 28 May 2000 10:53:43 GMT"

on_create_session_creation_tests = (cookie_exists = false) ->
  if cookie_exists
    it 'replaces the session first-party cookie data with retrieved data', (done) ->
      @init2()
      @instance.then =>
        expect(@biskoto.get(@session_cookie_name).session).to.equal @analytics_session
        done()
  else
    it 'creates the session first-party cookie with that value', (done) ->
      @init2()
      @instance.then =>
        expect(@biskoto.get(@session_cookie_name).session).to.equal @analytics_session
        done()

    it 'creates the session first-party cookie with proper version', (done) ->
      @init2()
      @instance.then =>
        expect(@biskoto.get(@session_cookie_name).version).to.equal @settings.cookies.version
        done()

  it 'it registers that value to @analytics_session', ->
    @init2()
    expect(@instance.analytics_session).to.equal @analytics_session

  it 'it resolves promise with the @analytics_session value', (done) ->
    @init2()
    @instance.then (session) =>
      expect(session.analytics_session).to.equal @analytics_session
      done()

on_create_session_retrieval_tests = (cookie_exists = false, session_from_cookie = null) ->
  it 'tries to extract analytics_session from Xdomain engine', ->
    @init()
    expect(@xdomain_spy).to.be.calledOnce

  it 'passes type to Xdomain engine', ->
    @init()
    expect(@xdomain_spy.args[0][0]).to.equal @type

  it 'passes shop_code to Xdomain engine', ->
    @init()
    expect(@xdomain_spy.args[0][1]).to.equal @shop_code

  it 'passes flavor to Xdomain engine', ->
    @init()
    expect(@xdomain_spy.args[0][2]).to.equal @flavor

  it 'passes analytics_session to Xdomain engine', ->
    @init()
    expect(@xdomain_spy.args[0][3]).to.equal session_from_cookie

  it 'passes metadata to Xdomain engine', ->
    @init()
    expect(@xdomain_spy.args[0][4]).to.equal encodeURIComponent(JSON.stringify(@metadata))

  context 'when the XDomain engine resolves', ->
    beforeEach ->
      @init2 = =>
        @init()
        @xdomain_promise.resolve(@analytics_session)
        return

    on_create_session_creation_tests(cookie_exists)

  context 'when the XDomain engine rejects', ->
    beforeEach ->
      @init()
      @xdomain_promise.reject()
      return

    it 'it rejects the @promise', (done)->
      resolve = ->
        assert.fail()
        done()
      reject = ->
        assert.ok(true)
        done()

      @instance.then(resolve, reject)

describe 'Session', ->
  before (done) ->
    @type_create       = 'create'
    @type_connect      = 'connect'
    @shop_code         = 'shop_code_1'
    @analytics_session = 'dummy_analytics_session_hash'
    @flavor            = 'flavor'
    @metadata          = { app_type: 'web', tags: 'tag1,tag2' }

    require [
      'promise'
    ], (Promise)=>
      @promise  = Promise

      requirejs.undef 'session_engines/xdomain_engine'
      @xdomain_promise = new @promise()
      @xdomain_mock = => return @xdomain_promise
      @xdomain_spy = sinon.spy @, 'xdomain_mock'
      define 'session_engines/xdomain_engine', [], => @xdomain_mock

      require [
        'session'
        'plugins_manager'
        'promise'
        'biskoto'
        'settings'
        'analytics_url'
        'domain_extractor'
      ], (Session, PluginsManager, Promise, Biskoto, Settings, AnalyticsUrl, DomainExtractor) =>
        @session = Session
        @PluginsManager = PluginsManager
        @promise  = Promise
        @biskoto  = Biskoto
        @settings = Settings
        @AnalyticsUrl = AnalyticsUrl
        @DomainExtractor = DomainExtractor
        done()

  after ->
    requirejs.undef 'session_engines/xdomain_engine'
    window.__requirejs__.clearRequireState()

  beforeEach ->
    @plugins_manager = new @PluginsManager()

  afterEach ->
    @xdomain_promise = new @promise()
    @xdomain_spy.reset()

  describe '.contructor', ->
    it 'returns its own instance', ->
      @instance = new @session(@plugins_manager)
      expect(@instance).to.be.an.instanceof @session

    it 'creates a promise to notify when session is ready', ->
      @instance = new @session(@plugins_manager)
      expect(@instance.promise).to.be.an.instanceof @promise

  describe '#run', ->
    it 'responds to #run', ->
      expect(new @session(@plugins_manager)).to.respondTo('run')

  describe '#then', ->
    beforeEach ->
      @instance = new @session(@plugins_manager)
      @resolve_spy = sinon.spy()
      @reject_spy = sinon.spy()

    afterEach ->
      @resolve_spy.reset()
      @reject_spy.reset()

    it 'returns the @promise', ->
      ret = @instance.then(@resolve_spy, @reject_spy)
      expect(ret).to.equal @instance.promise

    it 'triggers success callback argument on @promise.resolve()', ->
      @instance.then(@resolve_spy, @reject_spy)
      @instance.promise.resolve()

      expect(@resolve_spy).to.be.calledOnce

    it 'triggers fail callback argument on @promise.reject()', ->
      @instance.then(@resolve_spy, @reject_spy)
      @instance.promise.reject()

      expect(@reject_spy).to.be.calledOnce

  describe 'Business logic', ->
    beforeEach ->
      clear_all_cookies()

      @prev_cookies_version = @settings.cookies.version

      @sa_cookie_name = @settings.cookies.analytics.name
      @sa_cookie_data =
        version: 1
        analytics_session: @analytics_session
      @sa_cookie_options =
        expires: @settings.cookies.analytics.duration

      @session_cookie_name = @settings.cookies.session.name
      @session_cookie_data =
        version: 2
        session: 'another_dummy_session'
      @session_cookie_options =
        expires: @settings.cookies.session.duration

      @meta_cookie_name = @settings.cookies.meta.name
      @meta_cookie_data = { app_type: 'mobile', tags: 'tag3, tag4' }

    afterEach ->
      @settings.cookies.version = @prev_cookies_version

    context 'on session create', ->
      beforeEach ->
        @parsed_settings =
          shop_code: @shop_code
          flavor: @flavor
          metadata: @metadata
        @type = @type_create
        @init = =>
          sa('session', 'create', @shop_code, @flavor, @metadata)
          @instance = new @session(@plugins_manager).run()

      context 'when the session first-party cookie exists', ->
        beforeEach ->
          @biskoto.set @session_cookie_name, {version:1, session: 'asd'}, @session_cookie_options

        it 'initializes @analytics_session to the session first-party cookie\'s value', ->
          @init()
          expect(@instance.analytics_session).to.equal 'asd'

        context 'when cookie version has changed', ->
          beforeEach ->
            @settings.cookies.version = @prev_cookies_version + 1

          it 'deletes session first-party cookie', ->
            @init()
            expect(@biskoto.get(@session_cookie_name)).to.be.null

        on_create_session_retrieval_tests(true, 'asd')

      context 'when the session first-party cookie does not exist', ->
        it 'intializes @analytics_session to null', ->
          @init()
          expect(@instance.analytics_session).to.be.null

        on_create_session_retrieval_tests(false, null)

    context 'on session connect', ->
      beforeEach ->
        @parsed_settings =
          shop_code: @shop_code
        @type = @type_connect
        @init = =>
          sa('session', 'connect', @shop_code)
          @instance = new @session(@plugins_manager).run()
        @init_no_run = =>
          sa('session', 'connect', @shop_code)
          @instance = new @session(@plugins_manager)

      it 'assigns itself in plugins_manager', ->
        @init()

        expect(@plugins_manager.session).to.equal @instance

      it 'notifies the plugins manager', ->
        spy_notify = sinon.spy(@plugins_manager, 'notify')

        @init()

        expect(spy_notify).to.be.calledWithExactly('connect', {})

      it 'extracts the base level domain', ->
        prev_hostname = @settings.url.hostname
        @settings.url.hostname = 'sub.myshop.gr'

        @init()

        @settings.url.hostname = prev_hostname

        expect(@instance.domain).to.equal '.myshop.gr'

      context 'when connect is called multiple times', ->
        beforeEach ->
          @init = =>
            sa('session', 'connect', @shop_code)
            sa('session', 'connect', @shop_code)

            @instance = new @session(@plugins_manager)

        it 'notifies the plugins manager only once', ->
          spy_notify = sinon.spy(@plugins_manager, 'notify')

          @init().run()

          expect(spy_notify).to.have.been.calledOnce

      context 'when the skr_prm is present', ->
        context 'and the session is present', ->
          beforeEach ->
            @default_params = { session: @analytics_session }

            @stub_params = (params = @default_params) =>
              @read_params_stub = sinon.stub(@AnalyticsUrl.prototype, 'read_params').returns(params)

          afterEach -> @read_params_stub.restore()

          it 'it assigns the analytics session found in the skr_prm to @analytics_session', ->
            @stub_params()
            @init()

            expect(@instance.analytics_session).to.equal @analytics_session

          it 'resolves the @promise with the analytics session found in the skr_prm', (done) ->
            @stub_params()
            @init()
            @instance.then (session) =>
              expect(session.analytics_session).to.equal @analytics_session
              done()

          it 'does not use the XDomain engine to retrieve the analytics session', ->
            @stub_params()
            @init()

            expect(@xdomain_spy).to.not.be.called

          it 'does not retrieve the analytics session from the cached cookie', ->
            @stub_params()
            @init_no_run()
            spy_cached_cookie = sinon.spy(@instance, '_getSessionFromCacheCookie')

            @instance.run()

            expect(spy_cached_cookie).to.not.be.called

          it 'does not set the sa first-party cookie', ->
            @stub_params()
            @init()

            expect(@biskoto.get(@sa_cookie_name)).to.be.null

          it 'sets the session first-party cookie value', ->
            @stub_params()
            @init()

            expect(@biskoto.get(@session_cookie_name).session).to.equal @analytics_session

          it 'sets the session first-party cookie version', ->
            @stub_params()
            @init()

            expect(@biskoto.get(@session_cookie_name).version).to.equal @settings.cookies.version

          context 'and the session first-party cookie already exists', ->
            beforeEach ->
              @biskoto.set @session_cookie_name, @session_cookie_data, @session_cookie_options

            it 'updates the session first-party cookie value', ->
              @stub_params()
              @init()

              expect(@biskoto.get(@session_cookie_name).session).to.equal @analytics_session

            it 'updates the session first-party cookie version', ->
              @stub_params()
              @init()

              expect(@biskoto.get(@session_cookie_name).version).to.equal @settings.cookies.version

          context 'and the metadata are present', ->
            it 'it assigns the metadata found in the skr_prm to @metadata', ->
              @stub_params({ session: @analytics_session, metadata: @metadata })
              @init()

              expect(@instance.metadata).to.deep.equal @metadata

            it 'sets the metadata first-party cookie value', ->
              @stub_params({ session: @analytics_session, metadata: @metadata })
              @init()

              expect(@biskoto.get(@meta_cookie_name)).to.deep.equal @metadata

            context 'and the metadata first-party cookie already exists', ->
              beforeEach -> @biskoto.set @meta_cookie_name, @meta_cookie_data

              it 'updates the metadata first-party cookie value', ->
                @stub_params({ session: @analytics_session, metadata: @metadata })
                @init()

                expect(@biskoto.get(@meta_cookie_name)).to.deep.equal @metadata

          context 'and the metadata are not present', ->
            it 'it does not assign the @metadata', ->
              @stub_params({ session: @analytics_session })
              @init()

              expect(@instance.metadata).to.be.null

            it 'does not set the metadata first-party cookie value', ->
              @stub_params({ session: @analytics_session })
              @init()

              expect(@biskoto.get(@meta_cookie_name)).to.be.null

        context 'and the session is not present', ->
          beforeEach ->
            @default_params = { whateverparam: 'whatever'  }

            @stub_params = (params = @default_params) =>
              @read_params_stub = sinon.stub(@AnalyticsUrl.prototype, 'read_params').returns(params)

          afterEach -> @read_params_stub.restore()

          it 'does not set the session first-party cookie', ->
            @stub_params()
            @init()

            expect(@biskoto.get(@session_cookie_name)).to.be.null

          context 'and the metadata are not present', ->
            it 'it does not assign the @metadata', ->
              @stub_params()
              @init()

              expect(@instance.metadata).to.be.null

            it 'does not set the metadata first-party cookie value', ->
              @stub_params()
              @init()

              expect(@biskoto.get(@meta_cookie_name)).to.be.null

          context 'and the metadata are present', ->
            it 'it assigns the metadata found in the skr_prm to @metadata', ->
              @stub_params({ metadata: @metadata })
              @init()

              expect(@instance.metadata).to.equal @metadata

            it 'sets the metadata first-party cookie value', ->
              @stub_params({ metadata: @metadata })
              @init()

              expect(@biskoto.get(@meta_cookie_name)).to.deep.equal @metadata

          context 'and the sa first-party cookie exists', ->
            beforeEach ->
              @biskoto.set @sa_cookie_name, {version:1, analytics_session: 'cached_session'}, @sa_cookie_options

            it 'it assigns the analytics session found in the sa first-party cookie to @analytics_session', ->
              @stub_params()
              @init()

              expect(@instance.analytics_session).to.equal 'cached_session'

            it 'retrieves the analytics session from the sa first-party cookie', ->
              @stub_params()
              @init_no_run()
              spy_cached_cookie = sinon.spy(@instance, '_getSessionFromCacheCookie')

              @instance.run()

              expect(spy_cached_cookie).to.be.called.once

            it 'resolves the @promise with the analytics session found in the sa first-party cookie', (done) ->
              @stub_params()
              @init()
              @instance.then (session) =>
                expect(session.analytics_session).to.equal 'cached_session'
                done()

            it 'does not use the XDomain engine to retrieve the analytics session', ->
              @stub_params()
              @init()

              expect(@xdomain_spy).to.not.be.called

          context 'and the sa first-party cookie does not exist', ->
            it 'tries to extract analytics session from Xdomain engine', ->
              @stub_params()
              @init()

              expect(@xdomain_spy).to.be.calledOnce

            it 'passes type to Xdomain engine', ->
              @stub_params()
              @init()

              expect(@xdomain_spy.args[0][0]).to.equal @type

            it 'passes shop_code to Xdomain engine', ->
              @stub_params()
              @init()

              expect(@xdomain_spy.args[0][1]).to.equal @shop_code

            context 'and the XDomain engine rejects', ->
              beforeEach ->
                @stub_params()
                @init()
                @xdomain_promise.reject()
                return

              it 'it rejects the @promise', (done)->
                resolve = ->
                  assert.fail()
                  done()
                reject = ->
                  assert.ok(true)
                  done()

                @instance.then(resolve, reject)

            context 'and the XDomain engine resolves', ->
              beforeEach ->
                @init2 = =>
                  @stub_params()
                  @init()
                  @xdomain_promise.resolve(@analytics_session)
                  return

              it 'it registers that value to @analytics_session', ->
                @init2()
                expect(@instance.analytics_session).to.equal @analytics_session

              it 'it resolves promise with the @analytics_session value', (done) ->
                @init2()
                @instance.then (session) =>
                  expect(session.analytics_session).to.equal @analytics_session
                  done()

              it 'creates the sa first-party cookie with that value', (done) ->
                  @init2()
                  @instance.then =>
                    expect(@biskoto.get(@sa_cookie_name).analytics_session).to.equal @analytics_session
                    done()

              it 'creates the sa first-party cookie with proper version', (done) ->
                @init2()
                @instance.then =>
                    expect(@biskoto.get(@sa_cookie_name).version).to.equal @settings.cookies.version
                    done()

      context 'when the skr_prm is not present', ->
        beforeEach ->
          @stub_params = ->
            @read_params_stub = sinon.stub(@AnalyticsUrl.prototype, 'read_params').returns(null)

        afterEach -> @read_params_stub.restore()

        it 'does not set the session first-party cookie', ->
          @stub_params()
          @init()

          expect(@biskoto.get(@session_cookie_name)).to.be.null

        it 'does not set the metadata first-party cookie', ->
          @stub_params()
          @init()

          expect(@biskoto.get(@meta_cookie_name)).to.be.null

        context 'and the sa first-party cookie exists', ->
          beforeEach ->
            @biskoto.set @sa_cookie_name, {version:1, analytics_session: 'cached_session'}, @sa_cookie_options

          it 'it assigns the analytics session found in the sa first-party cookie to @analytics_session', ->
            @stub_params()
            @init()

            expect(@instance.analytics_session).to.equal 'cached_session'

          it 'retrieves the analytics session from the sa first-party cookie', ->
            @stub_params()
            @init_no_run()
            spy_cached_cookie = sinon.spy(@instance, '_getSessionFromCacheCookie')

            @instance.run()

            expect(spy_cached_cookie).to.be.called.once

          it 'resolves the @promise with the analytics session found in the sa first-party cookie', (done) ->
            @stub_params()
            @init()
            @instance.then (session) =>
              expect(session.analytics_session).to.equal 'cached_session'
              done()

          it 'does not use the XDomain engine to retrieve the analytics session', ->
            @stub_params()
            @init()

            expect(@xdomain_spy).to.not.be.called

        context 'and the sa first-party cookie does not exist', ->
          it 'tries to extract analytics session from Xdomain engine', ->
            @stub_params()
            @init()

            expect(@xdomain_spy).to.be.calledOnce

          it 'passes type to Xdomain engine', ->
            @stub_params()
            @init()

            expect(@xdomain_spy.args[0][0]).to.equal @type

          it 'passes shop_code to Xdomain engine', ->
            @stub_params()
            @init()

            expect(@xdomain_spy.args[0][1]).to.equal @shop_code

          context 'and the XDomain engine rejects', ->
            beforeEach ->
              @stub_params()
              @init()
              @xdomain_promise.reject()
              return

            it 'it rejects the @promise', (done) ->
              resolve = ->
                assert.fail()
                done()
              reject = ->
                assert.ok(true)
                done()

              @instance.then(resolve, reject)

          context 'and the XDomain engine resolves', ->
            beforeEach ->
              @init2 = =>
                @stub_params()
                @init()
                @xdomain_promise.resolve(@analytics_session)
                return

            it 'it registers that value to @analytics_session', ->
              @init2()
              expect(@instance.analytics_session).to.equal @analytics_session

            it 'it resolves promise with the @analytics_session value', (done) ->
              @init2()
              @instance.then (session) =>
                expect(session.analytics_session).to.equal @analytics_session
                done()

            it 'creates the sa first-party cookie with that value', (done)->
                @init2()
                @instance.then =>
                  expect(@biskoto.get(@sa_cookie_name).analytics_session).to.equal @analytics_session
                  done()

            it 'creates the sa first-party cookie with proper version', (done) ->
              @init2()
              @instance.then =>
                  expect(@biskoto.get(@sa_cookie_name).version).to.equal @settings.cookies.version
                  done()
