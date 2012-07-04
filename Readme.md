# MountainBerryFields

Tests code in readme files, generates the readme if they are successful.

## Usage

When you have a file with embedded code samples, rename it to include a .mountain_berry_fields suffix.
Then wrap test statements around the code samples. I've written two testing strategies: rspec and magic_comments.
You can create your own without much effort.


### Code samples with magic comments

You will need to
`$ gem install mountain_berry_fields-magic_comments`
for this to work.

The file `Readme.mountain_berry_fields.md`

    # MyLibName

        <% test 'an example', with: :magic_comments do %>
        MyLibName.new('some data').result # => "some cool result"
        <% end %>

Run `$ mountain_berry_fields Readme.mountain_berry_fields.md` and it will generate `Readme.md`

    # MyLibName

        MyLibName.new('some data').result # => "some cool result"

If at some point, you change your lib to not do that cool thing, then it will not generate the file.  Instead it will give you an error message:

    FAILURE: an example
    Expected: MyLibName.new('some data').result # => "some cool result"
    Actual:   MyLibName.new('some data').result # => "some unexpected result"

Now you can be confident that your code is still legit.

### Code samples with RSpec

You will need to
`$ gem install mountain_berry_fields-rspec`
for this to work.

The file `Readme.mountain_berry_fields.md`

    # MyLibName

        <% test 'an example', with: :rspec do %>
        describe MyLibName do
          it 'does what I made it do' do
            described_class.new('some data').result.should == 'some cool result'
          end
        end
        <% end %>

Run `$ mountain_berry_fields Readme.mountain_berry_fields.md` to generate `Readme.md`

    # MyLibName

        describe MyLibName do
          it 'does what I made it do' do
            described_class.new('some data').result.should == 'some cool result'
          end
        end

And an rspec error:

    FAILURE: an example
    MyLibName does what I made it do:
      expected: "some cool result"
         got: "some unexpected result" (using ==)

    backtrace:
      /spec.rb:8:in `block (2 levels) in <top (required)>'

### Setup blocks

You may need to do something to setup the environment for the tests (e.g. load the lib your examples are using)
Do that with a setup block:

    <% setup do %>
    $LOAD_PATH.unshift File.expand_path '../lib', __FILE__
    require 'my_lib_name'
    <% end %>

This will not show up anywhere in the generated file. It will be prepended before each code sample when running tests.

### Context blocks

Some examples may need to be executed within a context. Use a context block for that.
Use the `__CODE__` macro to indicate where the code should go relative to this context.

    <% context 'a user named Carlita' do %>
    user = Struct.new(:name).new 'Carlita'
    __CODE__
    <% end %>

    <% test 'users have a name', context: 'a user named Carlita', with: :magic_comments do %>
    user.name # => "Carlita"
    <% end %>

Context blocks can, themselves, be rendered into a context `<% context 'current', context: "my context's context" do %>`

### Rake Task

If you want to add this as part of your build, there is a rake task:

```ruby
require 'mountain_berry_fields/rake_task'
MountainBerryFields::RakeTask.new(:mbf, 'Readme.mountain_berry_fields.md')
```

which will allow you to say `$ rake mbf`. You could then add it to your default task with
`task default: :mbf`, or have whatever task runs your tests just execute it at the end.

### Creating your own test strategy

I've written the magic_comments and rspec strategies. You can write your own that do
whatever interesting thing you've thought of.

If you want it to be a gem, then the strategy needs to be in the file
`mountain_berry_fields/test/your_strategy.rb`. Mountain Berry Fields
will automatically load files at these paths. If your strategy is not a gem,
and you want to manage loading the file containing its code, then you can ignore this.

Any strategy can be made accessible to the .mountain_berry_fields file like this:
`MountainBerryFields::Test::Strategy.register :your_strategy, YourStrategy`
And then accessed by `<% test 'testname', with: :your_strategy do %>`

Strategies will be initialized with the code to test, and are expected to
implement `#pass?` which returns a boolean of whether the code passes according
to that strategy, and `#failure_message` which will used to describe why the spec
failed to users.

### About the name

I am often asked why I picked this name. I make things like this for me, because I have decided that they have value.
I felt the need to remind myself of that so I chose a name that no one would realisitcally choose,
to remind myself of the fact that no one could tell me I couldn't choose it.

The phrase "Mountain berry fields" is a lyric in a [song](http://www.myspace.com/joyelectric/music/songs/birds-will-sing-forever-christian-songs-album-version-34576758) that makes me happy.

If it bothers you: `$ alias mbf=mountain_berry_fields`

## TODO
* add links to examples where I do all of the above
  - edit dependencies to have mbf as dev dep
  - add rake tasks
  - push to github
* Fix dependencies such that they use Rubygems instead of Gemfiles
  - edit gemfiles and gemspecs
* Fix all readmes and gem descriptions
* push all 3 gems to github
* set it up on Travis

## Features to add for v2

Note that my use cases are to be able to test Deject and Surrogate,
which this currently does quite nicely. As a result, I have no imminent
need for any of these features, and so they are not a priority for me.
If you have a need for them (or for other features), let me know and that
will cause it to be a much higher priority for me. Alternatively,
pull requests that add them, fix bugs, or generally make it better,
are more than welcome.

* contexts should be lazy (can define context after a block that uses it)
* should be able to pass options to the initializer
* enable the test strategy to decide what should be returned
* support for multiple input files
* FLAGS:
* * -o set up input files so they don't need a .mountain_berry_fields in their name (output filename is provided, so input filename needs no naming conventions)
* * -s list all known test strategies
* * -v version
* * -c check syntax (no output, thus also no input filename restrictions)
* * -e flag for outputting erb (e.g. when it gives weird ass _buf error)
* * -h to display this menu
* * ?? to display the code that was passed to the test, along with the failure
