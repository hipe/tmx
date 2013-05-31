# as long as we use the test runner to determine (some kind of) coverage for
# the libraries on top of which the test runner itself depends, for any file
# that is loaded before we start the coverage library, we cannot determine
# coverge for that file. we therefor write this file bare, with no
# dependencies, even though we would otherwise want certain things. i.e:
#
# "this is a bootstrap zone! no fun allowed."

module Skylab
end

module Skylab::Test

  module Plugins
  end

  class Plugins::Coverage  # yes eew
  end

  class Plugins::Coverage::Manager

    -> do
      the_one_place_where_singleton_should_be_ok = nil
      define_singleton_method :instance do
        the_one_place_where_singleton_should_be_ok ||= begin
          x = new
          ::Kernel.at_exit( & x.method( :final_conclusions ) )
          x
        end
      end
      nil
    end.call

    def initialize
      @state = :initialized ; @is_started = nil  # keep together.
      nil
    end

    # `start` - result is tuple. `argv` is argv of caller and must not
    # be mutated. idx is the index of the `--coverage` switch.

    def start y, argv, idx
      :initialized == @state or fail "sanity - bad state transition"
      @state = :starting

      sn = ::Struct.new( :medium, :murmur ).new( true, false )  # try it

      require_relative '../../../lib/skylab/test-support/fun'
        # no more requires until we are started.

      yes = n = yc = nc = 0

      -> do
        p = $VERBOSE ; $VERBOSE = nil ; require 'simplecov' ; $VERBOSE = p
        sc = ::SimpleCov
        cache_h = { }
        sc.add_filter do |x|
          if ! @is_started
            ::Kernel.raise "sanity - had state #{ @state.inspect } #{
              }when tried to load - #{ x.filename }"
          end
          did = nil
          res = cache_h.fetch x.filename do |k|
            did = true ; r =
            if @white_x.match( x.filename ) && ! @black_x.match( x.filename )
              sn.murmur and y << "Y    #{ x.filename }"
              yes += 1
              false
            else
              sn.murmur and y << "N    #{ x.filename }"
              n += 1
              true
            end
            cache_h[ k ] = r
          end
          if ! did
            sn.murmur and y << "#{ res ? 'N' : 'Y' }(c) #{ x.filename }"
            res ? ( nc += 1 ) : ( yc += 1 )
          end
          res
        end
        sc.start
        nil
      end.call

      @black_x = -> do
        Black_Rx_Matcher_.new(
          /#{ ::Regexp.escape ::Skylab::TestSupport::FUN._spec_rb[] }\z/
        )
      end.call

      @white_x = -> do
        argv = argv.dup
        argv[ idx, 1 ] = [ ]
        if argv.length.zero?
          OMNI_PASS_MATCHER_
        else
          resolve_white_matcher argv
        end
      end.call

      @final_conclusions = -> do
        if sn.medium
          y << "(cov mgr said yes to #{ yes } files, no to #{ n }, was #{
            }asked again about any same file #{ yc + nc } times)"
        end
      end

      @state = :started ; @is_started = true  # keep together.
      true
    end

    def final_conclusions ; @final_conclusions[ ] end

    def add_path y, path
      :started == @state or raise "can't add path unless started - #{ @state }"
      @white_x.add_path y, path
    end

    class Omni_Pass_Matcher_
      def pass _ ; true end
    end

    OMNI_PASS_MATCHER_ = Omni_Pass_Matcher_.new

    class Black_Rx_Matcher_

      def initialize rx
        @match = -> x do
          rx =~ x
        end
      end

      def match x ; @match[ x ] end
    end

    class Pathname_Union_Mathcer

      def initialize a
        @match = -> path do
          a.detect do |dir|
            idx = path.index dir
            idx && idx.zero?
          end
        end
        @add_path = -> y, x do
          '/' == x[ -1 ] and raise "abnormal - #{ x }"
          x = "#{ x }/"
          shorter = @match[ x ]
          if shorter
            if shorter != x
              fail "sanity - #{ x }"
            end
          else
            a << x
            true
          end
        end
      end

      def match x ; @match[ x ] end
      def add_path y, x ; @add_path[ y, x ] end
    end

  private

    def resolve_white_matcher argv  # assume nonzero length argv
      require 'pathname'
      # Dir.glob avoids dotfiles unlike Pathname#children
      h = ::Dir[::File.expand_path '../../../../lib/skylab/*', __FILE__].
          reduce( { } ) do |m, p|
        pn = ::Pathname.new p
        m[ pn.basename.to_s ] = pn
        m
      end
      a = [ ] ; miss_a = nil ; argv.each do |x|
        if h.key? x
          a << "#{ h.fetch x }/"
        else
          ( miss_a ||= [ ] ) << x
        end
      end
      if miss_a
        raise "for now we must have only subproduct names here - (#{
          }#{ miss_a * ', ' })"
      end
      Pathname_Union_Mathcer.new a
    end
  end
end
      # ::SimpleCov.command_name "#{ Core_Client.full_name } [various]"
