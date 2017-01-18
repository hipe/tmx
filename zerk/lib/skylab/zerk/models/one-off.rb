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

        _above_st = super()

        Common_::Stream::CompoundStream.define do |o|
          o.add_stream _above_st
          o.add_stream _st2
        end
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

    class LEGACY_OneOff_as_Bound__  # will re-open

      def bound_call_under fr, & _oes_p  # [tmx]

        _proc_like = @_one_off.require_proc_like

        o = fr.resources

        _pnsa = [ * o.invocation_string_array.dup, @_one_off.slug ]

        _standard_five = [ o.argv, o.sin, o.sout, o.serr, _pnsa ]

        Common_::BoundCall[ _standard_five, _proc_like, :call ]
      end

      def __build_description_proc

        one_off = @_one_off

        -> y do

          _syno = Home_::CLI::SynopsisLines_via_HelpScreen.define do |o|
            o.number_of_synopsis_lines = 1
          end

          _lines = _syno.synopsis_lines_by do |downstream|
            one_off.express_help_by do |o|
              o.program_name_head_string_array = NOTHING_  # meh
              o.downstream = downstream
            end
          end

          y << _lines.fetch( 0 )
        end
      end
    end

    # ==

    class ExpressHelp_via___ < Home_::MagneticBySimpleModel

      attr_writer(
        :downstream,
        :one_off,
        :program_name_head_string_array,
      )

      def execute

        _proc_like = @one_off.require_proc_like

        _pnsa = [ * @program_name_head_string_array,
          * @one_off.program_name_tail_string_array ]

        _argv = HELP_ARGV___.dup  # those that use optparse consume

        _es = _proc_like[ _argv, DUMMY_STDIN___, :_no_sout_zerk_, @downstream, _pnsa ]

        _es
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

      def TO_OPERATOR_ADAPTER_FOR cli
        Home_::Magnetics::OperatorBranch_via_Directory::OA.new self, cli
      end

      def express_help_by
        ExpressHelp_via___.call_by do |o|
          yield o
          o.one_off = self
        end
      end

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

        # we do *not* prepend `@load_ticket.slug` here - that should be
        # expressed in the `program_name_head_string_array`

        [ slug ]
      end

      def intern  # to compat with branches that use symbols for load tickets
        normal_symbol
      end

      def normal_symbol
        @___normal_symbol ||= slug.gsub( DASH_, UNDERSCORE_ ).intern
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

      def category_symbol
        :zerk_one_off_category_symbol
      end
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

    module DUMMY_STDIN___ ; class << self
      def tty?
        false
      end
    end ; end

    # ==

    ::Skylab__Zerk__OneOffs = ::Module.new

    # ==

    HELP_ARGV___ = %w( --help ).freeze

    # ==
  end
end
# #history: moved from [br] to [ze], took content from (now) "magnetics-/one off scanner via.."
