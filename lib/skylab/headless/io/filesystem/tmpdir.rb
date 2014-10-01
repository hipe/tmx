# (predecessor to this line was poster-child beautification candidate [#bs-011])

module Skylab::Headless

  class IO::Filesystem::Tmpdir < ::Pathname

    include Headless_::Library_::FileUtils

    Headless_::Lib_::Entity[ self, -> do

      o :iambic_writer_method_name_suffix, :'=',

        :property, :debug_IO,

        :property, :max_mkdirs

      def noop=
        @is_noop = iambic_property
      end

      def path=
        @path_x = iambic_property
      end

      o :property, :be_verbose

    end ]

    class << self

      alias_method :via_iambic, :new

      def new * x_a
        via_iambic x_a
      end
    end

    alias_method :omg, :initialize

    def initialize x_a
      ::Array === x_a or raise 'where'
      1 == x_a.length and self._WHERE
      @is_noop = false
      @be_verbose = false
      process_iambic_fully x_a
      @debug_IO ||= Headless_::System::IO.some_stderr_IO
      @max_mkdirs ||= 1
      @path_x ||= Headless_::System.defaults.tmpdir_path
      super @path_x
      init_path_derivatives
      freeze
    end

    attr_reader :be_verbose, :to_pathname

    def with * x_a
      otr = dup
      otr.init_copy x_a
      otr
    end
  protected
    def init_copy x_a
      process_iambic_fully 0, x_a
      if @path_x
        omg @path_x
        @path_x = nil
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
        ::Pathname.new a.first  # result is undefined, this is a secret experiment
      end
    end

    def patch str  # result is exit_status
      Headless_::Text::Patch.directory str, to_path,
        @is_noop, @be_verbose, method( :send_debug_string )
    end

    alias_method :tmpdir_original_touch, :touch

    def touch path_tail
      pathname = join path_tail
      tmpdir_original_touch pathname.to_path, noop: @is_noop, verbose: @be_verbose
      pathname
    end

    def write local_path, file_contents
      pn = touch_r local_path
      if pn
        pn.open WRITEMODE_ do |fh|
          fh.write file_contents
        end
        pn
      end
    end

    def touch_r files_x

      last_pathname = last_was_dir = true
      touch_file = -> path_tail do

        SLASH__ == path_tail.to_s.getbyte( 0 ) and
          Raise__[ ::ArgumentError, say_not_relative( path_tail ) ]

        dest_path = join path_tail
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
          with :path, last_pathname
        else
          last_pathname
        end
      end
    end

    SLASH__ = '/'.getbyte 0

    def say_not_relative file
      "must be relative - #{ file }"
    end

    def clear
      prepare
      self
    end

    def prepare  # #note-130
      if exist?
        prepare_when_exist
      else
        prepare_when_not_exist
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

        path_a = ::Dir[ "#{ join '{*,.?*}' }" ]  # include dotfiles and '..'

        d = path_a.length

        d.zero? and Raise__[ say_no_elements ]

        case 1 <=> d
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
      if_verbose_say { say_rm_minus_rf }
      if SAFETY_RX__ =~ @path_s
        remove_entry_secure @path_s  # TERRIFYING
        ::FileUtils.mkdir @path_s, noop: @is_noop, verbose: @be_verbose  # result is array of selfsame path
      else
        Raise__[ ask_if_there_is_a_god ]
      end
    end

    def say_rm_minus_rf
      "rm -rf #{ @path_s }"
    end

    def ask_if_there_is_a_god
      "is there no god?"
    end

    def prepare_when_not_exist
      if sanity_check_self_for_mkdir
        mkdir_p @path_s, noop: @is_noop, verbose: @be_verbose
      end
    end

    def sanity_check_self_for_mkdir
      0 < @max_mkdirs or Raise__[ say_must_be_at_least ]

      stack_a = [] ; pop_p = -> do
        curr_pn = self
        -> do
          if ! ( curr_pn.root? || DOT__ == curr_pn.instance_variable_get( :@path ) )
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

    DOT__ = '.'.freeze

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

    def dirname
      @to_pathname.dirname
    end

    def join path_tail
      @to_pathname.join path_tail
    end

    PROCEDE_ = true
    UNABLE_ = false
  end
end
