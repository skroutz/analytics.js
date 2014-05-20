module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    optimize_rjs: {
      analytics: {
        dest: "dist/analytics.js"
      }
    },


    watch: {
      coffee:{
        files: [
          'src/**/*.coffee',
        ],
        tasks: [
          'coffee:compile',
          'optimize_rjs',
          'uglify'
        ]
      },
      vendor:{
        files: [
          'compiled/vendor/**/*.js',
        ],
        tasks: [
          'concat:easyxdm_module',
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
          "dist/analytics.min.js": [ "dist/analytics.js" ]
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
          'easyXDM.debug.js',
          'easyXDM.min.js',
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
        dest: 'dist',
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

  grunt.registerTask('build', [
    'install_bower_deps',
    'create_easyxdm_module',
    'copy:easyxdm_dist',
    'coffee:compile',
    'optimize_rjs',
    'uglify'
  ]);
  grunt.registerTask('cleanup', ['shell:cleanup']);
  grunt.registerTask('default', ['watch']);
  grunt.registerTask('test', ['coffee:compile_test', 'mocha']);
};
