module Skylab::Git::TestSupport

  module CLI

    def self.[] tcc
      if false
      Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
      end
      tcc.include Instance_Methods___
      NIL_
    end

    module Instance_Methods___

      def subject_CLI
        Home_::CLI
      end

      define_method :get_invocation_strings_for_want_stdout_stderr, -> do
        a = [ 'gi' ]
        -> do
          a
        end
      end.call

      def cd_ path, & x_p
        LIB__.__cd path, & x_p
      end
    end

    module LIB__ ; class << self

      def __cd path, & x_p

        __file_utils.cd path, & x_p
      end

      def __file_utils
        @__file_utils ||= __build_file_utils
      end

      def __build_file_utils
        require 'fileutils'
        ::FileUtils
      end
    end ; end
  end
end
