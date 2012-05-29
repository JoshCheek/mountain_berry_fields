@wip
Feature: Simple test

  Scenario: Error when the test passes
    Given the file "Readme.md.testable_readme"
    """
    # Whatever

        <% test 'I will pass', strategy: :always_pass %>
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

        <% test 'I will fail', strategy: :always_fail %>
        some code
        <% end %>
    """
    When I run "readme_tester Readme.md.testable_readme"
    Then it exits with a status of 1, and a stderr of
    """
    Failure:  I will fail
    This test will always fail.
    """
    And I do not see the file "Readme.md"
