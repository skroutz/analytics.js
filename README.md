# Analytics Client

A short description about the client in a single sentence.

## Installation

To use the script in your page in your footer / header.

```Javascript
<script type="text/javascript">

  var _saq = _saq || [];
  _saq.push(['_setAccount', 'XX-YYY-ZZZ']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = '//analytics.skroutz.gr/analytics.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
   })();
</script>
```

## API

Describe the API.

  * **_setAccount**

    It sets your Account.

    ```Javascript
      _saq.push(['_setAccount', 'XX-YYY-ZZZ']);
    ```

  * **_anotherCall**

## Building

The files inside `dist` folder are the **production assets**. They get created from a `build` script provided.

Make sure you have `node` (and `npm`) installed and made available to your `$PATH`

Then make sure that locally installed npm binaries are included in your `$PATH` by appending
 this line to your `.(bash|zsh)rc`:

```bash
  PATH=$(npm bin):$PATH
```

Finally all you have to do is

```bash
  $ npm run build
```

**That is it!** Once the above command ends, there will be a freshly baked batch of production assets in the `dist` directory.

## Development

For development (provided that you have executed `build` first) you should just execute:

```bash
  $ grunt
```

This starts the default grunt script, which in turn loads the testing server and
then executes a `watch` script.

The `watch` script does the following:

* Runs tests if dev, test or vendor files are changed
* Recompiles production assets if dev or vendor assets are changed

## Testing

For the test to run the `karma` server has to be loaded. There are two options to do that:

* Start the server just for the tests to run once.
* Start the server and keep it open so that tests can be run arbitrarily.

The first option is the *continuous integration* one and can easily be executed by running:

```bash
  $ grunt test
```

The second option is the one used in the development workflow.
First you have to start the server.

```bash
  $ grunt start_test_server
```

The above task is the one that is used internally on the development task:

```bash
  $ grunt
```

So if you have already run the above your server is already up and waiting.

With the server running and waiting for tests you can now run them:

* either from the console via: `karma run`
* or by changing a watched file (if on the development section)

You can also register a browser to the server that will automatically run the tests triggered above.
This way you can easily debug code in a familiar environment.

## Cleaning Up

The are two clean up scripts:

```bash
  $ npm run cleanup
```

This one removes the directories of the downloaded npm and bower packages as well as the directories
of the produced assets (`dist`, `compiled`), thus it performs a **deep cleanup**.

After a **deep cleanup**,

```bash
  $ npm run build
```

must be executed.

The other way is:

```bash
  $ grunt cleanup
```

This one only cleans up the produced asset directories (`dist`, `compiled`), thus it can be seen as a **soft cleanup**.

It is useful in development scenarios, as all the files delete get rebuild by the `watch` scripts.

## Authors

- Bill Trikalinos
- Chrisovalantis Kefalidis

## License

This software is licensed under MIT. For details see LICENSE.txt
