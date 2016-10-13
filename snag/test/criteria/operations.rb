module Skylab::Snag::TestSupport

  module Criteria::Operations

    def self.[] tcc
      tcc.include self
    end

    # this is definitely some testing antipattern - we possibly mutate
    # our "real live" application "installation" by adding a blank file
    # in a particular data directory. and then we hack teardown..

    setup_once = nil
    define_method :ensure_common_setup_ do
      setup_once[]
      NIL_
    end

    def retrieve_criteria_the_long_way_ target_s

      call_API :criteria, :to_criteria_stream

      st = @result

      begin
        o = st.gets
        o or break
        _s = o.property_value_via_symbol :name
        if target_s == _s
          found = o
          break
        end
        redo
      end while nil

      found
    end

    def criteria_directory_
      Path__[]
    end


    teardown = nil
    setup_once = -> do

      s = Path__[]

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
        fh = ::File.open( path, ::File::CREAT | ::File::WRONLY )
        fh.write "nodes that are tagged with #rocket\n"
        fh.close
      end

      if did_a.length.nonzero?
        did_a.reverse!
        ::Kernel.at_exit do
          teardown[ did_a, fu[] ]
        end
      end

      setup_once = Home_::EMPTY_P_

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

    Path__ = Common_.memoize do
      ::File.join(
        Home_.dir_path,
        Home_::Models_::Criteria::PERSISTED_CRITERIA_FILENAME___,
      )
    end
  end
end
