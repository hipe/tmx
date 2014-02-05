module Skylab::Headless

  module System  # read [#140] the headless system narrative #section-1

    module InstanceMethods
    private
      def system
        @system ||= System::Client__.new  # see
      end
    end

    MetaHell_ = Headless::Library_::MetaHell

    define_singleton_method :system,
      MetaHell_::FUN.memoize_to_const_method[
        -> { System::Client__.new }, :SYSTEM_CLIENT__ ]

    def self.defaults
      System::DEFAULTS__  # see
    end

    IO = (( class IO__ < ::Module  # #section-4 of the node narrative

      def some_two_IOs
        [ some_stdout_IO, some_stderr_IO ]
      end

      def some_three_IOs
        [ some_stdin_IO, some_stdout_IO, some_stderr_IO ]
      end

      i = $stdin ; o = $stdout ; e = $stderr

      define_method :some_stdin_IO do i end
      define_method :some_stdout_IO do o end
      define_method :some_stderr_IO do e end

      self
    end )).new
  end
end
