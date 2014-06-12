describe 'Settings', ->
  @timeout(0) # Disable the spec's timeout

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

    it 'has property .actions_queue', ->
      expect(@settings)
        .to.have.property('actions_queue')
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
    it 'has proper .yogurt.name', ->
      expect(@settings)
        .to.have.deep.property('cookies.yogurt.name')
        .that.is.a('string')
        .that.equals('yogurt_session')

    it 'has proper .analytics.name', ->
      expect(@settings)
        .to.have.deep.property('cookies.analytics.name')
        .that.is.a('string')
        .that.equals('analytics_session')

    it 'has proper .analytics.duration', ->
      expect(@settings)
        .to.have.deep.property('cookies.analytics.duration')
        .that.is.an('number')
        .that.equals( (60 * 60 * 24 * 7) )

  describe '.url', ->
    it 'has proper .base', ->
      expect(@settings)
        .to.have.deep.property('url.base')
        .that.is.a('string')
        .that.equals('http://analytics.local:9000')

    it 'has proper .current', ->
      current_url = window.location.href
      expect(@settings)
        .to.have.deep.property('url.current')
        .that.is.a('string')
        .that.equals(current_url)

    describe '.analytics_session', ->
      describe '.create', ->
        it 'returns the proper create endpoint', ->
          base = @settings.url.base
          session = 'foo'
          endpoint = "#{base}/track/create?yogurt_session=#{session}"
          expect(@settings.url.analytics_session.create(session))
            .to.equal(endpoint)

      describe '.connect', ->
        it 'returns the proper connect endpoint', ->
          expect(@settings.url.analytics_session.connect())
            .to.equal("#{@settings.url.base}/track/connect")

    describe '.beacon', ->
      it 'returns the proper beacon endpoint', ->
        base = @settings.url.base
        session = 'foo'
        endpoint = "#{base}/track/actions/create?analytics_session=#{session}"

        expect(@settings.url.beacon(session))
          .to.equal(endpoint)
