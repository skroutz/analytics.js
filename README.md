# Analytics Client [![Build Status](https://travis-ci.org/skroutz/analytics.js.svg?branch=master)](https://travis-ci.org/skroutz/analytics.js)

Minimal cross-domain user tracking library to measure user interaction
across Skroutz and partners' websites or web applications.

## How To Use

[Read the Documentation](http://developer.skroutz.gr/analytics/)

## Development

## Install Dependencies

### Using Docker

Install [docker](https://docs.docker.com/engine/installation/),
[docker-compose](https://docs.docker.com/compose/install/).

Prefix any of the available commands with `docker-compose run builder
<command>`.

> Any changes made to the code locally will be reflected inside the
> container.

Examples:

#### Run the tests

```shell
docker-compose run builder yarn run test
```

**NOTE**: If you get an error such as `[launcher]: Cannot start PhantomJS`,
you should run
```
docker-compose run builder yarn install
```
in order to install the correct binary for [`phantomjs`](https://github.com/Medium/phantomjs).

#### Start a shell

```shell
docker-compose run builder bash
```

### Installing platform dependencies locally

First, install [`Node.js`](http://nodejs.org/) and its package
manager, [`npm`](https://github.com/npm/npm) (`npm` comes by default
with `node` now).

Once you have npm installed, run the command bellow to install
[`yarn`](https://github.com/yarnpkg/yarn):

```bash
$ npm install --global yarn
```

Finally, install project dependencies:

```bash
$ yarn install
```

## Environments

You have two options to invoke a specific environment:

 1. Prepend `GRUNT_ENV=desired_environment` to any `yarn` or `grunt`
    command. For example:

    ```bash
    $ GRUNT_ENV=production yarn run build
    ```

 2. Append `--env=some_environment` to any `grunt` command. For
    example:

    ```bash
    $ yarn grunt create_env_settings -- --env=production
    ```

> By default the project runs in `development` environment.

The available *environments* are:

 - development (**default**)
 - testing
 - production

**`src/settings.coffee`**

The `src/settings.coffee` file gets created according to the
environment settings. The file gets created dynamically by the
following `grunt` task:

```bash
$ yarn grunt create_env_settings
```

## Build

Analytics Client supports deployment under different sites
(a.k.a. flavors in Skroutz speak) with different parameters
configured.

For example, if you want to deploy for flavor `skroutz`, where
`skroutz.gr` is the domain, then you should specify that flavor
in `config/settings/flavors.yml`:

```
- skroutz
```

and then configure `config/settings/production.yml` as follows:

```
skroutz:
  analytics_base_url: "https://analytics.skroutz.gr"
  application_base_url: "https://www.skroutz.gr"
```

You can build the project with the command:

```bash
$ yarn run build
```

Once the build process is successfully completed you should end up
with a new `dist` directory created at the root of the project. Under
`dist`, there should be one directory for each of the flavors
specified in `config/settings/flavors.yml`.

So, the contents of the `dist` directory should look like this:

```bash
# dist directory
└── skroutz
    ├── analytics.js
    ├── analytics.js.gz
    ├── analytics.min.js
    ├── analytics.min.js.gz
    └── js
        ├── easyXDM.min.js
        ├── easyXDM.min.js.gz
        ├── payload.3175ee7a.js
        ├── payload.3175ee7a.js.gz
        ├── payload.3175ee7a.min.js
        ├── payload.3175ee7a.min.js.gz
        ├── payload.js
        ├── payload.js.gz
        ├── payload.min.js
        ├── payload.min.js.gz
        └── plugins
            ├── order_stash.3c2ba10f.js
            ├── order_stash.3c2ba10f.js.gz
            ├── order_stash.3c2ba10f.min.js
            ├── order_stash.3c2ba10f.min.js.gz
            ├── order_stash.js
            ├── order_stash.js.gz
            ├── order_stash.min.js
            └── order_stash.min.js.gz
```

## Watch and rebuild changes

In development you don't have to constantly run the build command for
any change you perform in the sources. You may just run:

```bash
$ yarn run dev
```

This executes the *default* `grunt` task that:

- starts the test server
- watches for file changes and
    - runs all tests
    - recompiles assets

## Test

Tests run with the help of [`karma`](http://karma-runner.github.io/)
test runner.

You can run all tests with:

```bash
$ yarn run test
```

> *If you wish to run tests continuously check the Development
> section.*

## Clean Up

#### Deep Cleanup
You can perform a project **deep cleanup** with:

```bash
$ yarn run cleanup
```

The above command will:

 -  remove local `node modules`
 -  delete `dist` directory
 -  delete `compiled` directory
 -  delete `src/settings.coffee` file
 -  delete `src/plugins_settings.coffee` file

> *After a deep cleanup you have to install again the project
> dependencies. Please check the Installation section.*

#### Soft Cleanup
You can perform a **soft cleanup** with:

```bash
$ yarn grunt cleanup
```

The above command is useful when in development and it will just:

 -  delete `dist` directory
 -  delete `compiled` directory
 -  delete `src/settings.coffee` file
 -  delete `src/plugins_settings.coffee` file

## Authors

- Kostas Diamantis (*[kosdiamantis](https://github.com/kosdiamantis)*)
- Dimitris Karteris (*[dkart](https://github.com/dkart)*)
- Harris Kokkinos (*[harrisred](https://github.com/harrisred)*)

**Alumni**

- Bill Trikalinos (*[billtrik](https://github.com/billtrik)*)
- Chrisovalantis Kefalidis (*[cvkef](https://github.com/cvkef)*)
- Fotos Georgiadis (*[fotos](https://github.com/fotos)*)
- Dimitrios Zorbas (*[Zorbash](https://github.com/Zorbash)*)

## License

This software is released under the MIT License. For more details read
[this](https://github.com/skroutz/analytics.js/blob/master/LICENSE.txt).
