#!/usr/bin/env ruby -w

module Skylab

  class SimpleCov

    # a fun one-off for using simplecov in ad-hoc scenarios. if you have
    # some ruby that can be run by loading one file and processing some
    # argv (probably all ruby), you can use this script to load it, while
    # indicating explicitly which files you would like to get coverage
    # information on.

    # this is for ad-hoc scenarios (like debugging something tricky) and not
    # for typical coverage measurement of a test or test suite. for such
    # standard use, please see the simplecov gem's README.md

    def initialize sin, sout, serr
      @program_name = nil
      @y = ::Enumerator::Yielder.new { |msg| serr.puts msg ; nil }
      @invoke = -> argv do
        argv.length.zero? and break usage
        1 == argv.length and /\A-(?:h|-help)\z/ =~ argv[0] and break usage
        ok, res = resolve_matcher argv
        if ok
          res = execute argv
        end
        res
      end
      nil
    end

    def invoke argv
      @invoke[ argv ]
    end

    attr_writer :program_name

  private

    def resolve_matcher argv  # result is tuple
      idx = argv.index '--'
      if ! idx then
        @matcher = MOCK_
        true
      else
        # special circumstances here: we might be bootstrapping.
        require_relative calculate_lib_skylab_absolute_path
        require 'skylab/basic/core'
        @matcher = -> a do
          a.map! { |x| ::File.expand_path x }
          u = ::Skylab::Basic::Pathname::Union[ * a ]
          u.normalize -> e do
            @y << "(#{ program_name } #{
              }#{ nil.instance_exec( & e.message_proc ) })"
            nil
          end
          u
        end.call argv[ 0, idx ]
        argv[ 0 .. idx ] = []
        true
      end
    end

    class Mock_
      def match x ; true end
    end

    MOCK_ = Mock_.new

    def calculate_lib_skylab_absolute_path
      ::File.expand_path(
        ::Array.new( HOST_C_A_.length, '..' ) * '/', __FILE__ )
    end

    def execute argv
      FUN.without_warning[ -> { require 'simplecov' } ]
      # we assume that the first arg element is a loadable path. we shift it
      # off so that the remaining argv attempts to mimic the argv that the
      # script would have seen if it were invoked with ruby or as an exeuctable.
      pth = argv.shift or fail "sanity - empty argv?"
      @y << "(#{ program_name } about to run: #{ ( [ pth ] + argv ) * ' ' })"
      ::SimpleCov.command_name "#{ ::File.basename pth } (skylab simplecov)"
      ::SimpleCov.add_filter do |x|
        ! @matcher.match( x.filename )
      end
      ::SimpleCov.start
      load_path_somehow pth
      # $VERBOSE = false  # let simplecov go quietly on exit ([#sc-002])
    end

    def load_path_somehow pth
      # this kind of sucks : apparently the simplecov hooks into `require`
      # and not `load` (from the looks of it), so if a standalone file itself
      # is what you're covering, we cannot use load, hence it must end
      # with an `.rb`. in other words for now it appears impossible to
      # cover a standalone executable ruby script.
      xp = ::File.expand_path pth
      require xp  # we used to use `load`
    end

    o = { }

    o[:without_warning] = -> f do  # as seen in [#mh-028]
      x = $VERBOSE ; $VERBOSE = false
      begin
        r = f.call
      ensure
        $VERBOSE = x
      end
      r
    end

    # `run_with_rspec` - this was what this script used to do, here for
    # possible future use

    o[:run_with_rspec] = -> argv, serr, sout do
      o[:load_bundler].call
      o[:without_warning][ -> do
        require 'rspec/core'
        require 'simplecov'
      end ]
      $VERBOSE = false # simplecov barfs at exit otherwise
      ::RSpec::Core::Runner.run argv, serr, sout
    end

    o[:load_bundler] = -> do
      ::ENV['BUNDLE_GEMFILE'] ||= "#{ o[:root][] }/Gemfile"
      nil
    end

    -> do
      root = nil
      o[:root] = -> do
        root ||= ::File.expand_pth '../..', __FILE__
      end
    end.call

    def usage
      usage_string = -> do
        "#{ program_name } [ <white-path> [ <white-path> [..] ] -- ] <something-that-runs-some-ruby>"
      end
      usage = -> do
        @y << "usage: #{ usage_string[] }"
        nil
      end
      usage[]
    end

    def program_name
      @program_name || $PROGRAM_NAME
    end

    FUN = ::Struct.new( * o.keys ).new( * o.values )

    def self.load_into_host
      # assume we have just been autoloaded by the parent node
      # place ourselves in the appropriate location in that graph
      mod = HOST_C_A_.reduce( ::Object ) do |m, c|
        m.const_get c, false
      end
      mod.const_set :Simplecov, self
      # the casing changes only because our filename has no '-' or '_'
      nil
    end

    HOST_C_A_ = %i| Skylab TestSupport Regret CLI Actions |

  end
end

# this hybridization allows us to run this file directly if any parent
# nodes are in a broken state.

if __FILE__ == $PROGRAM_NAME
  Skylab::SimpleCov.new( STDIN, STDOUT, STDERR ).invoke ::ARGV
else
  Skylab::SimpleCov.load_into_host
end
