# ReadmeTester

Tests code in readme files, generates the readme if they are successful.

## TODO

* uh... make this a real readme
* rename to mountain berry fields
* should readme_tester shouldn't talk directly to file interface? Or should it be more abstract?
* readme_tester returning 1 and 0 is lame, make it less "I'm a command line app on Unix" by returning true/false
* erb shouldn't render the fuckign code in a visible block, there should just be commands, they should always be invisible Then the evaluator can decide what it wants to make visible and invisible by appending to the document
* add support for real tests (xmpfilter and rspec)
* add support for contexts
* add support for file rendering and line numbers
* rename strategy to something not so fucking snooty

## Installation

Add this line to your application's Gemfile:

    gem 'readme_tester'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install readme_tester

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
