Feature: Testing with :rspec

  Scenario: Passing RSpec
    Given the file "Readme.mountain_berry_fields.md":
    """
    # Whatever


        <% test 'My RSpec example', with: :rspec do %>
        describe 'an example' do
          it('passes') { true.should be_true }
        end
        <% end %>

    ya see?
    """
    When I run "mountain_berry_fields Readme.mountain_berry_fields.md"
    Then it prints nothing to stdout
    And it prints nothing to stderr
    And it exits with a status of 0
    And I see the file "Readme.md":
    """
    # Whatever


        describe 'an example' do
          it('passes') { true.should be_true }
        end

    ya see?
    """

  Scenario: Failing RSpec
    Given the file "Readme.mountain_berry_fields.md":
    """
    # Whatever


        <% test 'My RSpec example', with: :rspec do %>
        describe 'an example' do
          it('fails 1') { true.should be_false, 'failure message 1' }
          it('fails 2') { true.should be_false, 'failure message 2' }
        end
        <% end %>

    ya see?
    """
    When I run "mountain_berry_fields Readme.mountain_berry_fields.md"
    Then it exits with a status of 1, and a stderr of:
    """
    FAILURE: My RSpec example
    an example fails 1:
      failure message 1

    backtrace:
      /spec.rb:2:in `block (2 levels) in <top (required)>'
    """
    And I do not see the file "Readme.md"


  Scenario: Invalid example
    Given the file "Readme.mountain_berry_fields.md":
    """
    # Whatever


        <% test 'My RSpec example', with: :rspec do %>
        describe 'an example' do
          it('is invalid syntax') { }}}}
        end
        <% end %>

    ya see?
    """
    When I run "mountain_berry_fields Readme.mountain_berry_fields.md"
    Then it exits with a status of 1, and a stderr of:
    """
    FAILURE: My RSpec example
    -:2: syntax error, unexpected '}', expecting keyword_end
          it('is invalid syntax') { }}}}
                                      ^
    """
    And I do not see the file "Readme.md"
