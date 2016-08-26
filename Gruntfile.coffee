module.exports = (grunt) ->
  ENV = grunt.option("env") or process.env.GRUNT_ENV or 'development'

  FLAVORS = grunt.file.readYAML('config/settings/flavors.yml')
  DEFAULT_FLAVOR = 'skroutz'

  plugins_hashes_mapping = ->
    compiled_assets = grunt.file.readJSON('compiled/assets.json')
    plugins = {}
    for k,v of compiled_assets
      if(/^js\/plugins\//.test(k))
        plugin = if ENV isnt 'development' then v.replace('.js', '.min.js') else v
        plugins["#{k.substring(k.lastIndexOf('js/plugins/')+11, k.lastIndexOf('.js'))}_hash"] = plugin
    plugins

  grunt.initConfig
    env: ENV
    pkg: grunt.file.readJSON('package.json')

    clean:
      payload:
        src: ['.tmp/js/payload*']
      plugins:
        src: ['.tmp/js/plugins/*']
      tmp:
        src: ['.tmp']

    environment:
      src: './config/settings/'
      default: 'default'
      format: 'yaml'
      active: 'development'
      configVariable: 'env_settings'
      envFilePath: '.environment'

    compress:
      dist:
        options:
          mode: 'gzip'

        expand: true
        extDot: 'last'
        ext: '.js.gz'
        cwd: '.tmp/'
        src: ['**/*.js']
        dest: '.tmp/'

    hash:
      options:
        mapping: 'compiled/assets.json'
        srcBasePath: '.tmp/'
        destBasePath: '.tmp/'
        hashFunction: (source, encoding) -> # default is md5
          require('crypto').createHash('sha1').update(source, encoding).digest 'hex'

      payload:
        src: '.tmp/js/payload.js'
        dest: '.tmp/js'

      plugins:
        src: '.tmp/js/plugins/*'
        dest: '.tmp/js/plugins/'

    replace:
      settings:
        options:
          patterns: [json: (done) ->
            settings = grunt.config('env_settings')
            flavor_settings = settings[grunt.config.get('current_flavor')]

            for property of flavor_settings
              settings[property] = flavor_settings[property]

            done settings
            return
          ]

        files: [
          { src: 'src/settings.coffee.sample', dest: 'src/settings.coffee' },
          { src: 'src/plugins_settings.coffee.sample', dest: 'src/plugins_settings.coffee' }
        ]

      loader:
        options:
          patterns: [
            {
              match: 'payload_hash'
              replacement: ->
                filename = grunt.file.readJSON('compiled/assets.json')['js/payload.js']
                if grunt.config('env') isnt 'development'
                  filename = filename.replace('.js', '.min.js')
                filename
            }
            {
              match: 'analytics_base_url'
              replacement: ->
                grunt.config('env_settings')[grunt.config.get('current_flavor')].analytics_base_url
            }
          ]

        files: [
          src: 'compiled/loader.js'
          dest: '.tmp/analytics.js'
        ]

      plugins_settings:
        options:
          patterns: [
            {
              json: (done) -> done(plugins_hashes_mapping())
            }
          ]

        files: [
          src: '.tmp/js/payload.js'
          dest: '.tmp/js/payload.js'
        ]

    bump:
      options:
        pushTo: 'origin'

    optimize_rjs:
      analytics:
        dest: 'compiled/payload.js'

    karma:
      options:
        configFile: 'karma.conf.js'
        browsers: ['PhantomJS']

      unit:
        browsers: ['Chrome']
        logLevel: 'ERROR'
        background: true

      single:
        logLevel: 'ERROR'
        singleRun: true

    watch:
      tests:
        files: [
          'spec/**/*_spec.coffee'
          'spec/**/*.html'
          'spec/**/*.json'
          '!spec/coverage/**/*'
        ]
        tasks: ['karma:unit:run']

      payload:
        options:
          livereload: true
          spawn: false
        files: [
          'config/settings/*.yml'
          'src/**/*.coffee'
          'src/settings.coffee.sample'
        ]
        tasks: [
          'create_env_settings'
          'build_dist'
          'karma:unit:run'
        ]

      plugins:
        options:
          livereload: true
          spawn: false
        files: [
          'config/settings/*.yml'
          'src/plugins/**/*.coffee'
          'src/plugins_settings.coffee.sample'
        ]
        tasks: [
          'create_env_settings'
          'build_plugins'
          'build_dist'
        ]

    coffee:
      options:
        bare: true

      payload:
        expand: true
        cwd: 'src'
        src: [
          '**/*.coffee'
          '!loader.coffee'
          '!plugins/*'
        ]
        dest: 'compiled/'
        ext: '.js'

      loader:
        src: ['src/loader.coffee']
        dest: 'compiled/loader.js'

      plugins:
        options:
          bare: false
        expand: true
        cwd: 'src/plugins'
        src: '*.coffee'
        dest: 'compiled/plugins/'
        ext: '.js'

    uglify:
      options:
        mangle: false
        beautify:
          ascii_only: true

        preserveComments: false
        report: 'min'
        compress:
          hoist_funs: false
          loops: false
          unused: false

      payload:
        files: [
          expand: true
          cwd: '.tmp/js'
          extDot: 'last'
          src: [
            '**/*.js'
            '!**/*.min.js'
          ]
          dest: '.tmp/js'
          ext: '.min.js'
        ]

      loader:
        files:
          '.tmp/analytics.min.js': '.tmp/analytics.js'

        options:
          banner: '/*! <%= pkg.name %> v<%= pkg.version %> \n ' +
            '(c) <%= grunt.template.today("yyyy") %> <%= pkg.company %> \n ' +
            '<%= pkg.license %> */\n'

      plugins:
        files: [
          expand: true
          cwd: '.tmp/js/plugins'
          extDot: 'last'
          src: [
            '**/*.js'
            '!**/*.min.js'
          ]
          dest: '.tmp/js/plugins'
          ext: '.min.js'
        ]

    concat:
      options:
        separator: ';\n'

      payload:
        options:
          separator: '\n'

        src: [
          'bower_components/json2/json2.js'
          'tasks/wrappers/analytics/intro.js'
          'compiled/payload.js'
          'tasks/wrappers/analytics/outro.js'
        ]
        dest: '.tmp/js/payload.js'

      easyxdm_module:
        src: [
          'tasks/wrappers/easyxdm/intro.js'
          'compiled/vendor/easyXDM.js'
          'tasks/wrappers/easyxdm/outro.js'
        ]
        dest: 'compiled/easyXDM.js'

    bower:
      install:
        options:
          install: true
          copy: false
          cleanTargetDir: false
          cleanBowerDir: false

    shell:
      cleanup:
        options:
          stdout: true

        command: 'rm -rf compiled dist src/{plugins_,}settings.coffee'

    copy:
      ymls:
        expand: true
        cwd: 'config/settings'
        src: ['{testing,development}.yml.sample']
        dest: 'config/settings'
        ext: '.yml'

      easyxdm_module:
        expand: true
        cwd: 'vendor'
        src: ['easyXDM.js']
        dest: 'compiled/vendor'

      easyxdm:
        expand: true
        cwd: 'vendor'
        src: ['easyXDM.min.js']
        dest: '.tmp/js'

      plugins:
        expand: true
        cwd: 'compiled'
        src: 'plugins/*'
        dest: '.tmp/js'

      tmp:
        expand: true
        cwd: '.tmp/'
        src: '**'
        dest: "dist/<%= grunt.config.get('current_flavor') %>/"

  require('load-grunt-tasks') grunt
  grunt.loadTasks 'tasks'

  #TEST TASKS
  grunt.registerTask 'start_test_server', ['karma:unit:start']
  grunt.registerTask 'run_tests', ['karma:unit:run']

  #BOWER TASKS
  grunt.registerTask 'bower_install', [
    'bower:install'
  ]
  grunt.registerTask 'create_env_settings', [
    'environment:' + ENV
    'replace:settings'
  ]

  #BUILD PAYLOAD
  grunt.registerTask 'build_payload', [
    'clean:payload'
    'create_easyxdm_module'
    'coffee:payload'
    'optimize_rjs'
    'concat:payload'
    'replace:plugins_settings'
  ]
  grunt.registerTask 'create_easyxdm_module', [
    'copy:easyxdm_module'
    'concat:easyxdm_module'
  ]

  #BUILD LOADER
  grunt.registerTask 'build_loader', [
    'coffee:loader'
    'hash:payload'
    'replace:loader'
  ]

  grunt.registerTask 'build_plugins', [
    'clean:plugins'
    'coffee:plugins'
    'copy:plugins'
    'hash:plugins'
  ]

  #CREATE DIST ASSETS
  grunt.registerTask 'build_dist', [
    'vendor_assets'
    'build_plugins'
    'build_payload'
    'build_loader'
    'uglify'
  ]

  grunt.registerTask 'vendor_assets', ['copy:easyxdm']

  #ON DEPLOY
  grunt.registerTask 'build', (flavor) ->
    return grunt.task.run ('flavor_build:' + flavor) if flavor?

    grunt.task.run ('flavor_build:' + flavor for flavor in FLAVORS)

  grunt.registerTask 'flavor_build', (flavor)->
    grunt.config.set('current_flavor', flavor)

    grunt.task.run [
      'clean:tmp'
      'copy:ymls'
      'create_env_settings'
      'bower_install'
      'build_dist'
      'compress'
      'copy:tmp'
      'clean:tmp'
    ]

  grunt.registerTask 'set_default_current_flavor', ->
    grunt.config.set('current_flavor', DEFAULT_FLAVOR)

  #DEFAULT TASKS
  grunt.registerTask 'cleanup', ['shell:cleanup']
  grunt.registerTask 'default', [
    'set_default_current_flavor'
    'start_test_server'
    'watch'
  ]

  grunt.registerTask 'test', ['karma:single']

  return
