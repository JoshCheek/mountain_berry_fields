Feature: Input and output directories
  The current working directory while the mbf file executes
  is its own directory.

  The output file is placed in the same directory.

  Scenario:
    Given the file "example/mah_filez.mountain_berry_fields":
    """
    <% test 'what dir?', with: :magic_comments do %>
    Dir.pwd # => "{{proving_grounds_dir}}/example"
    <% end %>
    """
    When I run "mountain_berry_fields example/mah_filez.mountain_berry_fields"
    Then it exits with a status of 0
    And I see the file "example/mah_filez"
