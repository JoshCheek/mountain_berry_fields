class MountainBerryFields
  class RakeTask
    include Rake::DSL

    def initialize(task_name, input_file_name)
      desc("Test and generate #{input_file_name}") unless ::Rake.application.last_comment
      task task_name do
        sh "mountain_berry_fields #{input_file_name}"
      end
    end
  end
end
