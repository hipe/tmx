# (predecessor to this line was poster-child beautification candidate [#bs-011])

module Skylab::System

  class Services___::Filesystem

    class Models_::Tmpdir < ::Pathname  # (implementd as a frozen, dupable session)

      class << self

        def memoizer_for td, slug
          Memoizer___.new td, slug
        end

        def for_mutable_args_ x_a, & x_p
          if x_a.length.zero?
            self
          else
            new_via_iambic x_a, & x_p
          end
        end

        def new_with * x_a  # we would use la la but for #here
          new_via_iambic x_a
        end

        alias_method :new_via_iambic, :new
        undef_method :new
      end  # >>

      # --

      #   • near [#fi-022], we do defaulting "by hand"
      #
      #   • we can't implement as plain old actor because of the call to
      #     super below that must happen after all args are processed (:#here)
      #     which is a reminder of why inheritence is bad.

      ATTRIBUTES__ = Attributes_.call(
        be_verbose: nil,
        debug_IO: nil,
        max_mkdirs: nil,
        noop: [ :flag, :ivar, :@is_noop ],
        path: [ :ivar, :@_path_x ],
        verbose: [ :flag_of, :be_verbose ],
      )

      alias_method :__init_pathname, :initialize

      def initialize x_a

        block_given? and self._NO  # #todo

        @is_noop = false
        @be_verbose = false

        _kp = ATTRIBUTES__.init self, x_a
        _kp or self._FAIL

        @debug_IO ||= Home_.services.IO.some_stderr_IO
        @max_mkdirs ||= 1
        @_path_x ||= Home_.services.filesystem.tmpdir_path
        super @_path_x
        _init_path_derivatives
        freeze
      end

      # -- Simple readers

      attr_reader :be_verbose

      def basename
        @to_pathname.basename
      end

      def children with_directory=false
        @to_pathname.children with_directory
      end

      def dirname
        @to_pathname.dirname
      end

      def path
        @_path_s
      end

      attr_reader :to_pathname

    public

      def to_memoizer

        hot = nil ; cold = nil

        -> tcc do
          if tcc.do_debug
            if ! hot
              hot = new_with(
                :be_verbose, true,
                :debug_IO, tcc.debug_IO,
              )
            end
            hot
          else
            if ! cold
              cold = new_with(
                :be_verbose, false,
                :debug_IO, tcc.debug_IO
              )
            end
            cold
          end
        end
      end

      def rebuilt_for tc  # the above is an experimental replacement for this #todo

        yes = do_debug
        yes_ = td.be_verbose

        if yes
          if ! yes_
            new_with :debug_IO, debug_IO, :be_verbose, true
          end
        elsif yes_ && ! yes
          td.new_with :be_verbose, false
        end
      end

      def tmpdir_via_join path_tail, * x_a
        otr = dup
        x_a.push :path, ::File.join( @_path_s, path_tail )
        otr._init_copy_via_iambic x_a
        otr
      end

      def new_with * x_a
        otr = dup
        otr._init_copy_via_iambic x_a
        otr
      end

      def _init_copy_via_iambic x_a

        _kp = ATTRIBUTES__.init self, x_a
        _kp or self._SANITY

        if @_path_x
          __init_pathname @_path_x
          _init_path_derivatives
        end

        freeze
      end

      def _init_path_derivatives
        @_path_x = nil
        @_path_s = to_path.freeze
        @to_pathname = ::Pathname.new @_path_s
        NIL_
      end

      # -- Exposures

      # ~ preparation & related

      def clear

        prepare
        self
      end

      def prepare  # #note-130, keep eye on :+[#sy-004]:directory

        if exist?
          __prepare_when_exist
        else
          prepare_when_not_exist
        end
      end

      def prepare_when_not_exist  # :+#public-API

        if __sanity_check_self_for_mkdir
          mkdir_p @_path_s, noop: @is_noop, verbose: @be_verbose
        end
      end

      def UNLINK_FILES_RECURSIVELY_  # used by some VERY CLOSE collaborators

        _if_verbose_say { __say_rm_minus_rf }

        if SAFETY_RX__ =~ @_path_s
          remove_entry_secure @_path_s  # TERRIFYING (result is nil)
          ACHIEVED_
        else
          Raise__[ __ask_if_there_is_a_god ]
        end
      end

      def __say_rm_minus_rf

        "rm -rf #{ @_path_s }"
      end

      def __ask_if_there_is_a_god

        "is there no god?"
      end

      def __prepare_when_exist

        if directory?
          __prepare_when_exists_and_is_directory
        else
          Raise__[ ::Errno::ENOTDIR, @_path_s ]
        end
      end

      def __prepare_when_exists_and_is_directory

        if Sanity_check_pathname__[ self ]

          _path_ = Home_.lib_.shellwords.shellescape @_path_s

          path_a = ::Dir[ "#{ _path_ }/{*,.?*}" ]  # include dotfiles and '..'

          case 1 <=> path_a.length
          when -1
            __prepare_when_directory_has_entries

          when  0
            __prepare_when_directory_appears_empty path_a

          when  1
            Raise__[ __say_no_elements ]
          end
        end
      end

      def __say_no_elements

        "sanity - should always have at least 1 element"
      end

      def __prepare_when_directory_appears_empty path_a

        if SLASH_DOT_DOT__ == path_a.fetch( 0 )[ -3 .. -1 ]
          _if_verbose_say do
            __say_already_empty
          end
        else
          Raise__[ __say_strange_filesystem( path_a ) ]
        end
      end
      SLASH_DOT_DOT__ = '/..'.freeze

      def __say_strange_filename path_a

        "sanity - expecting '..' (strange filesystem?) - #{ path_a.first }"
      end

      def __say_already_empty

        "(already empty: #{ @_path_s })"
      end

      def __prepare_when_directory_has_entries

        ok = self.UNLINK_FILES_RECURSIVELY_
        ok and begin
          ::FileUtils.mkdir @_path_s, noop: @is_noop, verbose: @be_verbose  # result is array of selfsame path
        end
      end

      def __sanity_check_self_for_mkdir

        0 < @max_mkdirs or Raise__[ __say_must_be_at_least ]

        stack_a = [] ; pop_p = -> do

          curr_pn = self

          -> do

            _qualifies = curr_pn.root? ||
              DOT_ == curr_pn.instance_variable_get( :@path )

            if ! _qualifies

              stack_a.push curr_pn.basename.to_path
              curr_pn = curr_pn.dirname
            end
          end
        end.call

        curr_pn = @max_mkdirs.times.reduce self do |m, _|
          ( x = pop_p[] ) ? x : ( break m )
        end

        if ! curr_pn.exist?
          Raise__[ ::SecurityError, __say_wont_make_more( curr_pn ) ]
        end

        while ! stack_a.empty?
          peek_pn = curr_pn.join stack_a.last
          peek_pn.exist? or break
          stack_a.pop
          curr_pn = peek_pn
        end

        Sanity_check_pathname__[ curr_pn ]
      end

      def __say_must_be_at_least

        "max_mkdirs must be at least 1."
      end

      def __say_wont_make_more curr_pn

        "won't make more than #{ @max_mkdirs } dirs - #{
          }#{ curr_pn } must exist (increase your #{
           }`max_mkdirs` when you construct #{ self.class }?)"
      end

      Sanity_check_pathname__ = -> pn do

        if SAFETY_RX__ =~ pn.to_path
          ACHIEVED_

        else
          Raise__[ ::SecurityError, "unsafe tmpdir name - #{ pn }" ]
          UNABLE_
        end
      end

      # IMPORTANT - let's try really hard not to do a 'rm -rf' on any
      # directory other than ones that match this regex, that is, it
      # must have 'tmp' or 'T' as a full word match of any one entry

      SAFETY_RX__ = %r{ / (?: tmp | T ) (?: / | \z ) }x

      Raise__ = -> *a do  # #note-210
        nil.send :raise, * a
        UNABLE_
      end

      # -- Producing directories & files

      def copy_r path, dest_basename=nil  # no dry run.

        self._WORKED_AT_WRITING_but_not_covered  # [se] used then didn't use

        _dest_path = if dest_basename
          join( dest_basename ).to_path
        else
          self.path
        end

        _FS = Home_.services.filesystem

        _fuc = _FS.file_utils_controller do | fu_message |
          # (hi.)
          if @be_verbose
            @debug_IO.puts fu_message
          end
        end

        _x = _fuc.cp_r path, _dest_path, verbose: true

        _x  # (is nil)
      end

      def copy src_path_s, dest_basename=nil

        if src_path_s.respond_to? :to_path
          src_path_s = src_path_s.to_path
        end

        dst_pn = if dest_basename
          join dest_basename
        else
          join ::File.basename src_path_s
        end

        cp src_path_s, dst_pn.to_path, noop: @is_noop, verbose: @be_verbose

        # ( result of above is nil on success )

        dst_pn
      end

      def mkdir path_tail, opt_h=nil

        opt_h_ = { noop: @is_noop, verbose: @be_verbose }

        if opt_h
          opt_h_.merge! opt_h
        end

        _use_path = join( path_tail ).to_path

        a = ::FileUtils.mkdir _use_path, opt_h_

        # our result is as yet officially undefined -
        # the below is a secret :+#experimental

        if a.respond_to?( :each_index ) and 1 == a.length
          ::Pathname.new a.first
        else
          a
        end
      end

      def patch_via_path path

        _patch :patch_file, path
      end

      def patch s

        _patch :patch_string, s
      end

      def _patch * x_a

        Home_.services.filesystem.patch(
          :target_directory, to_path,
          :is_dry_run, @is_noop,
          * x_a

        ) do | * i_a, & ev_p |

          if :info == i_a.first

            if @be_verbose
              __express_event_as_string ev_p[]
            end
          else
            raise ev_p[].to_exception
          end
        end
      end

      # ~~ touch & related

      def write local_path, file_contents_s

        pn = touch_r local_path

        if pn
          pn.open ::File::CREAT | ::File::TRUNC | ::File::WRONLY do | fh |
            fh.write file_contents_s
          end
        end
        pn
      end

      def touch_r files_x

        last_pathname = last_was_dir = true

        touch_file = -> path_tail_x do

          path_tail_s = path_tail_x.to_s

          if FILE_SEPARATOR_BYTE == path_tail_s.getbyte( 0 )

            Raise__[ ::ArgumentError, __say_not_relative( path_tail_s ) ]
          end

          dest_path = join path_tail_s

          if FILE_SEPARATOR_BYTE == dest_path.to_path.getbyte( -1 )

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
            _tmpdir_original_touch dest_file, noop: @is_noop, verbose: @be_verbose
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

      def __say_not_relative file

        "must be relative - #{ file }"
      end

      include Home_.lib_.file_utils

      alias_method :_tmpdir_original_touch, :touch

      def touch path_tail

        pn = join path_tail

        _tmpdir_original_touch(
          pn.to_path,
          noop: @is_noop,
          verbose: @be_verbose )

        pn
      end

      # -- Support for all

      def fu_output_message msg
        _send_debug_string msg
      end

      def _if_verbose_say &p
        @be_verbose and _send_debug_string( p.call ) ; nil
      end

      def __express_event_as_string ev

        _expag = Home_.lib_.brazen::API.expression_agent_instance
        ev.render_each_line_under _expag do | line |
          _send_debug_string line
        end
        NIL_
      end

      def _send_debug_string msg
        @debug_IO.puts msg
        NIL_
      end

      class Memoizer___

        attr_reader :instance

        def initialize tc, slug

          _path = ::File.join tc.tmpdir_path_for_memoized_tmpdir, slug

          @instance = Tmpdir_.new_with(
            :path, _path,
            :be_verbose, tc.do_debug,
            :debug_IO, tc.debug_IO )
        end

        def for tc

          yes = @instance.be_verbose
          yes_ = tc.do_debug

          if yes
            if ! yes_
              o = @instance.new_with :be_verbose, false
            end
          elsif yes_
            o = @instance.new_with :debug_IO, tc.debug_IO, :be_verbose, true
          end
          if o
            @instance = o
            o
          else
            @instance
          end
        end
      end

      Tmpdir_ = self
    end
  end
end
