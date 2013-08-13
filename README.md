# Stitch Plus

A CommonJS JavaScript package management solution powered by [Stitch-rb](https://github.com/maccman/stitch-rb). Stitch Plus adds some nice features including:

- Optionally [uglify](https://github.com/lautis/uglifier) javascript output.
- Easily fingerprint the file name.
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
require 'stitch-plus'

options = {
  dependencies: ['javascripts/dependencies'],
  paths: ['javascripts/modules'],
  write: 'javascripts/app.js',
  fingerprint: true
}

stitch = StitchPlus.new(options)

stitch.compile
# > Stitch created javascripts/app-f1408932717b4b16eb97969d34961213.js

# You an temporarily override an option

stitch.compile({fingerprint: false})
# > Stitch deleted javascripts/app-f1408932717b4b16eb97969d34961213.js
# > Stitch created javascripts/app.js

# Or permanently change an option

stitch.set_options({write: false})
js = stitch.compile
# No output. Compiled javascript is returned as a string. 

```

## Configuration

This guard has these configurations.

| Config           | Description                                                                | Default     |
|:-----------------|:---------------------------------------------------------------------------|:------------|
| `dependencies`   | Array of files/directories to be added first as global javascripts         | nil         |
| `paths`          | Array of directories where javascripts will be wrapped as CommonJS modules | nil         |
| `write`          | A path to write the compiled javascript                                    | 'all.js'    |
| `fingerprint`    | Add a fingerprint to the file name for super cache busting power           | false       |
| `cleanup`        | Automatically remove previously compiled files                             | true        |
| `uglify`         | Smush javascript using the Uglifier gem                                    | false       |
| `uglify_options` | Options for the Uglifier gem. See the [Uglifier docs](https://github.com/lautis/uglifier#usage) for details. | {}       |


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

