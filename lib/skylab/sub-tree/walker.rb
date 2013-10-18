module Skylab

module SubTree  # borrow x 1 - load this solo but it needs meta hell

  class Walker

    # unifying something we've done in three places.

    # experimental interface, pub-sub-like, *somewhat*

    CONDUIT_ = {
      pth: -> a { @pth = a.fetch 0 ; a.shift },
      path: -> a { set_path a.fetch 0 ; a.shift },
      top: -> a { @top = a.fetch 0 ; a.shift },
      vtuple: -> a { @vtuple = a.fetch 0 ; a.shift },
      listener: -> a { @listener = a.fetch 0 ; a.shift }
    }.freeze

    def initialize *a
      while a.length.nonzero?
        instance_exec( a, & CONDUIT_.fetch( a.shift ) )
      end
    end
    attr_reader :pn, :top

    def set_path x
      @path = x  # #todo:during:3
      @pn = ::Pathname.new x
      @pn.absolute? or raise "we don't want to mess with relpaths here #{
        }for now - \"#{ x }\""
      nil
    end

    #                     ~ steps. (section 1) ~

    def expect_upwards relative
      found, count = search_upwards relative
      -> do
        found and break found
        p = @pn
        say :notice, -> do
          "\"#{ relative }\" not found within #{ count } dirs of #{
            }#{ @pth[ p ] }"
        end
        nil
      end.call
    end

    def search_upwards relative, limit=nil
      (( pn = @pn )).absolute? or fail "sanity - #{ pn }"
      count = 0
      limit_ok = limit ? -> { count < limit } : -> { true }
      while limit_ok[]
        try = pn.join relative
        try.exist? and break( found = try )
        count += 1
        TOP__ == pn.instance_variable_get( :@path ) and break
        pn = pn.dirname
      end
      found and maybe_set_top_pn found, relative
      [ found, count ]
    end

    TOP__ = '/'.freeze

    def maybe_set_top_pn pn, relative
      if ! top_pn
        p = pn.instance_variable_get :@path
        is_at_the_end_of relative, p or fail "sanity - #{ relative } in #{ p }"
        @top_pn = ::Pathname.new p[ 0 ... -1 * relative.length - 1 ]  # '/'
      end
    end

    def is_at_the_end_of relative, p
      p.rindex( relative ) == p.length - relative.length
    end

    def expect_files_file pn
      if pn.exist?
        @files_file_pn = pn
        true
      else
        @files_file_pn = nil
        say :notice, -> do
          "expected files file not found: #{ @pth[ pn ] }"
        end
        nil
      end
    end

    attr_reader :files_file_pn

    def pathnames
      ::Enumerator.new do |y|
        files_file_pn && top_pn or fail "sanity"
        tpn = Pathname__.new( @top_pn )
        @files_file_pn.open do |fh|
          while (( line = fh.gets ))
            line.chomp!
            if line.include? SPACE_
              line, rest = line.split SPACE_, 2
              pn = tpn._join line
              pn.add_note :notice, "line had space", :line_had_space,
                :rest, rest
            else
              pn = tpn._join line
            end
            y << pn
          end
        end
        nil
      end
    end

    SPACE_ = ' '.freeze

    class Pathname__ < ::Pathname

      attr_reader :has_notes, :note_a

      def add_note severity, message, *rest
        @has_notes ||= true
        @note_a ||= [ ]
        @note_a << [ severity, message, * rest ]
        nil
      end

      def _join x
        p = join( x ).instance_variable_get :@path
        self.class.allocate.instance_exec do
          @path = p
          self
        end
      end
    end

    def subtree_pathnames
      ::Enumerator.new do |y|
        p = @pn.instance_variable_get :@path ; len = p.length - SEPWIDTH_
        pathnames.each do |pn|
          pt = pn.instance_variable_get( :@path )[ 0 .. len ]
          if pt == p
            y << pn
          end
        end
        nil
      end
    end

    SEPWIDTH_ = 1

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
        @module = path_a.reduce @top_mod do |m, file_s|
          _i, m = MetaHell::Boxxy::FUN.
            fuzzy_const_get_name_and_value_with_prying_hack[
              m, file_s, -> name_er do
                say :notice, -> { name_er.message }
                nil
              end ]
          m or break( false )
        end
        @module ? true : @module
      end.call
    end
    attr_reader :module

    def build_difference
      self.class.subtract( @xpn, @top_pn ).sub_ext( '' ).to_s.
        split( ::Pathname::SEPARATOR_LIST )
    end
    private :build_difference

    -> do  # `find_top_toplevel
      slash = ::Pathname::SEPARATOR_LIST

      define_method :find_toplevel_module do
        top_mod, top_pn = find_top
        top_mod or break
        @top_mod, @top_pn = top_mod, top_pn
        true
      end

      report_error = -> p_a_, top_norm_a do
        _big = -> do  # #todo:for:release
          p_a_.reduce( [] ) do |m, x|
            m << Distill__[ x ] if '' != x ; m
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

      guess_top = -> p_a_, c_a, c_h do  # #result-is-tuple of `mod` / `pn`
        p_a = p_a_.dup
        top_norm_a = []
        begin
          top_norm = Distill__[ p_a.fetch( -1 ) ]
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
        nerk = Distill__[ top ]
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
          npa = p_a.map( & Distill__ )
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
            [ Distill__[ i ], idx ]
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
    #
    Distill__ = MetaHell::Boxxy::FUN.distill

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
      @listener.call Event__.new( volume, msg_func )
      nil
    end
    private :say

    Event__ = ::Struct.new :volume, :message_proc

    def vtuple  # #called-by self internally
      @vt
    end
  end
end  # give back x 1
end
