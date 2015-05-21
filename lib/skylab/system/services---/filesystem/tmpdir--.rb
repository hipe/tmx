# (predecessor to this line was poster-child beautification candidate [#bs-011])

module Skylab::System


    class Services___::Filesystem

      class Tmpdir__ < ::Pathname

        alias_method :init_pathname, :initialize

        # <- 2

    include System_.lib_.file_utils

    System_.lib_.entity self do

      o :polymorphic_writer_method_name_suffix, :'=',

        :property, :debug_IO,

        :property, :max_mkdirs

      def noop=
        @is_noop = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def path=
        @path_x = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      o :property, :be_verbose

      def verbose=
        @be_verbose = true
        KEEP_PARSING_
      end
    end

    def initialize * x_a, & p
      @is_noop = false
      @be_verbose = false

      if x_a.length.nonzero?
        process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
      end

      if p  # prolly mutex w/ above
        instance_exec( & p )
      end

      @debug_IO ||= System_.services.IO.some_stderr_IO
      @max_mkdirs ||= 1
      @path_x ||= System_.services.filesystem.tmpdir_path
      super @path_x do end
      init_path_derivatives
      freeze
    end

    attr_reader :be_verbose, :to_pathname

    def path
      @path_s
    end

    def tmpdir_via_join path_tail, * x_a
      otr = dup
      x_a.push :path, ::File.join( @path_s, path_tail )
      otr._init_copy_via_iambic x_a
      otr
    end

    def new_with * x_a
      otr = dup
      otr._init_copy_via_iambic x_a
      otr
    end
  protected
    def _init_copy_via_iambic x_a
      process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
      if @path_x
        init_pathname @path_x
        init_path_derivatives
      end
      freeze
    end
  private
    def init_path_derivatives
      @path_x = nil
      @path_s = to_path.freeze
      @to_pathname = ::Pathname.new @path_s ; nil
    end
  public

    def copy pathname, dest_basename=nil
      source = ::Pathname.new pathname.to_s
      dest = join dest_basename || source.basename
      cp source.to_s, dest.to_s, noop: @is_noop, verbose: @be_verbose
      dest
    end

    def mkdir path_tail, opt_h=nil
      o_h = { noop: @is_noop, verbose: @be_verbose }
      o_h.merge!( opt_h ) if opt_h
      use_path = join( path_tail ).to_s
      a = ::FileUtils.mkdir use_path, o_h
      if a.respond_to?( :each_index ) and 1 == a.length
        ::Pathname.new a.first  # result is undefined, this is a secret experiment
      end
    end

    def patch_via_path path
      _patch :patch_file, path
    end

    def patch str
      _patch :patch_string, str
    end

  private

    def _patch * x_a

      System_.services.patch(

          :target_directory, to_path,
           :is_dry_run, @is_noop,

           * x_a ) do | * i_a, & ev_p |

        if :info == i_a.first
          if @be_verbose
            ev_p[].render_each_line_under ___expag do | line |
              send_debug_string line
            end
          end
        else
          raise ev_p[].to_exception
        end
      end
    end

    def ___expag
      services.lib_.brazen::API.expression_agent_instance
    end

  public

    alias_method :tmpdir_original_touch, :touch

    def touch path_tail
      pathname = join path_tail
      tmpdir_original_touch pathname.to_path, noop: @is_noop, verbose: @be_verbose
      pathname
    end

    def write local_path, file_contents
      pn = touch_r local_path
      if pn
        pn.open ::File::CREAT | ::File::TRUNC | ::File::WRONLY do |fh|
          fh.write file_contents
        end
        pn
      end
    end

    def touch_r files_x

      last_pathname = last_was_dir = true
      touch_file = -> path_tail do

        FILE_SEPARATOR_BYTE == path_tail.to_s.getbyte( 0 ) and
          Raise__[ ::ArgumentError, say_not_relative( path_tail ) ]

        dest_path = join path_tail
        if FILE_SEPARATOR_BYTE == dest_path.to_s.getbyte( -1 )
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
          new_with :path, last_pathname
        else
          last_pathname
        end
      end
    end

    def say_not_relative file
      "must be relative - #{ file }"
    end

    def clear
      prepare
      self
    end

    def prepare  # #note-130, keep eye on :+[#sy-004]:directory
      if exist?
        prepare_when_exist
      else
        prepare_when_not_exist
      end
    end

    def prepare_when_not_exist  # :+#public-API
      if sanity_check_self_for_mkdir
        mkdir_p @path_s, noop: @is_noop, verbose: @be_verbose
      end
    end

    def UNLINK_FILES_RECURSIVELY_
      if_verbose_say { say_rm_minus_rf }
      if SAFETY_RX__ =~ @path_s
        remove_entry_secure @path_s  # TERRIFYING (result is nil)
        PROCEDE_
      else
        Raise__[ ask_if_there_is_a_god ]
      end
    end

  private

    def prepare_when_exist
      if directory?
        prepare_when_exists_and_is_directory
      else
        Raise__[ ::Errno::ENOTDIR, @path_s ]
      end
    end

    def prepare_when_exists_and_is_directory

      if Sanity_check_pathname__[ self ]

        _path_ = System_.lib_.shellwords.shellescape @path_s

        path_a = ::Dir[ "#{ _path_ }/{*,.?*}" ]  # include dotfiles and '..'

        case 1 <=> path_a.length
        when -1 ; prepare_when_directory_has_entries
        when  0 ; prepare_when_directory_appears_empty path_a
        when  1 ; Raise__[ say_no_elements ]
        end
      end
    end

    def say_no_elements
      "sanity - should always have at least 1 element"
    end

    def prepare_when_directory_appears_empty path_a
      if SLASH_DOT_DOT__ == path_a.fetch( 0 )[ -3 .. -1 ]
        if_verbose_say do
          say_already_empty
        end
      else
        Raise__[ say_strange_filesystem( path_a ) ]
      end
    end
    SLASH_DOT_DOT__ = '/..'.freeze

    def say_strange_filename path_a
      "sanity - expecting '..' (strange filesystem?) - #{ path_a.first }"
    end

    def say_already_empty
      "(already empty: #{ @path_s })"
    end

    def prepare_when_directory_has_entries
      ok = self.UNLINK_FILES_RECURSIVELY_
      ok and begin
        ::FileUtils.mkdir @path_s, noop: @is_noop, verbose: @be_verbose  # result is array of selfsame path
      end
    end

    def say_rm_minus_rf
      "rm -rf #{ @path_s }"
    end

    def ask_if_there_is_a_god
      "is there no god?"
    end

    def sanity_check_self_for_mkdir
      0 < @max_mkdirs or Raise__[ say_must_be_at_least ]

      stack_a = [] ; pop_p = -> do
        curr_pn = self
        -> do
          if ! ( curr_pn.root? || DOT_ == curr_pn.instance_variable_get( :@path ) )
            stack_a.push curr_pn.basename.to_s
            curr_pn = curr_pn.dirname
          end
        end
      end.call

      curr_pn = @max_mkdirs.times.reduce self do |m, _|
        ( x = pop_p[] ) ? x : ( break m )
      end

      curr_pn.exist? or Raise__[ ::SecurityError, say_wont_make_more( curr_pn ) ]

      while ! stack_a.empty?
        peek_pn = curr_pn.join stack_a.last
        peek_pn.exist? or break
        stack_a.pop
        curr_pn = peek_pn
      end

      Sanity_check_pathname__[ curr_pn ]
    end

    def say_must_be_at_least
      "max_mkdirs must be at least 1."
    end

    def say_wont_make_more curr_pn
      "won't make more than #{ @max_mkdirs } dirs - #{
        }#{ curr_pn } must exist (increase your #{
         }`max_mkdirs` when you construct #{ self.class }?)"
    end

    Sanity_check_pathname__ = -> pn do
      if SAFETY_RX__ =~ pn.to_path
        PROCEDE_
      else
        Raise__[ ::SecurityError, "unsafe tmpdir name - #{ pn }" ]
        UNABLE_
      end
    end

    SAFETY_RX__ = %r{ / (?: tmp | T ) (?: / | \z ) }x
    # avoid doing 'rm -rf' on directories other than ones that match this rx

    Raise__ = -> *a do  # #note-210
      nil.send :raise, * a
      UNABLE_
    end

    def if_verbose_say &p
      @be_verbose and fu_output_message( p.call ) ; nil
    end

    def fu_output_message msg
      send_debug_string msg
    end

    def send_debug_string msg
      @debug_IO.puts msg ; nil
    end

  public

    def basename
      @to_pathname.basename
    end

    def children with_directory=false
      @to_pathname.children with_directory
    end

    def dirname
      @to_pathname.dirname
    end

    # -> 2

      end
    end
end