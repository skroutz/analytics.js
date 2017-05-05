define [
  'settings',
  'plugins_settings',
  'jsonp'
], (Settings, PluginsSettings, JSONP) ->
  ###
  This module provides the capability to analytics.js to load a designated by the
  backend set of plugins and provides them the context (data, configuration) required to operate.
  ###
  class PluginsManager
    constructor: ->
      @session = null
      @loaded_plugins = [] # Use it in order to load a plugin only once

    ###
    Triggers PluginManager to load a plugin by an action

    @example plugins_manager.notify('addOrder', { order_id: 'order_id',... })

    @param [String] action The action that triggers a plugin
    @param [Object, String] data Any additional data required by the plugin
    ###
    notify: (action, data) ->
      @_fetchEnabledPlugins().then =>
        plugin = PluginsSettings.triggers[action]
        return unless plugin

        return if @_pluginIsLoaded(plugin) || !@_pluginIsEnabled(plugin)

        @_load(plugin) if @_publishPluginData(plugin, data)

    _publishPluginData: (name, data) ->
      if typeof data isnt 'object'
        try data = JSON.parse(data)
        catch
          return false

      window.sa_plugins ||= {}
      window.sa_plugins[name] ||= {}
      window.sa_plugins.settings = Settings

      data.shop_code = @session.shop_code
      data.analytics_session = @session.analytics_session
      data.configuration = @_plugin(name).configuration
      data.data = @_plugin(name).data
      window.sa_plugins[name] = data

      true

    _load: (name) ->
      @loaded_plugins.push(name) # Keep which plugins have been loaded
      JSONP.load(@_pluginSettings(name).url)

    _fetchEnabledPlugins: ->
      data = shop_code: @session.shop_code
      # @fetched purpose is to memoize request in order to prevent making multiple api calls
      @fetched ||= JSONP.fetch(PluginsSettings.general.fetch_plugins_url, data).then (response) =>
        @enabled_plugins = response.plugins

    _pluginIsLoaded: (name) -> name in @loaded_plugins

    _pluginIsEnabled: (name) -> name in (plugin.name for plugin in @enabled_plugins)

    _pluginSettings: (name) -> PluginsSettings.plugins[name]

    _plugin: (name) -> (plugin for plugin in @enabled_plugins when plugin.name is name)[0]

  return PluginsManager
