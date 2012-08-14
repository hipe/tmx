require File.expand_path('../../..', __FILE__)
require 'skylab/test-support/core'
require 'tmpdir'

module ::Skylab
  module CodeMolester
    module TestSupport
    end
    module TestNamespace
    end
  end
end

module ::Skylab::CodeMolester::TestSupport
  class Tmpdir < Pathname
    include FileUtils
    attr_accessor :debug
    def fu_output_message msg
      @debug and $stderr.puts "#{self.class}:dbg: #{msg}"
    end
    def initialize p=nil
      @debug = false
      p = p ? p.to_s : Dir.tmpdir
      super(p)
      yield(self) if block_given?
    end
    SAFETY = %w(tmp T)
    def prepare
      SAFETY.include?(dirname.basename.to_s) or
        fail("Being extra cautious for now, unsafe dirname: #{dirname}")
      dirname.exist? or fail("nope: parent dir must exist: #{dirname}")
      make = true
      if exist?
        if Dir[join('*')].any?
          @debug and fu_output_message("rm -rf #{to_s}")
          remove_entry_secure to_s
        else
          make = false
          @debug and fu_output_message("(already empty: #{to_s}")
        end
      end
      make and mkdir(to_s, :verbose => true)
    end
  end
end

module ::Skylab::CodeMolester::TestSupport
  TMPDIR = Tmpdir.new(::Skylab::ROOT.join('tmp/co-mo'))
end

