Feature: Using the :magic_comments strategy

  Scenario: Passing magic comments
    Given the file "Readme.mountain_berry_fields.md"
    """
    # Whatever

        <% test 'basic addition', with: :magic_comments do %>
        1 + 1 # => 2
        <% end %>

    More shit here
    """
    When I run "mountain_berry_fields Readme.mountain_berry_fields.md"
    Then it exits with a status of 0
    And I see the file "Readme.md"
    """
    # Whatever

        1 + 1 # => 2

    More shit here
    """


  Scenario: Failing magic comments
    Given the file "Readme.mountain_berry_fields.md"
    """
    # Whatever

        <% test 'basic addition', with: :magic_comments do %>
        1 + 2 # => 12
        <% end %>

    More shit here
    """
    When I run "mountain_berry_fields Readme.mountain_berry_fields.md"
    Then it exits with a status of 1, and a stderr of
    """
    FAILURE: basic addition
    Expected: 1 + 2 # => 12
    Actual:   1 + 2 # => 3
    """
    And I do not see the file "Readme.md"
