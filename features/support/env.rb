require 'simplecov'
require 'fileutils'

module ProvingGrounds
  include FileUtils

  def proving_grounds_dir
    File.expand_path "../../proving_grounds", __FILE__
  end

  def in_proving_grounds(&block)
    make_proving_grounds
    cd proving_grounds_dir, &block
  end

  def make_proving_grounds
    mkdir_p proving_grounds_dir
  end

  def remove_proving_grounds
    rm_r proving_grounds_dir
  end
end

ENV['PATH'] = "#{File.expand_path "../../../bin", __FILE__}:#{ENV['PATH']}"
ENV['YO_IM_TESTING_README_SHIT_RIGHT_NOW'] = 'FOR_REALSIES'
World ProvingGrounds
After { remove_proving_grounds }
