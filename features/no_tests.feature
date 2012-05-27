Feature: No Tests
  Scenario: Does nothing for a file with no tests
    Given the file "Readme.md.testable"
    """
    # Whatever

    Some text

      some code
    """
    When I run "readme_tester Readme.md.testable"
    Then I see "Readme.md"
    """
    # Whatever

    Some text

      some code
    """
