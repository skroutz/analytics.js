describe 'AnalyticsUrl', ->
  NOW = 1560349833558
  EXPIRED_TIME = NOW + 100000

  before (done) ->
    require ['analytics_url', 'helpers/base64_helper'], (AnalyticsUrl, Base64) =>
      @AnalyticsUrl = AnalyticsUrl
      @Base64 = Base64
      @EXPIRATION = NOW + 60 * 1000
      done()

  beforeEach ->
    @clock = sinon.useFakeTimers(NOW, 'Date')
    @mode = { type: 'default' }
    @session = 'analytics_session'
    @metadata = { app: 'mobile' }

  afterEach ->
    @clock.restore()

  describe '.constructor', ->
    it 'creates new AnalyticsUrl for Object', ->
      expect(=> new @AnalyticsUrl('https://shop.gr/product'))
        .to.not.throw()

  describe '#format_params', ->
    beforeEach ->
      @subject = new @AnalyticsUrl('https://shop.gr/product')
      @base64_param = @Base64.encodeURI(JSON.stringify([@session, @EXPIRATION, @metadata]))

    context 'when using default url mode', ->
      it 'formats the params', ->
        expect(@subject.format_params(@mode, @session, @metadata))
          .to.eq("https://shop.gr/product?skr_prm=#{@base64_param}")

      context 'when url already has params', ->
        beforeEach ->
          @subject = new @AnalyticsUrl('https://shop.gr/product?param=val')

        it 'formats the params', ->
          expect(@subject.format_params(@mode, @session, @metadata))
            .to.eq("https://shop.gr/product?param=val&skr_prm=#{@base64_param}")

    context 'when using append_to_param_link_url mode', ->
      beforeEach ->
        @subject = new @AnalyticsUrl('https://link.go/?lnkurl=https%3A%2F%2Fshop.gr%2Fproduct%3Fparam%3Dval&foo=bar')
        @mode = { type: 'append_to_param_link_url', param: 'lnkurl' }

      it 'formats the params', ->
        expect(@subject.format_params(@mode, @session, @metadata))
          .to.eq("https://link.go/?lnkurl=https%3A%2F%2Fshop.gr%2Fproduct%3Fparam%3Dval%26skr_prm%3D#{@base64_param}&foo=bar")

    context 'when using no_append mode', ->
      beforeEach ->
        @subject = new @AnalyticsUrl('https://shop.gr/product')
        @mode = { type: 'no_append' }

      it 'returns the original link', ->
        expect(@subject.format_params(@mode, @session, @metadata))
          .to.eq('https://shop.gr/product')

  describe '#read_params', ->
    beforeEach ->
      @url = new @AnalyticsUrl('https://shop.gr/product').format_params(@mode, @session, @metadata)
      @params = new @AnalyticsUrl(@url).read_params()

    it 'reads session', ->
      expect(@params.session).to.eq(@session)

    it 'reads metadata', ->
      expect(@params.metadata).to.deep.equal(@metadata)

    context 'when link is expired', ->
      beforeEach ->
        @url = new @AnalyticsUrl('https://shop.gr/product').format_params(@mode, @session, @metadata)
        @clock = sinon.useFakeTimers(EXPIRED_TIME, 'Date')
        @params = new @AnalyticsUrl(@url).read_params()

      it 'returns null', ->
        expect(@params).to.equal null

    context 'when url param is missing', ->
      beforeEach ->
        @url = 'https://shop.gr/product'
        @params = new @AnalyticsUrl(@url).read_params()

      it 'returns null', ->
        expect(@params).to.equal null

    context 'when url param is empty', ->
      beforeEach ->
        @url = 'https://shop.gr/product?skr_prm='
        @params = new @AnalyticsUrl(@url).read_params()

      it 'returns null', ->
        expect(@params).to.equal null

    context 'when url param is not valid JSON', ->
      beforeEach ->
        @url = 'https://shop.gr/product?skr_prm=bm90X2pzb24'
        @params = new @AnalyticsUrl(@url).read_params()

      it 'returns null', ->
        expect(@params).to.equal null

    context 'when url param is not base64 encoded', ->
      beforeEach ->
        @url = 'https://shop.gr/product?skr_prm=not base64'
        @params = new @AnalyticsUrl(@url).read_params()

      it 'returns null', ->
        expect(@params).to.equal null
