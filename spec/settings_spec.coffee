describe 'Settings', ->
  set_analytics_object = (analytics_object) ->
    window.SkroutzAnalyticsObject = analytics_object

  unset_analytics_object = -> delete window.SkroutzAnalyticsObject

  beforeEach (done) ->
    @require_settings = (done) =>
      requirejs.undef 'settings'

      require ['settings'], (Settings) =>
        @settings = Settings

        done()

    @require_settings(done)

  afterEach ->
    unset_analytics_object()
    delete @settings

  describe '.flavor', ->
    it 'has property .flavor', ->
      expect(@settings)
        .to.have.property('flavor')
        .that.equals('Skroutz')

  describe 'API', ->
    it 'has property .window', ->
      expect(@settings)
        .to.have.property('window', window)

    it 'has property .redirectTo', ->
      expect(@settings)
        .to.have.property('redirectTo')
        .that.is.an('function')

    describe '.command_queue_name', ->
      it "defaults to 'sa'", ->
        expect(@settings)
          .to.have.property('command_queue_name')
          .that.equals('sa')

      context 'when Analytics Object is defined', ->
        beforeEach (done) ->
          set_analytics_object('skroutz_analytics')

          @require_settings(done)

        it 'assigns the value from Analytics Object', ->
          expect(@settings)
            .to.have.property('command_queue_name')
            .that.equals('skroutz_analytics')

    it 'has property .commands_queue', ->
      expect(@settings)
        .to.have.property('commands_queue')
        .that.is.an('array')

    it 'has property .iframe_message', ->
      expect(@settings)
        .to.have.property('iframe_message')
        .that.is.a('string')
        .that.equals('get_analytics_session')

    it 'has property .single_beacon', ->
      expect(@settings)
        .to.have.property('single_beacon')
        .that.is.a('boolean')

    it 'has property .xdomain_session_timeout', ->
      expect(@settings)
        .to.have.property('xdomain_session_timeout')
        .that.is.a('number')

    it 'has property .auto_pageview_timeout', ->
      expect(@settings)
        .to.have.property('auto_pageview_timeout')
        .that.is.a('number')

    it 'has property .send_auto_pageview', ->
      expect(@settings)
        .to.have.property('send_auto_pageview')
        .that.is.a('boolean')

    it 'has property .cookies', ->
      expect(@settings)
        .to.have.property('cookies')
        .that.is.an('object')

    it 'has property .url', ->
      expect(@settings).to.have.property('url')

    it 'has property .api', ->
      expect(@settings).to.have.property('api')

  describe '.params', ->
    it 'has property .analytics_session', ->
      expect(@settings.params)
        .to.have.property('analytics_session')
        .that.is.a('string')
        .that.equals('analytics_session')

    it 'has property .signature', ->
      expect(@settings.params)
        .to.have.property('signature')
        .that.is.a('string')
        .that.equals('sig')

    it 'has property .url', ->
      expect(@settings.params)
        .to.have.property('url')
        .that.is.a('string')
        .that.equals('url')

    it 'has property .referrer', ->
      expect(@settings.params)
        .to.have.property('referrer')
        .that.is.a('string')
        .that.equals('referer')

    it 'has property .shop_code', ->
      expect(@settings.params)
        .to.have.property('shop_code')
        .that.is.a('string')
        .that.equals('shop_code')

  describe '.cookies', ->
    describe '.basic', ->
      it 'has proper .analytics.name', ->
        expect(@settings)
          .to.have.deep.property('cookies.basic.analytics.name')
          .that.is.a('string')
          .that.equals('__b_sa_session')

      it 'has proper .analytics.duration', ->
        expect(@settings)
          .to.have.deep.property('cookies.basic.analytics.duration')
          .that.is.an('number')
          .that.equals(60 * 30)

      it 'has proper .session.name', ->
        expect(@settings)
          .to.have.deep.property('cookies.basic.session.name')
          .that.is.a('string')
          .that.equals('__b_skr_nltcs_ss')

      it 'has proper .session.duration', ->
        expect(@settings)
          .to.have.deep.property('cookies.basic.session.duration')
          .that.is.an('number')
          .that.equals(60*60*24*15)

      it 'has proper .meta.name', ->
        expect(@settings)
          .to.have.deep.property('cookies.basic.meta.name')
          .that.is.a('string')
          .that.equals('__b_skr_nltcs_mt')

    describe '.full', ->
      it 'has proper .analytics.name', ->
        expect(@settings)
          .to.have.deep.property('cookies.full.analytics.name')
          .that.is.a('string')
          .that.equals('__sa_session')

      it 'has proper .analytics.duration', ->
        expect(@settings)
          .to.have.deep.property('cookies.full.analytics.duration')
          .that.is.an('number')
          .that.equals(60 * 30)

      it 'has proper .session.name', ->
        expect(@settings)
          .to.have.deep.property('cookies.full.session.name')
          .that.is.a('string')
          .that.equals('__skr_nltcs_ss')

      it 'has proper .session.duration', ->
        expect(@settings)
          .to.have.deep.property('cookies.full.session.duration')
          .that.is.an('number')
          .that.equals(60*60*24*15)

      it 'has proper .meta.name', ->
        expect(@settings)
          .to.have.deep.property('cookies.full.meta.name')
          .that.is.a('string')
          .that.equals('__skr_nltcs_mt')

  describe '.url', ->
    it 'has proper .base', ->
      expect(@settings)
        .to.have.deep.property('url.base')
        .that.is.a('string')
        .that.equals('http://localhost:9000')

    it 'has proper .current', ->
      current_url = window.location.href
      expect(@settings)
        .to.have.deep.property('url.current')
        .that.is.a('string')
        .that.equals(current_url)

    describe '.analytics_session', ->
      beforeEach ->
        @base = @settings.url.base
        @shop_code = 'shop_code_1'
        @flavor = 'skroutz'
        @analytics_session = 'analytics_session'
        @cookie_policy = 'full'
        @metadata = JSON.stringify({ app_type: 'web', tags: 'tag1,tag2' })

      describe '.create', ->
        it 'returns the proper create endpoint', ->
          endpoint = "#{@base}/track/create" +
                     "?shop_code=#{@shop_code}" +
                     "&flavor=#{@flavor}" +
                     "&session=#{@analytics_session}" +
                     "&cp=#{@cookie_policy}" +
                     "&metadata=#{@metadata}"

          expect(
            @settings.url.analytics_session.create(
              @shop_code, @flavor, @analytics_session, @cookie_policy, @metadata
            )
          ).to.equal(endpoint)

      describe '.connect', ->
        it 'returns the proper connect endpoint', ->
          endpoint = "#{@base}/track/connect?shop_code=#{@shop_code}"
          expect(@settings.url.analytics_session.connect(@shop_code))
            .to.equal(endpoint)

    describe '.beacon', ->
      it 'returns the proper beacon endpoint', ->
        base = @settings.url.base
        session = 'foo'
        endpoint = "#{base}/track/actions/create?analytics_session=#{session}"

        expect(@settings.url.beacon(session))
          .to.equal(endpoint)

  describe '.api', ->
    it 'has property .settings', ->
      expect(@settings.api)
        .to.have.property('settings')
        .that.is.an('object')

    it 'has property .yogurt', ->
      expect(@settings.api)
        .to.have.property('yogurt')
        .that.is.an('object')

    it 'has property .site', ->
      expect(@settings.api)
        .to.have.property('site')
        .that.is.an('object')

    it 'has property .ecommerce', ->
      expect(@settings.api)
        .to.have.property('ecommerce')
        .that.is.an('object')

    describe '.settings', ->
      it 'has property .key', ->
        expect(@settings.api.settings)
          .to.have.property('key')
          .that.is.a('string')
          .that.equals('settings')

      it 'has property .set_account', ->
        expect(@settings.api.settings)
          .to.have.property('set_account')
          .that.is.a('string')
          .that.equals('setAccount')

      it 'has property .set_callback', ->
        expect(@settings.api.settings)
          .to.have.property('set_callback')
          .that.is.a('string')
          .that.equals('setCallback')

      it 'has property .redirect_to', ->
        expect(@settings.api.settings)
          .to.have.property('redirect_to')
          .that.is.a('string')
          .that.equals('redirectTo')

    describe '.yogurt', ->
      it 'has property .key', ->
        expect(@settings.api.yogurt)
          .to.have.property('key')
          .that.is.a('string')
          .that.equals('yogurt')

      it 'has property .product_click', ->
        expect(@settings.api.yogurt)
          .to.have.property('product_click')
          .that.is.a('string')
          .that.equals('productClick')

    describe '.site', ->
      it 'has property .key', ->
        expect(@settings.api.site)
          .to.have.property('key')
          .that.is.a('string')
          .that.equals('site')

      it 'has property .send_pageview', ->
        expect(@settings.api.site)
          .to.have.property('send_pageview')
          .that.is.a('string')
          .that.equals('sendPageView')

    describe '.ecommerce', ->
      it 'has property .key', ->
        expect(@settings.api.ecommerce)
          .to.have.property('key')
          .that.is.a('string')
          .that.equals('ecommerce')

      it 'has property .add_transaction', ->
        expect(@settings.api.ecommerce)
          .to.have.property('add_transaction')
          .that.is.a('string')
          .that.equals('addTransaction')

      it 'has property .add_item', ->
        expect(@settings.api.ecommerce)
          .to.have.property('add_item')
          .that.is.a('string')
          .that.equals('addItem')
