describe 'Base64', ->
  before (done) ->
    require ['helpers/base64_helper'], (Base64) =>
      @Base64 = Base64
      done()

  beforeEach ->
    @original = 'i am a string'
    @encoded = 'aSBhbSBhIHN0cmluZw=='

  describe 'API', ->
    beforeEach ->
      @subject = @Base64

    it 'responds to encode', ->
      expect(@subject).to.respondTo('encode')

    it 'responds to encodeURI', ->
      expect(@subject).to.respondTo('encodeURI')

    it 'responds to decode', ->
      expect(@subject).to.respondTo('decode')

  describe '.encode', ->
    beforeEach ->
      @subject = @Base64.encode(@original)

    it 'encodes the given string properly', ->
      expect(@subject).to.eq(@encoded)

    context 'when string contains non-ascii characters', ->
      beforeEach ->
        @original = 'είμαι ένα αλφαριθμητικό'
        @encoded = 'zrXOr868zrHOuSDOrc69zrEgzrHOu8+GzrHPgc65zrjOvM63z4TOuc66z4w='
        @subject = @Base64.encode(@original)

      it 'encodes the given string properly', ->
        expect(@subject).to.eq(@encoded)

  describe '.encodeURI', ->
    beforeEach ->
      @encoded = 'aSBhbSBhIHN0cmluZw'
      @subject = @Base64.encodeURI(@original)

    it 'encodes the given string properly', ->
      expect(@subject).to.eq(@encoded)

    context 'when string contains non-ascii characters', ->
      beforeEach ->
        @original = 'είμαι ένα αλφαριθμητικό'
        @encoded = 'zrXOr868zrHOuSDOrc69zrEgzrHOu8-GzrHPgc65zrjOvM63z4TOuc66z4w'
        @subject = @Base64.encodeURI(@original)

      it 'encodes the given string properly', ->
        expect(@subject).to.eq(@encoded)

  describe '.decode', ->
    beforeEach ->
      @subject = @Base64.decode(@encoded)

    it 'decodes the given string properly', ->
      expect(@subject).to.eq(@original)

    context 'when original string contained non-ascii characters', ->
      beforeEach ->
        @original = 'είμαι ένα αλφαριθμητικό'
        @encoded = 'zrXOr868zrHOuSDOrc69zrEgzrHOu8+GzrHPgc65zrjOvM63z4TOuc66z4w='
        @subject = @Base64.decode(@encoded)

      it 'decodes the given string properly', ->
        expect(@subject).to.eq(@original)

    context 'when original string was URI encoded', ->
      beforeEach ->
        @encoded = 'aSBhbSBhIHN0cmluZw'
        @subject = @Base64.decode(@encoded)

      it 'decodes the given string properly', ->
        expect(@subject).to.eq(@original)
