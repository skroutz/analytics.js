module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    clean: {
      payload: {
        src: ['dist/js/analytics*']
      }
    },

    compress: {
      dist: {
        options: {
          mode: 'gzip'
        },
        expand: true,
        extDot: 'last',
        cwd: 'dist/',
        src: ['**/*'],
        dest: 'dist/'
      }
    },

    hash: {
      options: {
        mapping: 'compiled/assets.json',
        srcBasePath: 'dist/',
        destBasePath: 'dist/',
        hashFunction: function(source, encoding){ // default is md5
          return require('crypto').createHash('sha1').update(source, encoding).digest('hex');
        }
      },
      payload: {
        src: 'dist/js/analytics.js',
        dest: 'dist/js'
      },
    },

    replace: {
      loader: {
        options: {
          patterns: [{
            match: 'payload_hash',
            replacement: function(){
              filename = grunt.file.readJSON('compiled/assets.json')['js/analytics.js']
              return filename.replace('.js','.min.js')
            }
          },
          {
            match: 'base_url',
            replacement: 'http://analytics.local:9000/public'
          }]
        },
        files: [{
          src: 'compiled/loader.js',
          dest: 'dist/loader.js'
        }]
      }
    },

    bump: {
      options: {
        pushTo: 'origin',
      }
    },

    optimize_rjs: {
      analytics: {
        dest: "dist/js/analytics.js"
      }
    },

    karma: {
      options: {
        configFile: 'karma.conf.js',
        browsers: ['PhantomJS'],
      },
      unit: {
        browsers: ['Chrome'],
        logLevel: 'ERROR',
        background: true
      },
      single: {
        logLevel: 'ERROR',
        singleRun: true
      },
    },

    watch: {
      tests:{
        files: [
          'spec/**/*_spec.coffee',
          'spec/**/*.html',
          'spec/**/*.json',
        ],
        tasks: [
          'karma:unit:run',
        ]
      },
      loader:{
        files: [
          'src/loader.coffee',
        ],
        tasks: [
          'clean:payload',
          'build_dist',
        ]
      },
      payload:{
        files: [
          'src/**/*.coffee',
          '!src/loader.coffee',
        ],
        tasks: [
          'karma:unit:run',
          'clean:payload',
          'build_dist',
        ]
      },
    },

    coffee: {
      options: {
        bare: true
      },
      payload: {
        expand: true,
        cwd: 'src',
        src: [
          '**/*.coffee',
          '!loader.coffee'
        ],
        dest: 'compiled/',
        ext: '.js'
      },
      loader: {
        src: [
          'src/loader.coffee'
        ],
        dest: 'compiled/loader.js',
      },
    },

    uglify: {
      options: {
        mangle: false,
        beautify: {
          ascii_only: true
        },
        preserveComments: false,
        report: "min",
        compress: {
          hoist_funs: false,
          loops: false,
          unused: false
        }
      },
      payload: {
        files: [{
          expand: true,
          cwd: 'dist/js',
          extDot: 'last',
          src: [
            '**/*.js',
            '!**/*.min.js',
          ],
          dest: 'dist/js',
          ext: '.min.js'
        }],
      },
      loader: {
        files: {
          'dist/loader.min.js': 'dist/loader.js',
        },
        options: {
          banner: "/*! <%= pkg.name %> v<%= pkg.version %> \n " +
            "(c) 2014, <%= grunt.template.today('yyyy') %> <%= pkg.company %> \n " +
            "<%= pkg.license %> */\n",
        }
      }
    },

    concat: {
      options: {
        separator: ';\n'
      },
      easyxdm_module: {
        src: [
          'tasks/wrappers/easyxdm/intro.js',
          'compiled/vendor/easyXDM.js',
          'tasks/wrappers/easyxdm/outro.js'
        ],
        dest: 'compiled/easyXDM.js'
      }
    },

    bower: {
      install: {
        options:{
          install        : true,
          copy           : false,
          cleanTargetDir : false,
          cleanBowerDir  : false
        }
      }
    },

    shell:{
      build_easyxdm: {
        options: {
          stdout: true
        },
        command: 'cd bower_components/easyxdm/ && ant'
      },
      cleanup:{
        options: {
          stdout: true
        },
        command: 'rm -rf compiled dist'
      }
    },

    copy: {
      easyxdm_module: {
        expand: true,
        cwd: 'bower_components/easyxdm/work',
        src: [
          'easyXDM.js'
        ],
        dest: 'compiled/vendor',
      },
      easyxdm_dist: {
        expand: true,
        cwd: 'bower_components/easyxdm/work',
        src: [
          'easyXDM.min.js'
        ],
        dest: 'dist/js',
      },
    },
  });

  require('load-grunt-tasks')(grunt);
  grunt.loadTasks( "tasks" );

  //TEST TASKS
  grunt.registerTask('start_test_server', ['karma:unit:start']);
  grunt.registerTask('run_tests', ['karma:unit:run']);


  //BOWER TASKS
  grunt.registerTask('bower_install', [
    'bower:install',
    'shell:build_easyxdm'
  ]);


  //BUILD PAYLOAD
  grunt.registerTask('build_payload', [
    'create_easyxdm_module',
    'coffee:payload',
    'optimize_rjs',
  ]);

  grunt.registerTask('create_easyxdm_module', [
    'copy:easyxdm_module',
    'concat:easyxdm_module'
  ]);


  //BUILD LOADER
  grunt.registerTask('build_loader', [
    'coffee:loader',
    'hash:payload',
    'replace:loader'
  ]);


  //CREATE DIST ASSETS
  grunt.registerTask('build_dist', [
    'vendor_assets',
    'build_payload',
    'build_loader',
    'uglify'
  ]);

  grunt.registerTask('vendor_assets', [
    'copy:easyxdm_dist',
  ]);


  //ON DEPLOY
  grunt.registerTask('build', [
    'bower_install',
    'build_dist',
    'compress'
  ]);

  //DEFAULT TASKS
  grunt.registerTask('cleanup', ['shell:cleanup']);
  grunt.registerTask('default', ['start_test_server', 'watch']);
  grunt.registerTask('test', ['karma:single']);
};
