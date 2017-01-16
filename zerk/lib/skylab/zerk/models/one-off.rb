module Skylab::Zerk

  class Models::OneOff < SimpleModel_

    # ==

    Definition_for_the_LEGACY_method_called_to_unordered_selection_stream = -> exe_prefix do

      -> do

        _ss_mod = lookup_sidesystem_module

        _load_ticket = Models::Sidesystem::LoadTicket_via_AlreadyLoaded[ _ss_mod ]

        _st = _load_ticket.to_one_off_scanner_by do |o|
          o.stream_not_scanner = true
        end

        _st2 = _st.map_by do |oo|
          LEGACY_Whatever_via_OneOff___[ oo ]
        end

        super().concat_stream _st2
      end
    end

    # ==

    class LEGACY_Whatever_via_OneOff___ < MonadicMagneticAndModel_

      def initialize oo
        _ = oo.load_ticket.gem_name_elements.entry_string
        @name_function = Common_::Name.via_slug oo.slug
        @__one_off = oo
      end

      def new _this, _k, & oes_p
        LEGACY_OneOff_as_Bound__.new self, @__one_off, & oes_p
      end

      attr_reader(
        :name_function,
      )

      def adapter_class_for _
        self
      end
    end

    # ==

    class NOT_COVERED__ArgumentScanner__OperatorBranch_via_Directory

      # an adaptation of #[#051] for directories (probably "bin/"-like)

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      def initialize
        @prefix = nil
        yield self
        freeze
      end

      # -- definition time

      def directory dir
        @directory = dir ; nil
      end

      def parent_module_of_executables mod

        # (for now we are optimistic that this will result in a read success)

        @__up_const_path = mod.name.split Common_::CONST_SEPARATOR
        NIL
      end

      def mandatory_prefix_to_disregard s
        @prefix = s ; nil
      end

      def item_class cls
        @item_class = cls ; nil
      end

      def filesystem_function_implementors globber, fs, loader
        @filesystem = fs
        @globber = globber
        @loader = loader ; nil
      end

      # -- read time

      def emit_idea_by
        NOTHING_  # use default expression. (can be exposed if needed.)
      end

      def lookup_softly k

        name = _name_via_key k
        path = _path_via_name name

        if @filesystem.file? path
          _item_via path, name
        end
      end

      def entry_value k

        name = _name_via_key k
        _item_via _path_via_name( name ), name
      end

      def _item_via path, nm
        @item_class.new path, nm, @__up_const_path, @loader
      end

      def _path_via_name nm
        ::File.join @directory, "#{ @prefix }#{ nm.as_slug }"
      end

      def _name_via_key k
        Common_::Name.via_lowercase_with_underscores_symbol k
      end
    end

    # ==

    class LEGACY_OneOff_as_Bound__  # will re-open

      def bound_call_under fr, & _oes_p  # [tmx]

        _proc_like = @_one_off.require_proc_like

        o = fr.resources

        _pnsa = [ * o.invocation_string_array.dup, @_one_off.slug ]

        _standard_five = [ o.argv, o.sin, o.sout, o.serr, _pnsa ]

        Common_::Bound_Call[ _standard_five, _proc_like, :call ]
      end

      def __build_description_proc

        one_off = @_one_off
        -> y do

          _proc_like = one_off.require_proc_like

          _syno = Home_::CLI::SynopsisLines_via_HelpScreen.define do |o|
            o.number_of_synopsis_lines = 1
          end

          _pnsa = one_off.program_name_tail_string_array  # meh

          _argv = HELP_ARGV.dup  # those that use optparse consume

          _lines = _syno.synopsis_lines_by do |serr|
            _proc_like[ _argv, DUMMY_STDIN, :_no_sout_zerk_, serr, _pnsa ]
          end

          y << _lines.fetch( 0 )
        end
      end
    end

    # ==

    # `OneOff`

    # -
      def initialize
        yield self
        @_proc_like = :__proc_like_initially
        @_slug = :__slug_initially
      end

      attr_writer(
        :load_ticket,  # instance of the model
        :path,         # e.g "/Users/haxor/.gem/ruby/[..]/bin/tmx-meep-mop-frob-jibbers
        :slug_tail,    # e.g "frob-jibbers"
      )

      # --

      def require_proc_like
        send @_proc_like
      end

      def __proc_like_initially
        mod = ::Skylab__Zerk__OneOffs
        const = sub_top_level_const_guess
        if ! mod.const_defined? const, false
          ::Kernel.load @path
        end
        @__proc_like = mod.const_get const, false
        @_proc_like = :__proc_like_normally
        send @_proc_like
      end

      def __proc_like_normally
        @__proc_like
      end

      # --

      def sub_top_level_const_guess
        @___STLCG ||= __sub_top_level_const_guess
      end

      def __sub_top_level_const_guess
        if @slug_tail
          __sub_top_level_const_guess_normally
        else
          __sub_top_level_const_guess_when_weird_name
        end
      end

      def __sub_top_level_const_guess_when_weird_name

        # for weird one-offs whose filename entry didn't match the expected
        # head (a.k.a prefix), generally we derive a name from the whole
        # filename entry inflected to look like a [#bs-029.3] "function-like
        # const" (e.g from the file entry "git-stash-untracked" we would
        # derive `Git_stash_untracked`).
        #
        # however if this name has an acronym-looking piece for the first
        # piece, we don't want to downcase the nonfirst letters (e.g !"Tmx"
        # for "tmx"). so for the first piece we always use the VERY heuristic
        # function below...

        pieces = slug.split DASH_
        _s = @load_ticket.class::Const_guess_via_piece[ pieces.first ]  # meh
        pieces[0] = _s
        pieces.join( UNDERSCORE_ ).intern
      end

      def __sub_top_level_const_guess_normally

        # for one-offs whole filename followe convention, assume:

        _ = @slug_tail.gsub DASH_, UNDERSCORE_
        "#{ @load_ticket.one_off_const_head }#{ UNDERSCORE_ }#{ _ }".intern
      end

      # --

      def program_name_tail_string_array
        [ @load_ticket.slug, slug ]
      end

      def slug
        send @_slug
      end

      def __slug_initially
        if @slug_tail
          @_slug = :__slug_using_tail
        else
          @__slug_derived = ::File.basename( @path ).freeze
          @_slug = :__slug_derived_from_path
        end
        send @_slug
      end

      def __slug_using_tail
        @slug_tail
      end

      def __slug_derived_from_path
        @__slug_derived
      end

      attr_reader(
        :load_ticket,
        :path,
      )
    # -

    # ==

      # ===

      class LEGACY_OneOff_as_Bound__

        def initialize bound, oo, & oes_p

          @_bound = bound
          @_one_off = oo
        end

        # ~ needed by index

        def is_visible
          true
        end

        def name_value_for_order
          @_bound.name_function.as_lowercase_with_underscores_symbol
        end

        def name
          @_bound.name_function
        end

        def after_name_value_for_order
          NIL_
        end

        # ~ needed to reflect

        def description_proc_for_summary_under _
          description_proc
        end

        def description_proc
          @___dp ||= __build_description_proc
        end
      end

      # ===
    # ==

    module DUMMY_STDIN ; class << self
      def tty?
        false
      end
    end ; end

    # ==

    ::Skylab__Zerk__OneOffs = ::Module.new

    # ==

    HELP_ARGV = %w( --help ).freeze

    # ==
  end
end
# #history: moved from [br] to [ze], took content from (now) "magnetics-/one off scanner via.."
