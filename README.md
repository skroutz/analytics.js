# Analytics Client [![Build Status](https://travis-ci.org/skroutz/analytics.js.svg?branch=master)](https://travis-ci.org/skroutz/analytics.js)

Minimal cross-domain user tracking library to measure user interaction across Skroutz and partners' websites or web applications.

## How To Use

### Tracking Code Quick Installation

Add the following JavaScript snippet into your website template page. You may paste it just before closing either `<head>` or `<body>` section.

```javascript
<!-- [start] Skroutz Analytics -->
<script>
  (function(a,b,c,d,e,f,g){a[e]= a[e] || function(){
    (a[e].q = a[e].q || []).push(arguments);};f=b.createElement(c);f.async=true;
    f.src=d;g=b.getElementsByTagName(c)[0];g.parentNode.insertBefore(f,g);
  })(window,document,'script','https://analytics.skroutz.gr','sa');
  
  sa('settings', 'setAccount', 'SA-XXXX-Y');
  sa('site', 'sendPageView');
</script>
<!-- [end] Skroutz Analytics -->
```

### API Quick Reference

#### Settings

  * **setAccount**

    Sets the tracker object to your Account ID.

    ```javascript
    sa.push('settings', 'setAccount', 'SA-XXXX-Y');
    ```

  * **setCallback**
  
    Invokes a function after all data have been reported.
    
    ```javascript
    sa.push('settings', 'setCallback', doSomethingAfter);
    ```
  
  * **redirectTo**
  
    Redirects to a url after all data have been reported and callbacks (if any set) have been executed.
    
    ```javascript
    sa.push('settings', 'redirectTo', 'http://www.example.com/');
    ```

#### Yogurt

  * **productClick**

    Sends a product click for the specified product and shop.

    ```javascript
    sa.push('yogurt', 'productClick', {
      'product_id': '15400722',  // Product ID as knonwn at yogurt. Required.
      'shop_product_id': '752',  // Shop Product ID as known at merchant. Required.
      'shop_id': '2032'          // Shop ID. Required.
    });
    ```

#### Site

  * **sendPageView**

    Sends a page view for the current page. 
    > *This action is automatically generated if no other actions are defined.*

    ```javascript
    sa.push('site', 'sendPageView');
    ```

#### Ecommerce

  * **addOrder**

    Creates a new shopping cart object.

    ```javascript
    sa.push('ecommerce', 'addOrder', {
      'order_id': '123456',  // Order ID. Required.
      'revenue': '120.99',   // Grand Total.
      'shipping': '5.45',    // Total Shipping Cost.
      'tax': '10.50'         // Total Tax.
    });
    ```
  
  * **addItem**

    Adds a new item to the shopping cart object.

    ```javascript
    sa.push('ecommerce', 'addItem', {
      'order_id': '123456',  // Order ID. Required.
      'product_id': '987',   // Product ID. Required.
      'price': '10.50',      // Price per Unit. Required.
      'quantity': '4'        // Quantity of Items. Required.
    });
    ```

---

## Installation

First, install [`Node.js`](http://nodejs.org/) and its package manager, [`npm`](https://github.com/npm/npm) (`npm` comes by default with `node` now).

Configure `npm` and make available locally installed binaries to your `$PATH`. To do so, just append the following line to your `.{bash|zsh}rc`:

```bash
# .{bash|zsh}rc file
export PATH=$(npm bin):$PATH
```

Finally, install project dependencies:

```bash
$ npm install && grunt bower
```

---
## Environments

You have two options to invoke a specific environment:

 1. Prepend `GRUNT_ENV=desired_environment` to any `npm` or `grunt` command. For example:
    ```bash
    $ GRUNT_ENV=production npm run build
    ```

 2. Append `--env=some_environment` to any `grunt` command. For example:
    ```bash
    $ grunt create_env_settings --env=production
    ```

> By default the project run in `development` environment.

The available *environment* are:

 - development (**default**)
 - staging
 - production

**`src/settings.coffee`**
The `src/settings.coffee` file gets created according to the environment settings. The file gets created dynamically by the following `grunt` task:

```bash
$ grunt create_env_settings
```

---

## Build

You can build the project with the command:

```bash
$ npm run build
```

Once the build process is successfully completed you should end up with a new `dist` directory created at the root of the project. 

The contents of the `dist` directory should look like this:

```bash
# dist directory
|- js/
    |- easyXDM.min.js
    |- payload.1A2B3C4D.js
    |- payload.1A2B3C4D.min.js
    |- payload.js
    |- payload.min.js
|- analytics.js
|- analytics.min.js
```


---

## Development

For development, you may just run:

```bash
$ grunt
```

This executes the *default* `grunt` task that:

- starts the test server
- watches for file changes and
    - runs all tests
    - recompiles assets

---

## Test

Tests run with the help of [`karma`](http://karma-runner.github.io/) test runner.

You can run all tests with:

```bash
$ npm run test
```

> *If you wish to run tests continuously check the Development section.*

## Clean Up

#### Deep Cleanup
You can perform a project **deep cleanup** with:

```bash
$ npm run cleanup
```

The above command will:

 -  remove local `node modules`
 -  remove local `bower components`
 -  delete `dist` directory
 -  delete `compiled` directory
 -  delete `src/settings.coffee` file

> *After a deep cleanup you have to install again the project dependencies. Please check the Installation section.*

#### Soft Cleanup
You can perform a **soft cleanup** with:

```bash
$ grunt cleanup
```

The above command is useful when in development and it will just:

 -  delete `dist` directory
 -  delete `compiled` directory
 -  delete `src/settings.coffee` file

---

## Authors

- Bill Trikalinos (*[billtrik](https://github.com/billtrik)*)
- Chrisovalantis Kefalidis (*[cvkef](https://github.com/cvkef)*)
- Fotos Georgiadis (*[fotos](https://github.com/fotos)*)
- Dimitrios Zorbas (*[Zorbash](https://github.com/Zorbash)*)

---

## License

This software is released under the MIT License. For more details read [this](https://github.com/skroutz/analytics.js/blob/master/LICENSE.txt).
