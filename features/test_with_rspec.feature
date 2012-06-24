Feature: Testing with :rspec

  @wip
  Scenario: Passing RSpec
    Given the file "Readme.mountain_berry_fields.md":
    """
    # Whatever


        <% test 'My RSpec example', with: :rspec do %>
        User = Struct.new :name

        describe User do
          let(:username) { 'some name' }
          it 'has a name' do
            User.new(username).name.should == username
          end
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


        User = Struct.new :name

        describe User do
          let(:username) { 'some name' }
          it 'has a name' do
            User.new(username).name.should == username
          end
        end

    ya see?
    """

  @not-implemented
  Scenario: Failing RSpec
    Given the file "Readme.mountain_berry_fields.md":
    """
    # Whatever


        <% test 'My RSpec example', with: :rspec do %>
        User = Struct.new :name

        describe User do
          let(:username) { 'some name' }
          it 'has a name' do
            User.new(username).name.should_not == username
          end
        end
        <% end %>

    ya see?
    """
    When I run "mountain_berry_fields Readme.mountain_berry_fields.md"
    Then it exits with a status of 1, and a stderr of:
    """
    FAILURE: My RSpec example
    Expected: *** NOT SURE YET ***
    Actual:   *** NOT SURE YET ***
    """
    And I do not see the file "Readme.md"
