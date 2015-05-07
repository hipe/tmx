module Skylab::System::TestSupport

  module Services::Filesystem::Tmpdir

    class << self

      def [] tcm
        tcm.include self
      end
    end  # >>

    def anchor_
      services_.defaults.dev_tmpdir_pathname
    end

    def fu_
      System_.lib_.file_utils
    end

    define_method :my_tmpdir_, -> do

      o = nil  # :+#nasty_OCD_memoize (see similar in [sg])

      -> do

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
            :path, TS_.tmpdir_path_,
            :be_verbose, do_debug,
            :debug_IO, debug_IO )
        end
        o
      end
    end.call
  end
end
