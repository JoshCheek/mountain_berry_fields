Feature: Integrate with xmpfilter

  Scenario: Passing xmpfilter
    Given the file "Readme.mountain_berry_fields.md"
    """
    # Whatever

        <% test 'basic addition', strategy: :xmpfilter do %>
        1 + 1 # => 2
        <% end %>

    More shit here
    """
    When I run "mountain_berry_fields Readme.mountain_berry_fields.md"
    Then it exits with a status of 0
    Then I see the file "Readme.md"
    """
    # Whatever

        1 + 1 # => 2

    More shit here
    """

  Scenario: Failing xmpfilter
    Given the file "Readme.mountain_berry_fields.md"
    """
    # Whatever

        <% test 'basic addition', strategy: :xmpfilter do %>
        1 + 2 # => 2
        <% end %>

    More shit here
    """
    When I run "mountain_berry_fields Readme.mountain_berry_fields.md"
    Then it exits with a status of 1, and a stderr of
    """
    FAILURE: basic addition
    Expected: 1 + 2 # => 2
    Actual:   1 + 2 # => 3
    """
    And I do not see the file "Readme.md"
