Feature: Simple test

  Scenario: Error when the test passes
    Given the file "Readme.md.testable_readme"
    """
    # Whatever

        <% test 'IS will pass', strategy: :always_pass do %>
        some code
        <% end %>
    """
    When I run "readme_tester Readme.md.testable_readme"
    Then it exits with a status of 0
    And I see the file "Readme.md"
    """
    # Whatever


        some code
    """

  Scenario: Fail when the test fail
    Given the file "Readme.md.testable_readme"
    """
    # Whatever

        <% test 'I will fail', strategy: :always_fail do %>
        some code
        <% end %>
    """
    When I run "readme_tester Readme.md.testable_readme"
    Then it exits with a status of 1, and a stderr of
    """
    FAILURE: I will fail
    THIS STRATEGY ALWAYS FAILS
    """
    And I do not see the file "Readme.md"
