require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - to-stream" do

    extend TS_
    use :expect_event

    it "`to_criteria_stream` lists the files that are in the folder" do

      _ensure_common_setup

      call_API :criteria, :to_criteria_stream
      st = @result
      s = 'example'
      begin
        o = st.gets
        o or break
        _s = o.property_value_via_symbol :name
        if s == _s
          found = o
          break
        end
        redo
      end while nil

      found or fail
    end

    # this is definitely some testing antipattern - we possibly mutate
    # our "real live" application "installation" by adding a blank file
    # in a particular data directory. and then we hack teardown..

    setup_once = nil

    define_method :_ensure_common_setup do
      setup_once[]
    end

    teardown = nil

    setup_once = -> do

      s = Snag_.dir_pathname.join(
        Snag_::Models_::Criteria::PERSISTED_CRITERIA_FILENAME___
      ).to_path

      s_a = [
        ::File.dirname( s ),
        ::File.basename( s ),
        'example' ]

      fu = -> do
        require 'fileutils'
        fu = -> do
          ::FileUtils
        end
        ::FileUtils
      end

      did_a = []
      fs = ::File

      ( s_a.length - 1 ).times do | d |

        path = ::File.join( * ( d + 1 ).times.map { | d_ | s_a.fetch d_ } )

        if ! fs.directory? path
          did_a.push [ :dir, path ]
          fu[].mkdir_p path
        end
      end

      path = ::File.join( * s_a )

      if ! fs.file? path
        did_a.push [ :file, path ]
        fu[].touch path
      end

      if did_a.length.nonzero?
        did_a.reverse!
        ::Kernel.at_exit do
          teardown[ did_a, fu[] ]
        end
      end

      setup_once = Snag_::EMPTY_P_

      NIL_
    end

    teardown = -> did_a, fu do

      TestSupport_.debug_IO.puts( "(hacking cleanup of #{ did_a.map( & :first ) * ' and ' })" )

      did_a.each do | sym, path |
        case sym
        when :dir
          ::Dir.rmdir path
        when :file
          fu.rm path
        end
      end

      teardown = false

      NIL_
    end
  end
end
