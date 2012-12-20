require_relative '../test-support'


module Skylab::CodeMolester::TestSupport::Config::File
  ::Skylab::CodeMolester::TestSupport::Config[ File_TestSupport = self ]


  include self::CONSTANTS # so we can say C_M from the body of our specs

  module InstanceMethods
    include CONSTANTS # so we can say C_M from within i.m's below

    def config_file_new *a
      @o = CodeMolester::Config::File.new(* a)
    end


    def debug!
      CodeMolester::Config::File.do_debug = true
    end


    attr_reader :o

    def tmpdir
      TMPDIR
    end
  end
end
