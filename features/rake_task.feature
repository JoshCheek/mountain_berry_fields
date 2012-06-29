Feature: Mountain Berry Fields provides a rake task

  To automate usage, users may wish to add Mountain Berry Fields
  to a rake task, which runs as part of their suite.

  Scenario: Successful rake task
    Given the file "Rakefile":
    """
    require 'mountain_berry_fields/rake_task'
    MountainBerryFields::RakeTask.new(:mbf, 'Readme.mountain_berry_fields.md')
    """
    And the file "Readme.mountain_berry_fields.md":
    """
    Use it like this:

    <% test 'example', with: :always_pass do %>
    the code
    <% end %>
    """
    When I run "rake mbf"
    Then it exits with a status of 0
    And I see the file "Readme.md":
    """
    Use it like this:

    the code
    """


  Scenario: Failing rake task
    Given the file "Rakefile":
    """
    require 'mountain_berry_fields/rake_task'
    MountainBerryFields::RakeTask.new(:mountains, 'Readme.mountain_berry_fields.md')
    """
    And the file "Readme.mountain_berry_fields.md":
    """
    Use it like this:

    <% test 'example', with: :always_fail do %>
    the code
    <% end %>
    """
    When I run "rake mountains"
    Then it exits with a status of 1
    And I do not see the file "Readme.md"
