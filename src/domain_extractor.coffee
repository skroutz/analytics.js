define [
  'settings'
], (Settings)->
  ###
    First, we consider the part after the last dot as part of the TLD.
    Then, starting from right to left we consider anything that is less than
    4 characters long as part of the TLD. When we reach a level that is
    at least 4 characters we include it in the domain and we stop.

    We also accept a custom TLD list that allows us to bypass this.
    In that case, the domain is determined as the custom TLD plus
    the part immediately preceding it.

    If it is only one level or is an IPv4 address, we do not do any extraction.

    Finally, we drop the www prefix unless it is two levels (www.shop is valid)

    This approach might be problematic in the future, but the only safe
    alternative is to use the Public Suffix List which contains all
    the known TLDs. However is quite large in size.

    @see https://github.com/wrangr/psl
  ###
  class DomainExtractor
    NUMBER_DOT_ONLY_PATTERN = /^[\d.]+$/

    constructor: (hostname) ->
      @hostname = hostname.toLowerCase()

    ###
      Retrieve the base domain from the given hostname

      @param [Boolean] wildcard Whether to append a dot in the beginning of the domain.
      @return [String, null] The base domain or null if is IPv4 or 1 level
    ###
    get: (wildcard = true) ->
      return null if @hostname.match NUMBER_DOT_ONLY_PATTERN # check if it is IPv4

      domain_parts = @hostname.split('.')
      return null if domain_parts.length == 1 # check if it is 1 level

      # remove the www prefix if is not the base domain
      domain_parts.shift() if domain_parts[0] == 'www' and domain_parts.length > 2

      matched_tld = @_matchedCustomTld()

      domain = if matched_tld
                 @_constructMatchedDomain(domain_parts, matched_tld)
               else
                 @_constructDomain(domain_parts)

      domain = '.' + domain if wildcard

      domain

    ###
      Construct the domain name from the domain parts

      @param [Array] domain_parts The hostname splitted by dots, without the www prefix
      @return [String] The domain
    ###
    _constructDomain: (domain_parts) ->
      domain = [domain_parts.pop()]

      while domain_parts.length
        domain.unshift(domain_parts.pop())
        break if domain[0].length > 3

      domain.join('.')

    ###
      Construct the domain based on the custom tld that was matched in the hostname
      Keep the custom tld and extract the next domain levels if necessary

      @param [Array] domain_parts The hostname splitted by dots, without the www prefix
      @param [String] matched_tld The custom tld that was matched in the hostname
      @return [String] The domain
    ###
    _constructMatchedDomain: (domain_parts, matched_tld) ->
      return matched_tld if matched_tld == domain_parts.join('.')

      # if another subdomain level exists, include it in the domain
      matched_tld_length = matched_tld.split('.').length
      next_subdomain = domain_parts[domain_parts.length - matched_tld_length - 1]

      "#{next_subdomain}.#{matched_tld}"

    ###
      Check if the given hostname ends with one of the custom ltd we have set

      @return [String, null] The matched tld or null if not matched
    ###
    _matchedCustomTld: ->
      for tld in @_customTlds()
        dotted_tld = '.' + tld
        if @hostname.indexOf(dotted_tld, @hostname.length - dotted_tld.length) != -1
          return tld

      null

    ###
      Get the defined custom tlds from the settings. Sort the tlds by
      descending length in order to match first a tld that might have more
      levels and has the same base level with another one.
      e.g. 'aa.skroutz.gr' and 'skroutz.gr'
      However there is still a problem if two or more tlds are provided with
      the same length.
      e.g. 'bb.skroutz.gr' and 'aa.skroutz.gr'

      @return [String, null] The matched tld or null if not matched
    ###
    _customTlds: ->
      Settings.custom_tlds.sort (a, b) -> b.length - a.length

  return DomainExtractor
