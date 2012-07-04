<% load "readme_helper.rb" %>
# ReadmeTester

Tests code in readme files, generates the readme if they are successful.

## Usage

When you have a file with embedded code samples, rename it to include a .mountain_berry_fields suffix.
Then wrap test statements around the code samples. I've written two testing strategies: rspec and magic_comments.
You can create your own without much effort.


### Code samples with magic comments

You will need to
`<% test('dep magic_comments', with: :install_dep) { %>$ gem install mountain_berry_fields-magic_comments<% } %>`
for this to work.

<% test 'show magic comments', with: :mbf_example do %>
The file `Readme.mountain_berry_fields.md`

    # MyLibName

        <%% test 'an example', with: :magic_comments do %>
        MyLibName.new('some data').result # => "some cool result"
        <%% end %>

Run `$ mountain_berry_fields Readme.mountain_berry_fields.md` and it will generate `Readme.md`

    # MyLibName

        MyLibName.new('some data').result # => "some cool result"

If at some point, you change your lib to not do that cool thing, then it will not generate the file.  Instead it will give you an error message:

    FAILURE: an example
    Expected: MyLibName.new('some data').result # => "some cool result"
    Actual:   MyLibName.new('some data').result # => "some unexpected result"
<% end %>

Now you can be confident that your code is still legit.

### Code samples with RSpec

You will need to
`<% test('dep rspec', with: :install_dep) { %>$ gem install mountain_berry_fields-rspec<% } %>`
for this to work.

<% test 'show rspec', with: :mbf_example do %>
The file `Readme.mountain_berry_fields.md`

    # MyLibName

        <%% test 'an example', with: :rspec do %>
        describe MyLibName do
          it 'does what I made it do' do
            described_class.new('some data').result.should == 'some cool result'
          end
        end
        <%% end %>

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
<% end %>

### Setup blocks

You may need to do something to setup the environment for the tests (e.g. load the lib your examples are using)
Do that with a setup block:

<% test 'setup blocks', with: :requires_lib do %>
    <%% setup do %>
    $LOAD_PATH.unshift File.expand_path '../lib', __FILE__
    require 'my_lib_name'
    <%% end %>
<% end %>

This will not show up anywhere in the generated file. It will be prepended before each code sample when running tests.

