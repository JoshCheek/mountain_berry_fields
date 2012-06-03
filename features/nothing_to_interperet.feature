Feature: Nothing to interpret

  Scenario: Fail when the file doesn't exist
    When I run "mountain_berry_fields NonexistentReadme.mountain_berry_fields.md"
    Then it exits with a status of 1, and a stderr of
    """
    "{{proving_grounds_dir}}/NonexistentReadme.mountain_berry_fields.md" does not exist.
    """

  Scenario: Does nothing for a file with no tests
    Given the file "Readme.mountain_berry_fields.md"
    """
    # Whatever

    Some text

      some code
    """
    When I run "mountain_berry_fields Readme.mountain_berry_fields.md"
    Then it exits with a status of 0
    And I see the file "Readme.md"
    """
    # Whatever

    Some text

      some code
    """
