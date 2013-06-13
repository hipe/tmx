require_relative '../lib/skylab'
require 'skylab/test-support/core'
require 'skylab/face/core'        # `pretty_path`, Tableize::I_M

module Skylab::Test

  # (setup this module for support used in both benchmarking and the
  # test runner - it's a big swath, but hopefull the core.rb files are
  # kept lightweight.)

  %i| Face Headless MetaHell Test TestSupport |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  extend MetaHell::MAARS

  extend MetaHell::MAARS  # make it an autoloader, sure why not.

end
