module Skylab::TestSupport::Regret::API

  class API::Support::Tree::Walker

    # unifying something we've done in three places.

    # experimental interface, pub-sub-like, *somewhat*

    def initialize start_path, listener
      @pn, @listener = ::Pathname.new( start_path ), listener
    end
    attr_reader :pn

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
        say :everything, -> do
          "did not find any dirs named `#{ path }` around the #{
          }dirs (#{ a * ' ' })"
        end
        false
      end
    end
    attr_reader :dir_pn

    -> do  # `load_downwards`
      fun = MetaHell::Boxxy::FUN
      define_method :load_downwards do
        path_a = build_difference
        @module = path_a.reduce @top_mod do |m, x|
          fun.fuzzy_const_get[ m, x ]  # #todo ui here
        end
        true
      end
    end.call
    attr_reader :module

    def build_difference
      self.class.subtract( @xpn, @top_pn ).sub_ext( '' ).to_s.
        split( ::Pathname::SEPARATOR_LIST )
    end
    private :build_difference

    -> do  # `find_top_toplevel
      fun = MetaHell::Boxxy::FUN

      define_method :find_toplevel_module do
        top_mod, top_pn = find_top
        top_mod or break
        @top_mod, @top_pn = top_mod, top_pn
        true
      end

      define_method :find_top do
        c_a = ::Object.constants.freeze
        c_h = ::Hash[
          c_a.each_with_index.map do |i, idx|
            [ fun.normulate[ i ], idx ]
          end ]
        xp = @xpn = @pn.expand_path
        p_a_ = xp.sub_ext( '' ).to_s.split ::Pathname::SEPARATOR_LIST
        p_a = p_a_.dup
        begin
          top_norm = fun.normulate[ p_a.last ]
          if c_h.key? top_norm
            break
          else
            p_a.pop
            if p_a.empty? || '' == p_a.last
              top_norm = nil
              break
            end
          end
        end while true
        -> do  # result scope
          if ! top_norm
            say :medium, "none of the elements of your path were found #{
            }to have isomorphs in the toplevel constants of the ruby #{
            }runtime - (#{ p_a_.reduce( [] ) { |m, x| m << fun.normulate[ x ] if
              '' != x ; m } * ' ' })"  # #todo:for:release
            break false
          end
          top_mod = ::Object.const_get c_a.fetch( c_h.fetch( top_norm ) )
          top_pn = ::Pathname.new( p_a.join ::Pathname::SEPARATOR_LIST )
          [ top_mod, top_pn ]
        end.call
      end
    end.call
    attr_reader :xpn, :top_pn, :top_mod

    def current_path_exists
      pn = @pn
      if pn.exist?
        say :medium, -> { "exits: #{ @pth[ pn ] }" }
        true
      else
        say :everything, -> { "not found: #{ @pth[ pn ] }" }
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

  end
end
