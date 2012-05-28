Feature: Nothing to interpret

  Scenario: Fail when the readme doesn't exist
    When I run "readme_tester NonexistentReadme.md.testable_readme"
    Then it exits with a status of 1, and a stderr of
    """
    "{{proving_grounds_dir}}/NonexistentReadme.md.testable_readme" does not exist.
    """

  Scenario: Does nothing for a file with no tests
    Given the file "Readme.md.testable_readme"
    """
    # Whatever

    Some text

      some code
    """
    When I run "readme_tester Readme.md.testable_readme"
    Then it exits with a status of 0
    And I see the file "Readme.md"
    """
    # Whatever

    Some text

      some code
    """
