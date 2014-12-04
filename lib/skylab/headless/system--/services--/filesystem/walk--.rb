module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Walk__  # :[#176] (was [#ts-019], then [#st-007])

        Callback_::Actor[ self,
          :properties,
            :filename,
            :max_num_dirs_to_look,
            :prop,
            :start_path,
            :on_event_selectively ]

        Headless_._lib.event_lib.selective_builder_sender_receiver self

        def find_any_nearest_file_pathname  # :+#public-API
          execute
        end

        def execute
          normalize_ivars
          work
        end

      private

        def normalize_ivars
          if SLASH_ != @start_path.getbyte( 0 )
            @start_path = ::File.expand_path @start_path
          end
          @start_pathname = ::Pathname.new @start_path
        end

        SLASH_ = '/'.getbyte 0

        def work
          st = ::File::Stat.new @start_path
          if DIRECTORY_FTYPE__ == st.ftype
            fnd_any_nearest_file_pathname_when_start_pathname_exist
          else
            whn_start_directory_is_not_directory st
          end
        rescue ::Errno::ENOENT => e
          whn_start_directory_does_not_exist e
        end
        DIRECTORY_FTYPE__ = 'directory'.freeze

        def whn_start_directory_is_not_directory st
          maybe_send_event :error, :start_directory_is_not_directory do
            build_not_OK_event_with :start_directory_is_not_directory,
              :start_pathname, @start_pathname, :ftype, st.ftype,
                :prop, @prop
          end
        end

        def whn_start_directory_does_not_exist e
          maybe_send_event :error, :start_directory_is_not_directory do
            build_not_OK_event_with :start_directory_does_not_exist,
              :start_pathname, @start_pathname, :exception, e,
                :prop, @prop
          end
        end

        def fnd_any_nearest_file_pathname_when_start_pathname_exist
          count = 0

          continue_searching = if -1 == @max_num_dirs_to_look
            NILADIC_TRUTH_
          else
            -> { count < @max_num_dirs_to_look }
          end
          pn = @start_pathname
          while continue_searching[]
            count += 1
            try = pn.join @filename
            try.exist? and break( found = try )
            pn_ = pn.dirname
            pn_ == pn and break  # we've reached the top - the root path
            pn = pn_
          end
          if found
            whn_found found
          else
            whn_resource_not_found count
          end
        end

        def whn_found found
          ok = Headless_.system.filesystem.normalization.upstream_IO(
            :only_apply_expectation_that_path_is_file,
            :path, found.to_path,
            :on_event, -> ev do
              maybe_send_event normal_top_channel_via_OK_value ev.ok do
                ev
              end
              UNABLE_
            end )
          ok && found
        end

        def whn_resource_not_found count
          maybe_send_event :error, :resource_not_found do
            bld_resource_not_found_event count
          end
        end

        def bld_resource_not_found_event count
          build_not_OK_event_with :resource_not_found, :filename, @filename,
              :num_dirs_looked, count, :start_pathname, @start_pathname do |y, o|
            if o.num_dirs_looked.zero?
              y << "no directories were searched."
            else
              if 1 < o.num_dirs_looked
                d = o.num_dirs_looked - 1
                x = " or #{ d } dir#{ s d } up"
              end
              y << "#{ ick o.filename } not found in #{ pth o.start_pathname}#{x}"
            end
          end
        end
      end
    end
  end
end

if false
module Skylab::SubTree

  class Walker

    # unifying something we've done in three places.

    # experimental interface, pub-sub-like, *somewhat*

    # #deprecated for [br], see [#cu-003]

    def self.new * a
      if 1 == a.length
        super a.first
      else
        super a
      end
    end

    CONDUIT__ = {
      listener: -> a { @listener = a.shift ; nil },
      pth: -> a { @pth = a.shift ; nil },
      path: -> a { @path_to_set = a.shift ; nil },
      top: -> a { @top = a.fetch 0 ; a.shift },
      when_relative: -> a { @convert_relpath_p = a.shift ; nil },
      vtuple: -> a { @vtuple = a.shift ; nil }
    }.freeze

    def initialize a
      @convert_relpath_p = @files_file_IO = @path_set = nil
      while a.length.nonzero?
        instance_exec( a, & CONDUIT__.fetch( a.shift ) )
      end
      if (( x = @path_to_set ))  # absorb whole iambic before setting path
        @path_to_set = nil ; set_path x ; nil
      end
    end
    attr_reader :pn, :top

    def set_path x
      @path = x
      @pn = ::Pathname.new x
      @pn.absolute? or resolve_some_absolute_path ; nil
    end
  private
    def resolve_some_absolute_path
      @convert_relpath_p and @pn = @convert_relpath_p[ @pn ]
      @pn.absolute? or raise "we don't want to mess with relpaths here #{
        }for now - \"#{ @pn }\"" ; nil
    end
  public

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
      SubTree_._lib.power_scanner :init, -> do
        files_file_pn && top_pn or fail "sanity"
        @tpn = Pathname__.new @top_pn
        rwnd_files_file_IO
      end, :gets, -> do
        while true
          @files_file_IO or break
          line = @files_file_IO.gets
          line or break cls_and_discard_files_file_IO
          pn = prcr_any_pathname_from_file_line line
          pn and break
        end
        pn
      end
    end

    attr_reader :files_file_IO

  private

    def rwnd_files_file_IO
      if @files_file_IO
        @files_file_IO.rewind
      else
        @files_file_IO = @files_file_pn.open 'r'
      end ; nil
    end

    def cls_and_discard_files_file_IO
      @files_file_IO.close ; @files_file_IO = nil
    end

    def prcr_any_pathname_from_file_line line
      line.chomp!
      if line.include? SPACE_
        prcr_any_pathname_when_line_includes_space line
      else
        @tpn.join_ line
      end
    end

    def prcr_any_pathname_when_line_includes_space line
      line, rest_s = line.split SPACE_, 2
      pn = @tpn.join_ line
      pn.add_note :notice, "line had space", :line_had_space, :rest_s, rest_s
      pn
    end

    class Pathname__ < ::Pathname

      attr_reader :has_notes, :note_a

      def add_note chan_i, msg_s, type_i=nil, *rest
        @has_notes ||= true
        @note_a ||= []
        @note_a << Note__.new( chan_i, msg_s, type_i, rest )
        nil
      end

      def join_ x
        p = join( x ).instance_variable_get :@path
        self.class.allocate.instance_exec do
          @path = p
          self
        end
      end
    end

    Note__ = ::Struct.new :channel_i, :message_s, :type_i, :x_a

  public

    def subtree_pathnames
      path = scn = slice = nil
      SubTree_._lib.power_scanner :init, -> do
        path = @pn.instance_variable_get :@path
        _length = path.length - SEPWIDTH_
        slice = 0 .. _length
        scn = pathnames
      end, :gets, -> do
        while true
          pn = scn.gets or break
          part = pn.instance_variable_get( :@path )[ slice ]
          path == part or next
          break( r = pn )
        end
        r
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
          }dirs (#{ a * SPACE_ })"
        end
        false
      end
    end
    attr_reader :dir_pn

    def load_downwards * x_a
      -> do  # #result-block
        path_a = build_difference or break path_a
        @module = Autoloader_.const_reduce do |cr|
          cr.from_module @top_mod
          cr.const_path path_a
          cr.else do |name_er|
            say :notice, -> { name_er.message } ; nil
          end
        end
        @module ? true : @module
      end.call
    end
    attr_reader :module

    def build_difference
      self.class.subtract( @xpn, @top_pn ).sub_ext( EMPTY_S_ ).to_s.
        split( ::Pathname::SEPARATOR_LIST )
    end
    private :build_difference

    -> do  # `find_top_toplevel
      slash = ::Pathname::SEPARATOR_LIST

      define_method :find_toplevel_module do
        top_mod, top_pn = find_top
        top_mod or break
        @top_mod = top_mod ; @top_pn = top_pn
        true
      end

      report_error = -> p_a_, top_norm_a do
        _big = -> do
          p_a_.reduce( [] ) do |m, x|
            m << Distill__[ x ] if EMPTY_S_ != x ; m
          end * SPACE_
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
          if p_a.empty? || EMPTY_S_ == p_a.last
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
              "(the normulated toplevel constants are: #{ c_h.keys * SPACE_ })"
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
              "\"#{ nerk }\" not found in (#{ npa * SPACE_ })"
            end ]
          when 1  # fallthru
          else
            break bork[ -> do
              "\"#{ nerk }\" found multiple times in (#{ npa * SPACE_ })"
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
        p_a = xp.sub_ext( EMPTY_S_ ).to_s.split slash
        mod, pn = if @top
          instance_exec p_a, c_a, c_h, @top, &know_top
        else
          instance_exec p_a, c_a, c_h, & guess_top
        end
        if false != mod
          pn.instance_variable_defined?( :@path ) or fail "where is path?"
          pn.instance_variable_get( :@path ).length.zero? and fail "sanity"
          [ mod, pn ]
        end
      end
    end.call
    attr_reader :xpn, :top_pn, :top_mod

    Distill__ = -> do
      p = -> x do
        ( p = SubTree_._lib.distill_proc )[ x ]
      end
      -> x { p[ x ] }
    end.call

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
      @listener.maybe_receive_event Event__.new( volume, msg_func )
      nil
    end
    private :say

    Event__ = ::Struct.new :volume, :message_proc

    def vtuple  # #called-by self internally
      @vt
    end
  end
end
end
