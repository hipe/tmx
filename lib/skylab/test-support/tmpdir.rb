# (predecessor to this line was poster-child beautification candidate [#bs-011])

module Skylab::TestSupport

  class Tmpdir < ::Pathname  # #todo this should probably move to e.g [hl] IO b.c it is no longer used exclusively in testing

    include Subsys::Services::FileUtils

    def initialize * x_a  # [ <path_x> ] [ <opt_h> ]
      st = ST__.dup
      x_a[ -1 ].respond_to? :each_pair and
        x_a.pop.each { |i, x| st[ i ] = x }
      if (( x = x_a[ -1 ] )) &&
          ( x.respond_to? :ascii_only? or x.respond_to? :sub_ext )
        st[ :path ] and raise ::ArgumentError, "collision - `path`"
        st[ :path ] = x_a.pop
      end
      x_a.length.zero? or raise ::ArgumentError, "#{ a.length } unparsed"
      @infostream, @max_mkdirs, @is_noop, pth, @be_verbose = st.to_a
      super pth || Subsys::Services::Tmpdir.tmpdir
    end

    St__ = ::Struct.new :infostream, :max_mkdirs, :noop, :path, :verbose

    ST__ = St__.new( nil, 1, false, nil, false ).freeze

    def verbose!
      debug! ; self
    end
    #
    def debug!
      self.verbose = true
      nil
    end
    #
    def verbose= x
      @be_verbose = x
    end

    def copy pathname, dest_basename = nil
      source = ::Pathname.new pathname.to_s
      dest = join( dest_basename || source.basename ) # where to? (basename)
      cp source.to_s, dest.to_s, noop: @is_noop, verbose: @be_verbose
      nil # result is undefined for now -- we might turn it into etc
    end

    def mkdir path_tail, opt_h=nil
      o_h = { noop: @is_noop, verbose: @be_verbose }
      o_h.merge!( opt_h ) if opt_h
      use_path = join( path_tail ).to_s
      a = ::FileUtils.mkdir use_path, o_h
      if a.respond_to?( :each_index ) and 1 == a.length
        self.class.new a.first   # result is undefined, this is a secret experiment
      end
    end

    def patch str
      Headless::Services::Patch.directory str, to_s, @is_noop, @be_verbose,
        -> e { info e }
      # (result is exit_status)
    end

    alias_method :tmpdir_original_touch, :touch

    def touch file
      pathname = join file
      tmpdir_original_touch pathname.to_s, noop: @is_noop, verbose: @be_verbose
      pathname
    end

    def touch_r files_x
      last_pathname = last_was_dir = true
      touch_file = -> file do
        SLASH__ == file.to_s.getbyte( 0 ) and
          Raise__[ ::ArgumentError, "must be relative - #{ file }" ]
        dest_path = join file
        if SLASH__ == dest_path.to_s.getbyte( -1 )
          last_pathname = dest_dir = dest_path
          last_was_dir = true
        else
          dest_dir = dest_path.dirname
          last_pathname = dest_file = dest_path
          last_was_dir = false
        end
        dest_dir.exist? or
          mkdir_p dest_dir, noop: @is_noop, verbose: @be_verbose
        dest_file and
          tmpdir_original_touch dest_file, noop: @is_noop, verbose: @be_verbose
        nil
      end
      if files_x.respond_to? :each_index
        files_x.each( & touch_file ) ; nil
      else
        touch_file[ files_x ]
        if last_was_dir
          self.class.new last_pathname
        else
          last_pathname
        end
      end
    end
    SLASH__ = '/'.getbyte 0

    def write local_path, file_contents
      pathname = touch_r local_path
      if pathname
        pathname.open 'w' do |fh|
          fh.write file_contents
        end
        pathname
      end
    end

    def clear
      prepare ; self
    end

    def prepare  # by this selfsame definition a "preapared" testing tmpdir
      # is one that is guaranteed to start out as empty (empty even of
      # dotfiles (i.e "hidden files")). to this end if the path of this tmpdir
      # object exists at the time this method is called it is asserted to be
      # a directory and if that directory has a nonzero number of entries
      # (including dotfiles) *** IT WILL BE `rm -rf`'d !! ***. all of this is
      # of course contingent on filesystem permissions of which this facility
      # is currently ignorant.
      @path_s ||= to_s
      if exist? then prepare_when_exist else prepare_when_not_exist end
    end

  private

    def prepare_when_exist
      if ! directory?
        Raise__[ ::Errno::ENOTDIR, @path_s ]
      elsif Sanity_check_pathname__[ self ]
        @path_a = ::Dir[ "#{ join '{*,.?*}' }" ]  # include dotfiles and '..'
        (( len = @path_a.length )).zero? and
          Raise__[ "sanity - should always have at least 1 element" ]
        if 1 == len
          prepare_when_directory_appears_empty
        else
          prepare_when_directory_has_entries
        end
      end
    end
    #
    def prepare_when_directory_appears_empty
      '/..' == @path_a.fetch( 0 )[ -3 .. -1 ] or Raise__[ "sanity - #{
        }expecting '..' (strange filesysteme?) - #{ @path_a[ 0 ] }" ]
      if_verbose_say { "(already empty: #{ @path_s })" } ; nil
    end
    #
    def prepare_when_directory_has_entries
      if_verbose_say { "rm -rf #{ @path_s }" }
      if (( SAFETY_RX__ =~ @path_s or Raise__[ "is there no god?" ] ))  # 2x
        remove_entry_secure @path_s  # TERRIFYING
        ::FileUtils.mkdir @path_s, noop: @is_noop, verbose: @be_verbose  # result is array of selfsame path
      end
    end
    #
    def prepare_when_not_exist
      sanity_check_self_for_mkdir and
        mkdir_p @path_s, noop: @is_noop, verbose: @be_verbose
    end
    #
    def sanity_check_self_for_mkdir
      0 < @max_mkdirs or Raise__[ "max_mkdirs must be at least 1." ]

      stack_a = [ ] ; pop_p = -> do
        curr_pn = self
        -> do
          if ! ( curr_pn.root? || '.' == curr_pn.instance_variable_get( :@path ) )
            stack_a << curr_pn.basename.to_s
            curr_pn = curr_pn.dirname
          end
        end
      end.call

      curr_pn = @max_mkdirs.times.reduce self do |m, _|
        ( x = pop_p[] ) ? x : ( break m )
      end

      curr_pn.exist? or Raise__[ ::SecurityError, "won't make more than #{
        }#{ @max_mkdirs } dirs - #{ curr_pn } must exist (increase your #{
          }`max_mkdirs` when you construct #{ self.class }?)" ]

      while ! stack_a.empty?
        (( peek_pn = curr_pn.join stack_a.last )).exist? or break
        stack_a.pop_p
        curr_pn = peek_pn
      end
      Sanity_check_pathname__[ curr_pn ]
    end
    #
    Sanity_check_pathname__ = -> pn do
      SAFETY_RX__ =~ pn.to_s or
        Raise__[ ::SecurityError, "unsafe tmpdir name - #{ pn }" ]
    end
    #
    SAFETY_RX__ = %r{ / (?: tmp | T ) (?: / | \z ) }x
    # avoid doing 'rm -rf' on directories other than ones that match this rx
    Raise__ = -> *a do  # it is possible that `raise` could be overridden
      # (as ill-advised as that would be). to get "absolute certainty" in
      # ruby is perhaps impossible, for even constants can be re-defined at
      # runtime with only a warning (rendering this whole technique
      # vulnerable); however we use this proc in a constant as a magical
      # talisman aginst these concerns; because if we send a `raise` that
      # does not cause a return, consequences could be disastrous, e.g
      # doing an 'rm -rf' on the wrong directory.
      nil.send :raise, * a  # ::Kernel can even be overridden, meh so can this method :/
      false  # in case something is spectacularly wrong we check the result too
    end

    def if_verbose_say &p
      @be_verbose and fu_output_message( p.call ) ; nil
    end
    #
    def fu_output_message msg
      info msg
    end
    #
    def info msg
      (( @infostream ||= Subsys::Stderr_[] )).puts msg
    end
  end
end
