// Karma configuration
module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['requirejs', 'mocha', 'chai-sinon', 'fixture'],

    // list of files / patterns to load in the browser
    files: [
      {
        pattern: 'spec/helpers/**/*.coffee',
      },
      {
        pattern: 'spec/fixtures/**/*',
      },
      {
        pattern: 'spec/**/*_spec.coffee',
        included: false
      },
      {
        pattern: 'src/**/*.coffee',
        included: false
      },
      {
        pattern: 'compiled/vendor/**/*.js',
        included: false
      },
    ],

    // list of files to exclude
    exclude: [],

    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      // In development, change the preprocessor of src/**/*.coffee to ['coffee'] for source maps
      'src/**/*.coffee'  : ['coverage'],
      'spec/**/*.coffee' : ['coffee'],
      '**/*.html'        : ['html2js'],
      '**/*.json'        : ['html2js']
    },

    coffeePreprocessor: {
      // options passed to the coffee compiler
      options: {
        bare: true,
        sourceMap: true
      },
    },

    // test results reporter to use
    // possible values: 'dots', 'progress', 'mocha'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['mocha', 'coverage'],

    // configure the coverage reporter
    coverageReporter: {
      dir: 'spec/coverage',
      useJSExtensionForCoffeeScript: true,
      instrumenters: { ibrik: require('ibrik') },
      instrumenter: { '**/*.coffee': 'ibrik' },
      reporters: [
        { type: 'html', subdir: 'html' },
        { type: 'cobertura', subdir: 'cobertura' }
      ]
    },

    // web server port
    port: 9876,

    // enable / disable colors in the output (reporters and logs)
    colors: true,

    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_DEBUG,

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,

    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['PhantomJS'],

    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false
  });
};
