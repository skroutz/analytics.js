module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

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
      coffee:{
        files: [
          'src/**/*.coffee',
        ],
        tasks: [
          'karma:unit:run',
          'coffee:compile',
          'optimize_rjs',
          'uglify:payload',
        ]
      },
      vendor:{
        files: [
          'compiled/vendor/**/*.js',
        ],
        tasks: [
          'concat:easyxdm_module',
          'karma:unit:run',
        ]
      },
    },

    coffee: {
      compile: {
        options: {
          bare: true
        },
        expand: true,
        cwd: 'src',
        src: ['**/*.coffee'],
        dest: 'compiled/',
        ext: '.js'
      },
    },

    uglify: {
      payload: {
        files: {
          'dist/js/analytics.min.js': 'dist/js/analytics.js',
        },
        options: {
          banner: "/*! <%= pkg.name %> v<%= pkg.version %> \n " +
            "(c) 2014, <%= grunt.template.today('yyyy') %> <%= pkg.company %> \n " +
            "<%= pkg.license %> */\n",
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


  grunt.registerTask('create_easyxdm_module', [
    'copy:easyxdm_module',
    'concat:easyxdm_module'
  ]);

  grunt.registerTask('install_bower_deps', [
    'bower:install',
    'shell:build_easyxdm'
  ]);

  grunt.registerTask('start_test_server', ['karma:unit:start']);
  grunt.registerTask('run_tests', ['karma:unit:run']);

  grunt.registerTask('build', [
    'install_bower_deps',
    'create_easyxdm_module',
    'copy:easyxdm_dist',
    'coffee:compile',
    'optimize_rjs',
    'uglify',
    'compress'
  ]);
  grunt.registerTask('cleanup', ['shell:cleanup']);
  grunt.registerTask('default', ['start_test_server', 'watch']);
  grunt.registerTask('test', ['karma:single']);
};
