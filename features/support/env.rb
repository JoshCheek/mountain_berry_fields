require 'simplecov'

require 'fileutils'
module ProvingGrounds
  def proving_grounds_dir
    File.expand_path "../../proving_grounds", __FILE__
  end

  def in_proving_grounds(&block)
    make_proving_grounds
    FileUtils.cd(proving_grounds_dir) { return block.call }
  end

  def make_proving_grounds
    FileUtils.mkdir_p proving_grounds_dir
  end

  def remove_proving_grounds
    FileUtils.rm_r proving_grounds_dir
  end

  def ensure_dir(dirname)
    FileUtils.mkdir_p dirname
  end
end


module Helpers
  def interpret_curlies(string)
    string.gsub /{{.*?}}/ do |code|
      code.sub! /^{{/, ''
      code.sub! /}}$/, ''
      eval code
    end
  end

  def strip_trailing_whitespace(text)
    text.gsub /\s+$/, ''
  end
end

require 'open3'
class CommandLine
  module CukeHelpers
    def cmdline(command, options={})
      @last_cmdline = CommandLine.new(command, options)
      @last_cmdline.execute
      @last_cmdline
    end

    def last_cmdline
      @last_cmdline
    end
  end

  attr_reader :command, :options, :stderr, :stdout

  def initialize(command, options={})
    @command, @options = command, options
  end

  def execute
    @stdout, @stderr, @status = Open3.capture3(command, @options)
  end

  def exitstatus
    @status.exitstatus
  end
end

ENV['PATH'] = "#{File.expand_path "../../../bin", __FILE__}:#{ENV['PATH']}"
ENV['YO_IM_TESTING_README_SHIT_RIGHT_NOW'] = 'FOR_REALSIES'
World ProvingGrounds
World CommandLine::CukeHelpers
World Helpers
After { remove_proving_grounds }
