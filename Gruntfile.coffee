module.exports = (grunt) ->
  ENV = grunt.option("env") or process.env.GRUNT_ENV or 'development'

  grunt.initConfig
    env: ENV
    pkg: grunt.file.readJSON('package.json')
    clean:
      payload:
        src: ['dist/js/payload*']

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
        cwd: 'dist/'
        src: ['**/*.js']
        dest: 'dist/'

    hash:
      options:
        mapping: 'compiled/assets.json'
        srcBasePath: 'dist/'
        destBasePath: 'dist/'
        hashFunction: (source, encoding) -> # default is md5
          require('crypto').createHash('sha1').update(source, encoding).digest 'hex'

      payload:
        src: 'dist/js/payload.js'
        dest: 'dist/js'

    replace:
      settings:
        options:
          patterns: [json: (done) ->
            done grunt.config('env_settings')
            return
          ]

        files: [
          src: 'src/settings.coffee.sample'
          dest: 'src/settings.coffee'
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
              match: 'base'
              replacement: ->
                grunt.config('env_settings').base
            }
          ]

        files: [
          src: 'compiled/loader.js'
          dest: 'dist/analytics.js'
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

    coffee:
      options:
        bare: true

      payload:
        expand: true
        cwd: 'src'
        src: [
          '**/*.coffee'
          '!loader.coffee'
        ]
        dest: 'compiled/'
        ext: '.js'

      loader:
        src: ['src/loader.coffee']
        dest: 'compiled/loader.js'

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
          cwd: 'dist/js'
          extDot: 'last'
          src: [
            '**/*.js'
            '!**/*.min.js'
          ]
          dest: 'dist/js'
          ext: '.min.js'
        ]

      loader:
        files:
          'dist/analytics.min.js': 'dist/analytics.js'

        options:
          banner: '/*! <%= pkg.name %> v<%= pkg.version %> \n ' +
            '(c) <%= grunt.template.today("yyyy") %> <%= pkg.company %> \n ' +
            '<%= pkg.license %> */\n'

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
        dest: 'dist/js/payload.js'

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

        command: 'rm -rf compiled dist src/settings.coffee'

    copy:
      ymls:
        expand: true
        cwd: 'config/settings'
        src: ['*.yml.sample']
        dest: 'config/settings'
        ext: '.yml'

      easyxdm_module:
        expand: true
        cwd: 'vendor'
        src: ['easyXDM.js']
        dest: 'compiled/vendor'

      easyxdm_dist:
        expand: true
        cwd: 'vendor'
        src: ['easyXDM.min.js']
        dest: 'dist/js'

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

  #CREATE DIST ASSETS
  grunt.registerTask 'build_dist', [
    'vendor_assets'
    'build_payload'
    'build_loader'
    'uglify'
  ]
  grunt.registerTask 'vendor_assets', ['copy:easyxdm_dist']

  #ON DEPLOY
  grunt.registerTask 'build', [
    'create_env_settings'
    'bower_install'
    'build_dist'
    'compress'
  ]

  #DEFAULT TASKS
  grunt.registerTask 'cleanup', ['shell:cleanup']
  grunt.registerTask 'default', [
    'start_test_server'
    'watch'
  ]
  grunt.registerTask 'test', [
    'copy:ymls'
    'create_env_settings'
    'karma:single'
  ]

  return