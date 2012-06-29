Feature: Using a context block

  Sometimes there is necessary code around what the user wants to show.
  But including this context just distracts from the relevant piece of code.

  The user can declare this context in the context block. Their code example
  can state that it should be executed in that context, and its body will
  replace the __CODE__ macro in the context.

  This ensures it gets tested with the context, but displayed without it.

  Scenario: Passing test block with a context
    Given the file "example.mountain_berry_fields.md":
    """
    <% context 'user spec' do %>
      User = Struct.new :name
      describe User do
        it 'does usery things' do
          __CODE__
        end
      end
    <% end %>

    Users know their names:
    ```ruby
    <% test 'users know their name', with: :rspec, context: 'user spec' do %>
    User.new('Josh').name.should == 'Josh'
    <% end %>
    ```
    """
    When I run "mountain_berry_fields example.mountain_berry_fields.md"
    Then it exits with a status of 0
    And I see the file "example.md":
    """

    Users know their names:
    ```ruby
    User.new('Josh').name.should == 'Josh'
    ```
    """


  Scenario: Passing test block with a context
    Given the file "example.mountain_berry_fields.md":
    """
    <% context 'user spec' do %>
      User = Struct.new :name
      describe User do
        it 'does usery things' do
          __CODE__
        end
      end
    <% end %>

    Users know their names:
    ```ruby
    <% test 'Users know their names', with: :rspec, context: 'user spec' do %>
      User.new('Josh').name.should == 'Not Josh'
    <% end %>
    ```
    """
    When I run "mountain_berry_fields example.mountain_berry_fields.md"
    Then it exits with a status of 1, and a stderr of:
    """
    FAILURE: Users know their names
    User does usery things:
      expected: "Not Josh"
         got: "Josh" (using ==)

    backtrace:
      /spec.rb:4:in `block (2 levels) in <top (required)>'
    """
    And I do not see the file "example.md"
