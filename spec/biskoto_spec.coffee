describe 'Biskoto', ->
  before (done) ->
    require ['biskoto'], (Biskoto) =>
      @biskoto = Biskoto
      done()

  describe 'API', ->
    it 'responds to .get', ->
      expect(@biskoto).itself.to.respondTo('get')

    it 'responds to .set', ->
      expect(@biskoto).itself.to.respondTo('set')

    it 'responds to .expire', ->
      expect(@biskoto).itself.to.respondTo('expire')

  describe '#get', ->
    afterEach ->
      document.cookie = 'foo=; expires=Thu, 01 Jan 1970 00:00:01 GMT;'

    context 'when cookie exist', ->
      it 'returns the proper cookie value', ->
        document.cookie = 'foo=bar'
        expect(@biskoto.get('foo')).to.deep.equal('bar')

    context 'when cookie not exist', ->
      it 'returns null', ->
        expect(@biskoto.get('foobar')).to.be.null

  describe '#set', ->
    afterEach ->
      document.cookie = 'foo2=; expires=Thu, 01 Jan 1970 00:00:01 GMT;'

    it 'sets the proper cookie', ->
      options = {
        expires: 10000
        secure: false
        domain: ''
        path: '/'
      }
      @biskoto.set('foo2', 'bar', options)
      expect(@biskoto.get('foo2')).to.deep.equal('bar')

  describe '#expire', ->
    it 'deletes the cookie', ->
      @biskoto.set('foo', 'bar')
      @biskoto.expire('foo')
      expect(@biskoto.get('foo')).to.be.null
