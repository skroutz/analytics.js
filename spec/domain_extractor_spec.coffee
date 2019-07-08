describe 'DomainExtractor', ->
  before (done) ->
    require ['settings', 'domain_extractor'], (Settings, DomainExtractor) =>
      @Settings = Settings
      @DomainExtractor = DomainExtractor
      done()

  describe '.constructor', ->
    it 'creates new DomainExtractor for Object', ->
      expect(=> new @DomainExtractor('www.shop.gr'))
        .to.not.throw()

  describe '#get', ->
    beforeEach ->
      @subject = new @DomainExtractor('sub.shop.gr')

    it 'extracts the wildcard base domain', ->
      expect(@subject.get()).to.eq('.shop.gr')

    context 'when the wildcard option is false', ->
      it 'extracts the base domain', ->
        expect(@subject.get(false)).to.eq('shop.gr')

    context 'when is prefixed with www and is more than 4 characters', ->
      beforeEach ->
        @subject = new @DomainExtractor('www.shop.gr')

      it 'extracts the base domain without the prefix', ->
        expect(@subject.get()).to.eq('.shop.gr')

    context 'when is prefixed with www and is less than 4 characters', ->
      beforeEach ->
        @subject = new @DomainExtractor('www.sho.gr')

      it 'extracts the base domain without the prefix', ->
        expect(@subject.get()).to.eq('.sho.gr')

    context 'when is prefixed with www and is 2 levels', ->
      beforeEach ->
        @subject = new @DomainExtractor('www.shop')

      it 'returns the domain including the www', ->
        expect(@subject.get()).to.eq '.www.shop'

    context 'when is an IPv4 address', ->
      beforeEach ->
        @subject = new @DomainExtractor('127.0.0.1')

      it 'returns null', ->
        expect(@subject.get()).to.eq null

    context 'when is 1 level', ->
      beforeEach ->
        @subject = new @DomainExtractor('localhost')

      it 'returns null', ->
        expect(@subject.get()).to.eq null

    context 'when has a custom tld', ->
      context 'and has no subdomain', ->
        beforeEach ->
          @subject = new @DomainExtractor('skroutzstore.gr')

        it 'extracts the custom base domain', ->
          expect(@subject.get()).to.eq('.skroutzstore.gr')

      context 'and has subdomain', ->
        beforeEach ->
          @subject = new @DomainExtractor('la.la.skroutzstore.gr')

        it 'extracts the custom base domain including the next level subdomain', ->
          expect(@subject.get()).to.eq('.la.skroutzstore.gr')

      context 'and are defined multiple custom tlds with the same base domain', ->
        beforeEach ->
          @prev_custom_tlds = @Settings.custom_tlds
          @Settings.custom_tlds.push('sub.skroutzstore.gr')
          @subject = new @DomainExtractor('la.sub.skroutzstore.gr')

        afterEach ->
          @Settings.custom_tlds = @prev_custom_tlds

        it 'extracts the custom base domain based on the longer in length domain', ->
          expect(@subject.get()).to.eq('.la.sub.skroutzstore.gr')

    context 'when the domain is one level deep', ->
      context 'and has 3 characters', ->
        beforeEach ->
          @subject = new @DomainExtractor('xxx.gr')

        it 'extracts the proper base domain', ->
          expect(@subject.get()).to.eq('.xxx.gr')

      context 'and has 4 characters', ->
        beforeEach ->
          @subject = new @DomainExtractor('xxxx.gr')

        it 'extracts the proper base domain', ->
          expect(@subject.get()).to.eq('.xxxx.gr')

    context 'when the domain is two levels deep', ->
      context 'and the levels have 3 and 3 characters respectively', ->
        beforeEach ->
          @subject = new @DomainExtractor('yyy.xxx.gr')

        it 'extracts the proper base domain', ->
          expect(@subject.get()).to.eq('.yyy.xxx.gr')

      context 'and the levels have 3 and 4 characters respectively', ->
        beforeEach ->
          @subject = new @DomainExtractor('yyy.xxxx.gr')

        it 'extracts the proper base domain', ->
          expect(@subject.get()).to.eq('.xxxx.gr')

      context 'and the levels have 4 and 3 characters respectively', ->
        beforeEach ->
          @subject = new @DomainExtractor('yyyy.xxx.gr')

        it 'extracts the proper base domain', ->
          expect(@subject.get()).to.eq('.yyyy.xxx.gr')

      context 'and the levels have 4 and 4 characters respectively', ->
        beforeEach ->
          @subject = new @DomainExtractor('yyyy.xxxx.gr')

        it 'extracts the proper base domain', ->
          expect(@subject.get()).to.eq('.xxxx.gr')
