@not-implemented
Feature: Using a context block

  ***WAITING TO IMPLEMENT THIS UNTIL I HAVE RSPEC WORKING,
  BECAUSE THESE EXAMPLES ARE WAY BETTER IN RSPEC***

  Sometimes there is necessary code around what the user wants to show.
  But including this context just distracts from the relevant piece of code.

  The user can declare this context in the context block. Their code example
  can state that it should be executed in that context, and its body will
  replace the __CODE__ macro in the context.

  This ensures it gets tested with the context, but displayed without it.

  Scenario: Passing test block with a context
    Given the file "lib/user.rb":
    """
    User = Struct.new :name
    """
    Given the file "example.mountain_berry_fields.md":
    """
    <% setup do %>
    $LOAD_PATH.unshift File.expand_path '../lib', __FILE__
    <% end %>

    <% context 'a user named Josh' do %>
    -> name { __CODE__ }.('Josh')
    <% end %>

    Create a user like this:
    ```ruby
    <% test 'create a user', with: :magic_comments, context: 'a user named Josh' do %>
    User.new(name).name # => "Josh"
    <% end %>
    ```
    """
    When I run "mountain_berry_fields example.mountain_berry_fields.md"
    Then it exits with a status of 0
    And I see the file "example.md":
    """


    ```ruby
    User.new(name).name # => "Josh"
    ```
    """



  # Scenario: Failling test block with a context

  # Scenario: Contexts can have contexts
  # Scenario: Setups, contexts, and tests all in one (zomg!)
