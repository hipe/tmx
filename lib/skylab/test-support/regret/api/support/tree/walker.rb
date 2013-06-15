module Skylab::TestSupport::Regret::API

  class API::Support::Tree::Walker

    # unifying something we've done in three places.

    # experimental interface, pub-sub-like, *somewhat*

    def initialize start_path, top, vtuple, listener
      @pn, @top, @vt, @listener = ::Pathname.new( start_path ), top,
        vtuple, listener
    end
    attr_reader :pn, :top

    #                     ~ steps. (section 1) ~

    def find_first_dir path
      @dir_pn = nil
      a = build_difference
      a.pop  # for now, we won't be looking for dirs under the leaf ("")
      while a.length.nonzero?
        dir = @top_pn.join( * a, path )
        dir.directory? and break
        dir = nil
        a.pop
      end
      if dir then
        @dir_pn = dir
        true
      else
        a = build_difference
        say :notice, -> do
          "did not find any dirs named `#{ path }` around the #{
          }dirs (#{ a * ' ' })"
        end
        false
      end
    end
    attr_reader :dir_pn

    def load_downwards
      -> do  # #result-block
        path_a = build_difference or break path_a
        @module = path_a.reduce @top_mod do |m, x|
          MetaHell::Boxxy::FUN.fuzzy_const_get[ m, x ]  # #todo ui here
        end
        true
      end.call
    end
    attr_reader :module

    def build_difference
      self.class.subtract( @xpn, @top_pn ).sub_ext( '' ).to_s.
        split( ::Pathname::SEPARATOR_LIST )
    end
    private :build_difference

    -> do  # `find_top_toplevel
      fun = MetaHell::Boxxy::FUN ; slash = ::Pathname::SEPARATOR_LIST

      define_method :find_toplevel_module do
        top_mod, top_pn = find_top
        top_mod or break
        @top_mod, @top_pn = top_mod, top_pn
        true
      end

      report_error = -> p_a_, top_norm_a do
        _big = -> do  # #todo:for:release
          p_a_.reduce( [] ) do |m, x|
            m << fun.normulate[ x ] if '' != x ; m
          end * ' '
        end
        case top_norm_a.length
        when 0
          say :notice, -> { "none of the elements of your path were found #{
            }to have isomorphs in the toplevel constants of the ruby #{
            }runtime - (#{ _big[] })" }
        when 1 ; fail "sanity - no"
        else
          say :notice, -> do
            "which of these corresponds with your toplevel constant - #{
              }#{ top_norm_a.map { |x| x.first.inspect } * ' or ' }? they #{
              }are #{ 2 == top_norm_a.length ? 'both' : 'all' } isomorphic #{
              }with toplevel constants in the ruby runtime. #{
              }use --top to chose one. #{
              }(seeing the elements of your path as (#{ _big[] })"
          end
        end
        nil
      end

      final_result = -> c_a, c_h, top_norm, p_a, idx do
        top_pn = ::Pathname.new p_a[ 0 .. idx ].join( slash )
        top_mod = ::Object.const_get c_a.fetch( c_h.fetch( top_norm ) )
        [ top_mod, top_pn ]
      end

      guess_top = -> p_a_, c_a, c_h do # #result-is-tuple of `mod` / `pn`
        p_a = p_a_.dup
        top_norm_a = []
        begin
          top_norm = fun.normulate[ p_a.fetch( -1 ) ]
          if c_h.key? top_norm
            top_norm_a << [ top_norm, p_a.length - 1 ]
          end
          p_a.pop
          if p_a.empty? || '' == p_a.last
            break
          end
        end while true
        -> do  # #result-block
          if 1 != top_norm_a.length
            instance_exec p_a_, top_norm_a, & report_error
            break false
          end
          top_norm, idx = top_norm_a.fetch 0
          final_result[ c_a, c_h, top_norm, p_a_, idx ]
        end.call
      end

      do_big = nil
      c_a_ = -> svcs, c_a do
        do_big = true
        cond = ' [..]' if ! svcs.vtuple[ :murmur ]
        "the list of #{ c_a.length } normulated versions of ruby runtime #{
          }toplevel constants#{ cond }"
      end

      know_top = -> p_a, c_a, c_h, top do
        nerk = fun.normulate[ top ]
        bork = -> f do
          do_big = nil
          say :notice, -> do
            "#{ instance_exec( & f ) }. cannot procede."
          end
          if do_big
            do_big = nil
            say :murmur, -> do
              "(the normulated toplevel constants are: #{ c_h.keys * ' ' })"
            end
          end
          false
        end
        idx = c_h[ nerk ]
        -> do # result block
          if ! idx
            me = self
            break bork[ -> do
              "the normulated version of your `--top` value (\"#{ nerk }\") #{
                }was not found in #{ c_a_[ me, c_a ] }"
            end ]
          end
          npa = p_a.map( & fun.normulate )
          a = npa.length.times.reduce [] do |m, x|
            m << x if nerk == npa[ x ] ; m
          end
          case a.length
          when 0
            break bork[ -> do
              "\"#{ nerk }\" not found in (#{ npa * ' ' })"
            end ]
          when 1  # fallthru
          else
            break bork[ -> do
              "\"#{ nerk }\" found multiple times in (#{ npa * ' ' })"
            end ]
          end
          final_result[ c_a, c_h, nerk, p_a, a.fetch( 0 ) ]
        end.call
      end

      define_method :find_top do  # #result-is-tuple of `mod` / `pn`
        c_a = ::Object.constants.freeze
        c_h = ::Hash[
          c_a.each_with_index.map do |i, idx|
            [ fun.normulate[ i ], idx ]
          end ]
        xp = @xpn = @pn.expand_path
        p_a = xp.sub_ext( '' ).to_s.split slash
        mod, pn = if @top
          instance_exec p_a, c_a, c_h, @top, &know_top
        else
          instance_exec p_a, c_a, c_h, & guess_top
        end
        pn.instance_variable_get( :@path ).length.zero? and fail "sanity"
        [ mod, pn ]
      end
    end.call
    attr_reader :xpn, :top_pn, :top_mod

    def current_path_exists
      pn = @pn
      if pn.exist?
        say :medium, -> { "yep i see it there: #{ @pth[ pn ] }" }
        true
      else
        say :notice, -> { "not found: #{ @pth[ pn ] }" }
        false
      end
    end

    #         ~ class methods as couresy functions (section 2) ~

    # `subtract` - `relative_path_from` with a sanity check

    def self.subtract longer_pn, shorter_pn
      0 == longer_pn.to_s.index( shorter_pn.to_s ) or fail "sanity - .."
      longer_pn.relative_path_from shorter_pn
    end

    #               ~ non-topical private (section 3) ~

    def say volume, msg_func
      @listener.call Event_.new( volume, msg_func )
      nil
    end
    private :say

    Event_ = ::Struct.new :volume, :message_function


    def vtuple  # #called-by self internally
      @vt
    end
  end
end
