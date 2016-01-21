describe 'Settings', ->
  before (done) ->
    require ['settings'], (Settings) =>
      @settings = Settings
      done()

  describe 'API', ->
    it 'has property .window', ->
      expect(@settings)
        .to.have.property('window')
        .that.is.an('object')

    it 'has property .redirectTo', ->
      expect(@settings)
        .to.have.property('redirectTo')
        .that.is.an('function')

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

    it 'has property .shop_code', ->
      expect(@settings.params)
        .to.have.property('shop_code')
        .that.is.a('string')
        .that.equals('shop_code')

  describe '.cookies', ->
    it 'has proper .analytics.name', ->
      expect(@settings)
        .to.have.deep.property('cookies.analytics.name')
        .that.is.a('string')
        .that.equals('analytics_session')

    it 'has proper .analytics.duration', ->
      expect(@settings)
        .to.have.deep.property('cookies.analytics.duration')
        .that.is.an('number')
        .that.equals( (60 * 60 * 24 * 30) )

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
        @session = 'foo'
        @yogurt_user_id = '123'
        @shop_code = 'shop_code_1'

      describe '.create', ->
        it 'returns the proper create endpoint', ->
          endpoint = "#{@base}/track/create?yogurt_session=#{@session}&yogurt_user_id=#{@yogurt_user_id}&shop_code=#{@shop_code}"
          expect(@settings.url.analytics_session.create(@shop_code, @session, @yogurt_user_id))
            .to.equal(endpoint)

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

      it 'has property .yogurt_session', ->
        expect(@settings.api.settings)
          .to.have.property('yogurt_session')
          .that.is.a('string')
          .that.equals('setYogurtSession')

      it 'has property .yogurt_user', ->
        expect(@settings.api.settings)
          .to.have.property('yogurt_user')
          .that.is.a('string')
          .that.equals('setYogurtUser')

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
