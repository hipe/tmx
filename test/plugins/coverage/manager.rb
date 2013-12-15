module Skylab::Test

  class Plugins::Coverage::Manager

    # this is a bootstrap zone! no fun allowed [#te-002]. if you are familiar
    # with the skylab universe and how perfect, clean and consistent it always
    # is (i'm lookin' at you, me!) then everything here will look wierd to you.

    SWITCH_ = Plugins::Coverage::SWITCH_

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
      @final_conclusions = nil
      @state = nil
      state! :initialized
      nil
    end

    # `start` - result is tuple. `argv` is argv of caller and must not
    # be mutated. idx is the index of the e.g `--c-overage` switch.

    def start y, argv, idx
      require LIB_SKYLAB_PN_[].join( 'test-support/fun' ).to_s
        # the above is the last require before we (_we_) are started.
      begin
        state! :starting
        sn = ::Struct.new( :medium, :murmur ).new( true, false )  # try it
        ok, res = resolve_white_matcher y, argv, idx, sn
        ok or break
        @white_x = res
        ok, res = start_simplecov y, sn
        ok or break
        @black_x = -> do  # do this after starting above just as grease
          rx = ::Regexp.method :escape ; fun = ::Skylab::TestSupport::FUN
          Black_Rx_Matcher_.new(  # could stand to be more extensible
            %r{ (?:
              #{ rx[ fun::Spec_rb[] ] }
                |
              (?: \A | / )
              (?: #{  fun::Test_support_filenames[].map( & rx ) * '|' } )
            )\z }x )
        end.call
        state! :started
        ok = true ; res = nil
      end while false
      [ ok, res ]
    end

    def final_conclusions
      @final_conclusions and @final_conclusions[]
    end

    def add_path y, path
      :started == @state or raise "can't add path unless started - #{ @state }"
      @white_x.add_path y, path
    end

  private

    -> do  # `state!` - cutie little baby state machine
      h = {
        initialized: {
          starting: -> { },
        },
        starting: {
          started: -> { @is_started = true }
        }
      }
      h[ nil ] = {
        initialized: -> {  @is_started = false }
      }
      define_method :state! do |i|
        instance_exec( & h.fetch( @state ).fetch( i ) )
        @state = i
        nil
      end
      private :state!
    end.call

    def resolve_white_matcher y, argv, idx, sn  # result is tuple
      argv = argv.dup
      argv[ idx, 1 ] = [ ]
      if argv.length.zero?
        [ DO_STAY_, OMNI_PASS_MATCHER_ ]
      else
        build_union_matcher y, argv, idx, sn
      end
    end

    DO_STAY_ = true ; DO_NOT_STAY_ = false ; GENERIC_ERROR_CODE_ = 1

    def build_union_matcher y, argv, idx, sn
      # Dir.glob avoids dotfiles unlike Pathname#children
      h = ::Dir[ LIB_SKYLAB_PN_[].join '*' ].reduce( { } ) do |m, p|
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
        y << "when using, #{ SWITCH_ } we can only have subproduct #{
          }names here (for now), not (#{ miss_a * ', ' })"
        [ DO_NOT_STAY_, GENERIC_ERROR_CODE_ ]
      else
        [ DO_STAY_, Pathname_Union_Matcher_.new( a ) ]
      end
    end

    def start_simplecov y, sn
      yes = n = yc = nc = 0
      p = $VERBOSE ; $VERBOSE = nil ; require 'simplecov' ; $VERBOSE = p
      sc = ::SimpleCov ; cache_h = { }
      sc.command_name "#{ FULL_NAME_[] } [various]"
      sc.add_filter do |x|
        @is_started or ::Kernel.raise "sanity - had state #{
          }#{ @state.inspect } when tried to load - #{ x.filename }"
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
      begin
        ok = sc.start
        if ! ok
          y << "simplecov was not usable. it may be that the #{ SWITCH_ } #{
            }option is unavailable to you where you live in your #{
            }neigbhorhood."
          break( res = GENERIC_ERROR_CODE_ )
        end
        @final_conclusions = -> do
          if sn.medium
            y << "(cov mgr said yes to #{ yes } files, no to #{ n }, was #{
              }asked again about any same file #{ yc + nc } times)"
          end
        end
      end while false
      [ ok, res ]
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

    class Pathname_Union_Matcher_

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
  end
end
