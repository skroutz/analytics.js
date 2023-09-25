describe 'PluginsManager', ->
  before (done) ->
    mock_plugin_settings =
      general:
        fetch_plugins_url: 'http://example.com/plugins'
      plugins:
        analytics_plugin:
          url: 'http://example.com/analytics_plugin.js'
        analytics_plugin_2:
          url: 'http://example.com/analytics_plugin_2.js'
        not_enabled_plugin:
          url: 'http://example.com/not_enabled_plugin.js'
      triggers:
        addOrder: 'analytics_plugin'
        addItem: 'not_enabled_plugin'
        cancelOrder: ['not_enabled_plugin', 'analytics_plugin_2', 'analytics_plugin']

    # mock PluginsSettings
    requirejs.undef 'plugins_settings'
    define 'plugins_settings', => mock_plugin_settings

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
        { plugins: [{ name: 'analytics_plugin', configuration: { position: 'bottom-right' }, data: { test: 'test' } },
                    { name: 'analytics_plugin_2', configuration: { answer: ' yes' }, data: { test_2: 'test_2' } }] }

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
      xcontext 'and plugin is enabled', ->
        beforeEach -> @plugin = (plugin for plugin in @plugins_response.plugins when plugin.name is 'analytics_plugin')[0]

        it 'retrieves the enabled plugins', ->
          data = shop_code: @session.shop_code
          @subject.notify('addOrder', { order_id: 1 })

          expect(@jsonp_fetch_stub.withArgs(@plugins_settings.general.fetch_plugins_url, data).calledOnce).to.be.true

        it 'caches the retrieved plugins', ->
          @subject.notify('addOrder', { order_id: 1 })

          expect(@subject.enabled_plugins).to.equal(@plugins_response.plugins)

        it 'loads the plugin', ->
          @subject.notify('addOrder', { order_id: 1 })

          expect(@jsonp_load_stub.withArgs(@plugins_settings.plugins.analytics_plugin.url).calledOnce).to.be.true

        it 'makes analytics settings available to the plugins', ->
          @subject.notify('addOrder', { order_id: 1 })

          settings =
            url:
              base: @analytics_settings.url.base
              application_base: @analytics_settings.url.application_base
            plugins: @plugins_settings.plugins

          expect(window.sa_plugins.settings).to.eql(settings)

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
            expect(@jsonp_load_stub.withArgs(@plugins_settings.plugins.analytics_plugin.url).calledOnce).to.be.true

          it 'does not make multiple api calls', ->
            data = shop_code: @session.shop_code
            expect(@jsonp_fetch_stub.withArgs(@plugins_settings.general.fetch_plugins_url, data).calledOnce).to.be.true

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

    context 'when action is set to trigger multiple plugins', ->
      beforeEach ->
        @plugin = (plugin for plugin in @plugins_response.plugins when plugin.name is 'analytics_plugin')[0]
        @plugin_2 = (plugin for plugin in @plugins_response.plugins when plugin.name is 'analytics_plugin_2')[0]
        @not_enabled_plugin = (plugin for plugin in @plugins_response.plugins when plugin.name is 'not_enabled_plugin')[0]

      xit 'retrieves the enabled plugins', ->
        data = shop_code: @session.shop_code
        @subject.notify('cancelOrder', { order_id: 1 })

        expect(@jsonp_fetch_stub.withArgs(@plugins_settings.general.fetch_plugins_url, data).calledOnce).to.be.true

      xit 'caches the retrieved plugins', ->
        @subject.notify('cancelOrder', { order_id: 1 })

        expect(@subject.enabled_plugins).to.equal(@plugins_response.plugins)

      xit 'loads the plugins', ->
        @subject.notify('cancelOrder', { order_id: 1 })

        expect(@jsonp_load_stub.withArgs(@plugins_settings.plugins.analytics_plugin.url).calledOnce).to.be.true
        expect(@jsonp_load_stub.withArgs(@plugins_settings.plugins.analytics_plugin_2.url).calledOnce).to.be.true

      xit 'makes analytics settings available to the plugins', ->
        @subject.notify('cancelOrder', { order_id: 1 })

        settings =
          url:
            base: @analytics_settings.url.base
            application_base: @analytics_settings.url.application_base
          plugins: @plugins_settings.plugins

        expect(window.sa_plugins.settings).to.eql(settings)

      context 'when data is an object', ->
        xit 'makes data public', ->
          @subject.notify('cancelOrder', { order_id: 1 })

          expect(window.sa_plugins.analytics_plugin)
            .to.deep.equal({ order_id: 1, shop_code: @session.shop_code, analytics_session: @session.analytics_session, configuration: @plugin.configuration, data: @plugin.data })
          expect(window.sa_plugins.analytics_plugin_2)
            .to.deep.equal({ order_id: 1, shop_code: @session.shop_code, analytics_session: @session.analytics_session, configuration: @plugin_2.configuration, data: @plugin_2.data })

      context 'when data is json stringified', ->
        xit 'makes data public', ->
          @subject.notify('cancelOrder', JSON.stringify({ order_id: 1 }))

          expect(window.sa_plugins.analytics_plugin)
            .to.deep.equal({ order_id: 1, shop_code: @session.shop_code, analytics_session: @session.analytics_session, configuration: @plugin.configuration, data: @plugin.data })
          expect(window.sa_plugins.analytics_plugin_2)
            .to.deep.equal({ order_id: 1, shop_code: @session.shop_code, analytics_session: @session.analytics_session, configuration: @plugin_2.configuration, data: @plugin_2.data })

      context 'when data is not a valid json', ->
        beforeEach -> @subject.notify('cancelOrder', 'not_a_json')

        it 'does not make data public', ->
          expect(window.sa_plugins.analytics_plugin).to.be.undefined

        it 'does not load a plugin', ->
          expect(@jsonp_load_stub.called).to.be.false

      context 'and already loaded', ->
        beforeEach ->
          @subject.notify('cancelOrder', { order_id: 1 })
          @subject.notify('cancelOrder', { order_id: 1 })

        xit 'loads the plugins only once', ->
          expect(@jsonp_load_stub.withArgs(@plugins_settings.plugins.analytics_plugin.url).calledOnce).to.be.true
          expect(@jsonp_load_stub.withArgs(@plugins_settings.plugins.analytics_plugin_2.url).calledOnce).to.be.true

        xit 'does not make multiple api calls', ->
          data = shop_code: @session.shop_code
          expect(@jsonp_fetch_stub.withArgs(@plugins_settings.general.fetch_plugins_url, data).calledOnce).to.be.true

      context 'and a plugin is not enabled', ->
        beforeEach ->
          @subject.notify('cancelOrder', { order_id: 1 })

        it 'does not load that not enabled plugin', ->
          expect(@jsonp_load_stub.withArgs(@plugins_settings.plugins.not_enabled_plugin.url).called).to.be.false
