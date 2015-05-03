require_relative '../test-support'

module Skylab::Headless::TestSupport::System::Services::Filesystem

  ::Skylab::Headless::TestSupport::System::Services[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym

      TS_.const_get(
        Callback_::Name.via_variegated_symbol( sym ).as_const, false
      )[ self ]

      NIL_
    end
  end

  module InstanceMethods
    def subject
      super.filesystem
    end
  end

  # ~

  module TestLib_

    include Constants::TestLib_

    File_utils = -> do
      Headless_::Library_::FileUtils
    end

    Tmpdir_pathname = -> do
      Headless_.system.defaults.dev_tmpdir_pathname
    end
  end

  My_Tmpdir_ = -> do

    o = nil  # :+#nasty_OCD_memoize (see similar in [sg])

    -> tcm do

      tcm.send :define_method, :my_tmpdir_ do

        if o
          if do_debug
            if ! o.be_verbose
              o = o.new_with :debug_IO, debug_IO, :be_verbose, true
            end
          elsif o.be_verbose
            o.new_with :be_verbose, false
          end
        else
          o = TestSupport_.tmpdir.new(
            :path, TS_.tmpdir_pathname,
            :be_verbose, do_debug,
            :debug_IO, debug_IO )
        end
        o
      end
    end
  end.call

  # ~

  Callback_ = Headless_::Callback_
  Headless_ = Headless_
  NIL_ = nil

  module Constants
    TestLib_ = TestLib_
  end
end
