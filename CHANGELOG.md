# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

## [0.1.0] - 2016-01-15

### Added

* Runnable Mixin enhances modules with command execution capabilities.

### Changed

* Tests run after the distribution is built to ensure buildability.

* ActionsManager is instantiated with an acquired Session.

### Removed

* Project no longer requires [ant](http://ant.apache.org/) to be built
  and [easyXDM](https://github.com/oyvindkinsey/easyXDM) is vendored.
