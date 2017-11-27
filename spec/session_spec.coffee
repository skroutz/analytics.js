clear_all_cookies = ->
  document.cookie.split(/;\s/g).forEach (cookie)->
    document.cookie = "#{cookie.split('=')[0]}= ;expires=Wed, 28 May 2000 10:53:43 GMT"

session_creation_tests = (cookies_enabled = false, cookie_exists = false)->
  if cookies_enabled
    if cookie_exists
      it 'replaces first-party cookie data with retrieved data', (done)->
        @init2()
        @instance.then =>
          expect(@biskoto.get(@cookie_name).analytics_session).to.equal @analytics_session
          done()
    else
      it 'creates a first-party cookie with that value', (done)->
        @init2()
        @instance.then =>
          expect(@biskoto.get(@cookie_name).analytics_session).to.equal @analytics_session
          done()

      it 'creates first-party cookie with proper version', (done)->
        @init2()
        @instance.then =>
          expect(@biskoto.get(@cookie_name).version).to.equal @settings.cookies.version
          done()
  else
    it 'does not create a cookie', ->
      prev_length = document.cookie.split(/;\s/g).length
      @init2()

      expect(document.cookie.split(/;\s/g).length).to.equal prev_length

  it 'it registers that value to @analytics_session', ->
    @init2()
    expect(@instance.analytics_session).to.equal @analytics_session

  it 'it resolves promise with that value', (done) ->
    @init2()
    @instance.then (session) =>
      expect(session.analytics_session).to.equal @analytics_session
      done()

session_retrieval_tests = (cookies_enabled = false, cookie_exists = false)->
  it 'tries to extract analytics_session from Xdomain engine', ->
    @init()
    expect(@xdomain_spy).to.be.calledOnce

  it 'passes type to Xdomain engine', ->
    @init()
    expect(@xdomain_spy.args[0][0]).to.equal @type

  it 'passes shop_code to Xdomain engine', ->
    @init()
    expect(@xdomain_spy.args[0][1]).to.equal @shop_code

  it 'tries to extract analytics_session from GetParam engine', ->
    @init()
    expect(@get_param_spy).to.be.calledOnce

  context 'when only the XDomain engine resolves', ->
    beforeEach ->
      @init2 = =>
        @init()
        @xdomain_promise.resolve(@analytics_session)
        @get_param_promise.reject()
        return

    session_creation_tests(cookies_enabled, cookie_exists)

  context 'when only the GetParam engine resolves', ->
    beforeEach ->
      @init2 = =>
        @init()
        @xdomain_promise.reject()
        @get_param_promise.resolve(@analytics_session)
        return

    session_creation_tests(cookies_enabled, cookie_exists)

  context 'when both XDomain and GetParam resolve', ->
    it 'it uses the value from the XDomain engine', (done)->
      @init()
      @xdomain_promise.resolve('asd')
      @get_param_promise.resolve('dsa')
      @instance.then (session) =>
        expect(session.analytics_session).to.equal 'asd'
        done()

  context 'when both engines reject', ->
    beforeEach ->
      @init()
      @xdomain_promise.reject()
      @get_param_promise.reject()
      return

    it 'it rejects the @promise', (done)->
      resolve = ->
        assert.fail()
        done()
      reject = ->
        assert.ok(true)
        done()

      @instance.then(resolve, reject)

    if cookies_enabled
      it 'does not create a first-party cookie', ->
        prev_length = document.cookie.split(/;\s/g).length
        @init()

        expect(document.cookie.split(/;\s/g).length).to.equal prev_length

inside_yogurt_tests = (cookies_enabled = false)->
  if cookies_enabled
    context 'when a first-party cookie exists', ->
      beforeEach ->
        @biskoto.set @cookie_name, {version:1, analytics_session: 'asd'}, @cookie_options

      it 'initializes @analytics_session to the first-party cookie\'s value', ->
        @init()
        expect(@instance.analytics_session).to.equal 'asd'


      context 'when cookie version has changed', ->
        beforeEach ->
          @settings.cookies.version = @prev_cookies_version + 1

        it 'deletes first-party cookie', ->
          @init()
          expect(@biskoto.get(@cookie_name)).to.be.null

      session_retrieval_tests(cookies_enabled, true)

    context 'when a first-party cookie does not exist', ->
      it 'intializes @analytics_session to null', ->
        @init()
        expect(@instance.analytics_session).to.be.null

      session_retrieval_tests(cookies_enabled, false)
  else
    context 'when a first-party cookie exists', ->
      beforeEach ->
        @biskoto.set @cookie_name, @cookie_data, @cookie_options

      it 'deletes first-party cookie', ->
        @init()
        expect(@biskoto.get(@cookie_name)).to.be.null

    session_retrieval_tests(cookies_enabled, false)

outside_yogurt_tests = (cookies_enabled = false)->
  if cookies_enabled
    context 'when a first-party cookie exists', ->
      beforeEach ->
        @biskoto.set @cookie_name, {version:1, analytics_session: 'asd'}, @cookie_options

      it 'resolves the @promise with the "analytics_session" found in the cookie', (done)->
        @init()
        @instance.then (session) ->
          expect(session.analytics_session).to.equal 'asd'
          done()

      it 'does not use the XDomain engine to retrieve the "analytics_session"', ->
        @init()
        expect(@xdomain_spy).to.not.be.called

      it 'does not use the GetParam engine to retrieve the "analytics_session"', ->
        @init()
        expect(@get_param_spy).to.not.be.called

    context 'when a first-party cookie does not exist', ->
      session_retrieval_tests(cookies_enabled, false)
  else
    context 'when a first-party cookie exists', ->
      beforeEach ->
        @biskoto.set @cookie_name, @cookie_data, @cookie_options

      it 'deletes first-party cookie ', ->
        @init()
        expect(@biskoto.get(@cookie_name)).to.be.null

    session_retrieval_tests(cookies_enabled)

describe 'Session', ->
  before (done) ->
    @type_create       = 'create'
    @type_connect      = 'connect'
    @yogurt_session    = 'dummy_yogurt_session_hash'
    @yogurt_user_id    = '1234'
    @shop_code         = 'shop_code_1'
    @analytics_session = 'dummy_analytics_session_hash'
    @flavor            = 'flavor'
    @metadata          = JSON.stringify({ app_type: 'web', tags: 'tag1,tag2' })

    require [
      'promise'
    ], (Promise)=>
      @promise  = Promise

      window.__requirejs__.clearRequireState()
      requirejs.undef 'session_engines/get_param_engine'
      @get_param_promise = new @promise()
      @get_param_mock = => return @get_param_promise
      @get_param_spy = sinon.spy @, 'get_param_mock'
      define 'session_engines/get_param_engine', [], => @get_param_mock

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
      ], (Session, PluginsManager, Promise, Biskoto, Settings)=>
        @session = Session
        @PluginsManager = PluginsManager
        @promise  = Promise
        @biskoto  = Biskoto
        @settings = Settings
        done()

  after ->
    requirejs.undef 'session_engines/get_param_engine'
    requirejs.undef 'session_engines/xdomain_engine'
    window.__requirejs__.clearRequireState()

  beforeEach ->
    @plugins_manager = new @PluginsManager()

  afterEach ->
    @get_param_promise = new @promise()
    @get_param_spy.reset()
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
      @stub = sinon.stub @instance, '_extractAnalyticsSession'
      @resolve_spy = sinon.spy()
      @reject_spy = sinon.spy()

    afterEach ->
      @resolve_spy.reset()
      @reject_spy.reset()
      @stub.restore()

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

      @prev_cookies_enabled = @settings.cookies.first_party_enabled
      @prev_cookies_version = @settings.cookies.version

      @cookie_name = @settings.cookies.analytics.name
      @cookie_data =
        version: 1
        analytics_session: @analytics_session
      @cookie_options =
        expires: @settings.cookies.analytics.duration

    afterEach ->
      @settings.cookies.first_party_enabled = @prev_cookies_enabled
      @settings.cookies.version = @prev_cookies_version

    context 'on session create', ->
      beforeEach ->
        @parsed_settings =
          yogurt_user_id: @yogurt_user_id
          yogurt_session: @yogurt_session
          shop_code: @shop_code
          flavor: @flavor
          metadata: @metadata
        @type = @type_create
        @init = =>
          sa('session', 'create', @shop_code, @yogurt_session, @yogurt_user_id, @flavor, @metadata)
          @instance = new @session(@plugins_manager).run()

      context 'when first-party cookies are enabled', ->
        beforeEach ->
          @settings.cookies.first_party_enabled = true

        inside_yogurt_tests(true)

      context 'when first-party cookies are disabled', ->
        beforeEach ->
          @settings.cookies.first_party_enabled = false

        inside_yogurt_tests(false)

    context 'on session connect', ->
      beforeEach ->
        @parsed_settings =
          yogurt_user_id: @yogurt_user_id
          yogurt_session: @yogurt_session
          shop_code: @shop_code
        @type = @type_connect
        @init = =>
          sa('session', 'connect', @shop_code)
          @instance = new @session(@plugins_manager).run()

      it 'assigns itself in plugins_manager', ->
        @init()

        expect(@plugins_manager.session).to.equal(@instance)

      it 'notifies the plugins manager', ->
        spy_notify = sinon.spy(@plugins_manager, 'notify')

        @init()

        expect(spy_notify).to.be.calledWithExactly('connect', {})

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

        it 'tries to extract the session only once', ->
          @init()
          spy_extract = sinon.spy(@instance, '_extractAnalyticsSession')

          @instance.run()

          expect(spy_extract).to.have.been.calledOnce

        context 'when analytics_session is already extracted', ->
          it 'resolves the promise only once', ->
            @init()
            @instance.analytics_session = 'analytics_session'

            stub_promise = sinon.stub(@instance.promise, 'resolve')

            @instance.run()

            expect(stub_promise).to.have.been.calledOnce

      context 'when first-party cookies are enabled', ->
        beforeEach ->
          @settings.cookies.first_party_enabled = true

        outside_yogurt_tests(true)

      context 'when first-party cookies are disabled', ->
        beforeEach ->
          @settings.cookies.first_party_enabled = false

        outside_yogurt_tests(false)

