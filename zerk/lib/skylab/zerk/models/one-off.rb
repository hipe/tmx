module Skylab::Zerk

  class Models::OneOff < SimpleModel_

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

    # -
      def initialize
        yield self
        @_slug = :__slug_initially
      end

      attr_writer(
        :load_ticket,  # instance of the model
        :path,         # e.g "/Users/haxor/.gem/ruby/[..]/bin/tmx-meep-mop-frob-jibbers
        :slug_tail,    # e.g "frob-jibbers"
      )

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

      # [br] CLI is an adaptation of a reactive model to a particular
      # modality. this is an adaption of of scripts written "natively"
      # in that modality into .. the [br] CLI. yes, it's CLI for CLI.

      Definition_for_the_LEGACY_method_called_to_unordered_selection_stream = -> s do

        # result is the method body for a `to_unordered_selection_stream`
        # that exposes all the executable files in the usual location that
        # have the provided prefix, as if they were reactive action nodes.

        -> do

          _stream_1 = super()

          ss_mod = lookup_sidesystem_module

          glob = ::File.expand_path "../../../bin/#{ s }*",
            ss_mod.dir_path

          range = glob.length - 1 .. -1

          _s_a = ss_mod.name.split Common_::CONST_SEPARATOR

          _stream_2 = Common_::Stream.via_nonsparse_array( ::Dir[ glob ] ) do | path |

            Executable_as_Unbound___.new( path[ range ], path, _s_a )
          end

          _stream_1.concat_stream _stream_2
        end
      end

      # ===

      class Executable_as_Unbound___

        attr_reader(
          :name_function,
        )

        def initialize slug, path, const_ppfx

          @__const_pfx = const_ppfx
          @name_function = Common_::Name.via_slug slug
          @__path = path
        end

        def adapter_class_for _
          self
        end

        def new _this, k, & oes_p

          Executable_as_Bound___.new k, self, & oes_p
        end

        attr_reader(
          :__const_pfx,
          :__path,
        )
      end

      # ===

      class Executable_as_Bound___

        def initialize k, bound, & oes_p

          @_bound = bound
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
          @___dp ||= ___build_description_proc
        end

        def ___build_description_proc

          bound = @_bound
          -> y do
            y << ::File.basename( bound.__path )
          end
        end

        # ~ needed to invoke

        def bound_call_under fr, & _oes_p  # [tmx]

          _one_off = __build_one_off

          o = fr.resources

          _one_off.to_bound_call_via_standard_five_resources(
            o.argv, o.sin, o.sout, o.serr, o.invocation_string_array )
        end

        def __build_one_off

          bo = @_bound

          ONE_OFF_LEGACY_MODEL___.define do |o|
            o.path = bo.__path
            o.terminal_name = bo.name_function
            o.up_const_path = bo.__const_pfx
            o.loader = ::Kernel
          end
        end
      end

      # ===

      class ONE_OFF_LEGACY_MODEL___ < SimpleModel_

            # when it comes time to invoke the executable, it must follow a
            # few rules in order to be exposed by this [br]-integrated
            # modality face.

        def initialize

          yield self

          scn = Common_::Polymorphic_Stream.via_array @up_const_path

          _head_const = scn.gets_one

          buffer = ""
          begin
            buffer << "#{ scn.gets_one }#{ UNDERSCORE_ }"
          end until scn.no_unparsed_exists
          buffer << @terminal_name.as_lowercase_with_underscores_string

          # the above is the predecessor to nascent [#063.1]

          @_tail_const = buffer

          @__universe_module = ::Object.const_get _head_const, false
        end

        attr_writer(
          :loader,
          :path,
          :terminal_name,
          :up_const_path,
        )

        def to_bound_call_via_standard_five_resources argv, i, o, e, up_pn_s_a

          _proc_ish = __proc_like_loaded_if_necessary

          _pn_s_a = [ * up_pn_s_a, @terminal_name.as_slug ]

          _standard_five = [ argv, i, o, e, _pn_s_a ]

          Common_::Bound_Call[ _standard_five, _proc_ish, :call ]
        end

              # we cannot simply `require` it because it is not an ordinary
              # ruby library file. hypothetically we could `eval` it but
              # then it is harder to develop because no stack traces.

        def __proc_like_loaded_if_necessary

          # (the resource may have been loaded already if for example
          # you are using the test runner to test itself)

          univ_mod = @__universe_module
          const = @_tail_const

          if ! univ_mod.const_defined? const, false
            Touch_this_module___[]
            @loader.load @path
          end

          univ_mod.const_get const, false
        end

        attr_reader(
          :terminal_name,
        )
      end

      # ==

      Touch_this_module___ = Lazy_.call do
        module ::Skylab__Zerk__OneOffs
        end
        NIL
      end

      # ===

    # ==
  end
end
# #history: moved from [br] to [ze], took content from (now) "magnetics-/one off scanner via.."
