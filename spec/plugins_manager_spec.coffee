describe 'PluginsManager', ->
  before (done) ->
    @settings =
      general:
        fetch_plugins_url: 'http://example.com/plugins'
      plugins:
        analytics_plugin:
          url: 'http://example.com/analytics_plugin.js'
        not_enabled_plugin:
          url: 'http://example.com/not_enabled_plugin.js'
      triggers:
        addOrder: 'analytics_plugin'
        addItem: 'not_enabled_plugin'

    # mock PluginsSettings
    requirejs.undef 'plugins_settings'
    define 'plugins_settings', => @settings

    require [
      'settings',
      'plugins_manager',
      'promise',
      'plugins_settings',
      'jsonp'], (Settings, PluginsManager, Promise, PluginsSettings, JSONP) =>
      @analytics_settings = Settings
      @plugins_manager = PluginsManager
      @promise = Promise
      @plugins_settings = PluginsSettings
      @jsonp = JSONP

      @plugins_response =
        { plugins: [{ name: 'analytics_plugin', configuration: { position: 'bottom-right' }, data: { test: 'test' } }] }

      done()

   after ->
     requirejs.undef 'plugins_settings'
     window.__requirejs__.clearRequireState()

  beforeEach ->
    @jsonp_fetch_stub = sinon.stub(@jsonp, 'fetch').returns((new @promise).resolve(@plugins_response))
    @jsonp_load_stub = sinon.stub(@jsonp, 'load')
    @subject = new @plugins_manager()

    window.sa_plugins = {}

  afterEach ->
    @jsonp_fetch_stub.restore()
    @jsonp_load_stub.restore()

  describe '.constructor', ->
    it 'initializes the session', ->
      expect(@subject.session).to.be.null

    it 'does not fetch plugins', ->
      expect(@jsonp_fetch_stub.called).to.be.false

  describe '#notify', ->
    beforeEach ->
      @session = { shop_code: 'SA-XXXX-XXX', analytics_session: 'analytics_session' }
      @subject.session = @session

    context 'when action is set to trigger a plugin', ->
      context 'and plugin is enabled', ->
        beforeEach -> @plugin = (plugin for plugin in @plugins_response.plugins when plugin.name is 'analytics_plugin')[0]

        it 'retrieves the enabled plugins', ->
          data = shop_code: @session.shop_code
          @subject.notify('addOrder', { order_id: 1 })

          expect(@jsonp_fetch_stub.withArgs(@settings.general.fetch_plugins_url, data).calledOnce).to.be.true

        it 'caches the retrieved plugins', ->
          @subject.notify('addOrder', { order_id: 1 })

          expect(@subject.enabled_plugins).to.equal(@plugins_response.plugins)

        it 'loads the plugin', ->
          @subject.notify('addOrder', { order_id: 1 })

          expect(@jsonp_load_stub.withArgs(@settings.plugins.analytics_plugin.url).calledOnce).to.be.true

        it 'makes analytics settings available to the plugins', ->
          @subject.notify('addOrder', { order_id: 1 })

          expect(window.sa_plugins.settings).to.equal(@analytics_settings)

        context 'when data is an object', ->
          it 'makes data public', ->
            @subject.notify('addOrder', { order_id: 1 })

            expect(window.sa_plugins.analytics_plugin)
              .to.deep.equal({ order_id: 1, shop_code: @session.shop_code, analytics_session: @session.analytics_session, configuration: @plugin.configuration, data: @plugin.data })

        context 'when data is json stringified', ->
          it 'makes data public', ->
            @subject.notify('addOrder', JSON.stringify({ order_id: 1 }))

            expect(window.sa_plugins.analytics_plugin)
              .to.deep.equal({ order_id: 1, shop_code: @session.shop_code, analytics_session: @session.analytics_session, configuration: @plugin.configuration, data: @plugin.data })

        context 'when data is not a valid json', ->
          beforeEach -> @subject.notify('addOrder', 'not_a_json')

          it 'does not make data public', ->
            expect(window.sa_plugins.analytics_plugin).to.be.undefined

          it 'does not load a plugin', ->
            expect(@jsonp_load_stub.called).to.be.false

        context 'and already loaded', ->
          beforeEach ->
            @subject.notify('addOrder', { order_id: 1 })
            @subject.notify('addOrder', { order_id: 1 })

          it 'loads the plugin only once', ->
            expect(@jsonp_load_stub.withArgs(@settings.plugins.analytics_plugin.url).calledOnce).to.be.true

          it 'does not make multiple api calls', ->
            data = shop_code: @session.shop_code
            expect(@jsonp_fetch_stub.withArgs(@settings.general.fetch_plugins_url, data).calledOnce).to.be.true

      context 'and plugin is not enabled', ->
        beforeEach ->
          @subject.notify('addItem', { order_id: 1 })

        it 'does not make data public', ->
          expect(window.sa_plugins.not_enabled_plugin).to.be.undefined

        it 'does not load a plugin', ->
          expect(@jsonp_load_stub.called).to.be.false

    context 'when action is not set to trigger a plugin', ->
      beforeEach ->
        @subject.notify('nonexistant', { data: 'data' })

      it 'does not make data public', ->
        expect(window.sa_plugins.nonexistant).to.be.undefined

      it 'does not load a plugin', ->
        expect(@jsonp_load_stub.called).to.be.false
