# Stitch Plus

A CommonJS JavaScript package management solution powered by [Stitch-rb](https://github.com/maccman/stitch-rb). Stitch Plus adds some nice features including:

- Optionally [uglify](https://github.com/lautis/uglifier) javascript output.
- Each build is fingerprinted with a comment to avoid unnecessary compiling.
- Easily fingerprint the file name for cache busting power.
- Remove previously generated files with each compile.
- Designed to integrate with Guard via [guard-stitch-plus](https://github.com/imathis/guard-stitch-plus).

## Installation

Add this line to your application's Gemfile:

    gem 'stitch-plus'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stitch-plus

## Usage

```ruby
# options can be a hash or a path to a yaml file
s = StitchPlus.new(options)

# Compile  javascript 
s.compile

# Return the compiled javascript instead of writing to disk
s.build

# Get compiled filename
s.output_file #> javascripts/app-f1408932717b4b16eb97969d34961213.js

# Get a list of javascripts to be compiled, in order
s.all_files

# Get the fingerprint to be used
s.file_fingerprint

# Permanently modify the config options
s.set_options({output: 'foo.js'})

```

All methods will accept an options hash which will temporarily override
previous options options, for example:


```
s.build({fingerprint: 'false'})
```

This will disable fingerprinting of the filename temporarily and write to app.js instead of the fingerprinted filename.


## Configuration

You can configure StichPlus as like this.

| Config           | Description                                                                | Default     |
|:-----------------|:---------------------------------------------------------------------------|:------------|
| `dependencies`   | Array of files/directories to be added first as global javascripts         | nil         |
| `paths`          | Array of directories where javascripts will be wrapped as CommonJS modules | nil         |
| `output`         | A path to write the compiled javascript                                    | 'all.js'    |
| `fingerprint`    | Add a fingerprint to the file name for super cache busting power           | false       |
| `cleanup`        | Automatically remove previously compiled files                             | true        |
| `uglify`         | Smash javascript using the Uglifier gem                                    | false       |
| `uglify_options` | Options for the Uglifier gem. See the [Uglifier docs](https://github.com/lautis/uglifier#usage) for details. | {}       |

### Reading configuration from a file

Stitch can also read configurations from a YAML file. For example, you could
create a `stitch.yml` containing the following:

```yaml
stitch:
  dependencies: ['javascripts/dependencies']
  paths: ['javascripts/modules']
  output: 'javascripts/app.js'
  fingerprint: true
```

Then you could call stitch like this:

```ruby
require 'stitch-plus'

StitchPlus.new('stitch.yml').compile
```

### Regarding "Dependencies"

When using `dependencies`, order matters, directories are globbed, and files will only be included once for each listing. For example, if you are working on something with jQuery and Backbone.js, your dependencies might look like this:

```
dependencies: ['js/deps/jquery.js', 'js/deps/underscore.js', 'js/deps/backbone.js', 'js/deps']
```

This will add—in order—jQuery, Underscore.js and Backbone.js, followed by any other files in the `js/deps` directory.


### Regarding "Paths"

Javascrpts which are included as paths will be added to the output javascript, after any dependencies, and will be wrapped up as CommonJS modules. Stitch will add its
own require function which allows these scripts to be loaded as modules, then it will write each script as a member of a hash, with the file path as the key. For
example.

A the script `js/deps/test-module.js` containing the following:

```js
var Test = {
  init: function(){
    console.log('initialized!');
  }
}

module.exports = Test;
```

will be added to the hash and surrounded with the following:

```js
"test-module": function(exports, require, module) {
  // the original script
}
```

This allows other scripts to load the module with

```js
test = require('test-module')
test.init() // logs 'initialized!' to the console
```

Author's note: I feel like `paths` is a stupid name for this option, but I have left it as-is to be consistent with Stitch.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (c) 2013 Brandon Mathis

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

