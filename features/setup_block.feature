Feature: Using a setup block

  Sometimes the user needs to setup the environment.
  Rather than forcing the user to provide this setup in the
  code block, which is visible, allow them to provide a
  setup block, which will be executed before each block of code.

  The current directory is set to the directory containing the
  mountain_berry_field file, so file operations can be performed
  relative to that directory.

  Scenario: setup blocks are evaluated before each test block
    Given the file "addition_helpers.rb"
    """
    def plus_five(n)
      n + 5
    end
    """
    And the file "example.mountain_berry_fields.md"
    """
    <% setup do %>
    require "./addition_helpers"
    <% end %>

    <% test 'I see the method', with: :magic_comments do %>
    plus_five 2 # => 7
    <% end %>
    """
    When I run "mountain_berry_fields example.mountain_berry_fields.md"
    Then it exits with a status of 0
    And I see the file "example.md"
    """

    plus_five 2 # => 7
    """

