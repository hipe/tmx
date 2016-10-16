module Skylab::TanMan

  module Input_Adapters_::Treetop

    class Sessions::Require  # see [#008]

      Attributes_ = -> h do
        Home_.lib_.fields::Attributes[ h ]
      end

      attrs = Attributes_.call(

        add_parser_enhancer_module: [ :list, :optional, ],

        add_treetop_grammar: [ :list, ],

        force_overwrite: [ :boolean, :default, false ],

        input_path_head_for_relative_paths: [ :_write, :optional ],

        output_path_head_for_relative_paths: [ :_write, :optional ],
      )

      attrs.define_methods self

      attr_writer( * attrs.symbols( :_write ) )

      ATTRIBUTES = attrs

      def initialize & oes_p
        @on_event_selectively = oes_p
      end

      LOADED__ = Common_::Box.new

      def execute  # see [#.A]

        # to save "time", we don't even normalize the parameters yet.

        key = @add_treetop_grammar.last

        if Path_looks_relative_[ key ]
          key = ::File.join @input_path_head_for_relative_paths, key
        end

        none = nil
        cls = LOADED__.fetch key do
          none = true
        end

        if none
          __do_load
        else
          cls
        end
      end

      def __do_load

        @_filesystem = Home_.lib_.system.filesystem  # mkdir_p

        ok = normalize
        ok &&= __resolve_units_of_work
        ok && Home_.lib_.TT  # either for compiling or for loading
        ok &&= __maybe_compile_some_files
        ok && __require_the_files
        ok && __produce_the_final_parser_class
      end

    private

      def normalize  # near but not really the same as #[#fi-022] ..

        self.class::ATTRIBUTES.normalize_session self  # handler?..
      end

      def __resolve_units_of_work

        _bound_attributes = Home_.lib_.fields::Attributes::Bounder[ self ]

        _uow_a = Here_::Actors_::Build_units_of_work.call(
          _bound_attributes,
          @_filesystem,
          & @on_event_selectively )

        _store :@_units_of_work, _uow_a
      end

      # ~ compile

      def __maybe_compile_some_files

        a = nil
        will_create = nil
        will_overwrite = nil

        @_units_of_work.each do | uow |
          if uow.output_path_did_exist
            if @force_overwrite
              will_overwrite = true
              ( a ||= [] ).push uow
            end
          else
            will_create = true
            ( a ||= [] ).push uow
          end
        end

        if a

          if will_create
            @on_event_selectively.call :info, :creating do
              __build_creating_event a.reject( & :output_path_did_exist )
            end
          end

          if will_overwrite
            @on_event_selectively.call :info, :overwriting do
              __build_overwriting_event a.select( & :output_path_did_exist )
            end
          end

          __compile_these a
        else
          ACHIEVED_
        end
      end

      def __build_creating_event g_a
        _build_grammar_event :create_g_a, g_a, :creating
      end

      def __build_overwriting_event g_a
        _build_grammar_event :exist_g_a, g_a, :overwriting
      end

      def _build_grammar_event which_g_a, g_a, ing_sym

        Common_::Event.inline_neutral_with(
          ing_sym,
          which_g_a, g_a,

        ) do | y, o |

          _s_a = o.send( which_g_a ).map do |g|
            pth g.output_path
          end

          y << "#{ ing_sym }: #{ _s_a * ', ' }"
        end
      end

      def __compile_these uow_a
        ok = true
        uow_a.each do | uow |
          ok = __compile uow
          ok or break
        end
        ok
      end

      def __compile uow

        _ok = __mkdir_if_necessary uow
        _ok &&= __via_compiler_compile uow
      end

      def __mkdir_if_necessary uow

        mkdir_p = uow.make_this_directory_minus_p
        if mkdir_p
          ::Home._COVER_ME
          @_filesystem.mkdir_p mkdir_p, & @on_event_selectively
        else
          ACHIEVED_
        end
      end

      def __via_compiler_compile uow

        cmp = ( @___compiler ||= ::Treetop::Compiler::GrammarCompiler.new )
        d = cmp.compile uow.input_path, uow.output_path

        if d.nonzero?  # number of bytes
          ACHIEVED_
        else
          self._COVER_ME
        end
      end

      # ~ load

      def __require_the_files

        uow_a = @_units_of_work

        load = -> uow do
          ::Kernel.load uow.output_path
         end

        ( 0 ... ( uow_a.length - 1 ) ).each do | d |  # all but the last ..

          uow = uow_a.fetch d
          LOADED__.add uow.input_path, :_loaded_as_ancillary_grammar_  # ..
          load[ uow ]

        end

        load.call uow_a.fetch( -1 )

        NIL_
      end

      # ~ produce the final parser class

      def __produce_the_final_parser_class

        uow = @_units_of_work.last
        sym_a = uow.module_name_i_a
        sym_a[ -1 ] = :"#{ sym_a.last }Parser"
        cls = Common_::Const_value_via_parts[ sym_a ]

        if @add_parser_enhancer_module  # an array

          d = 0
          ick = Common_::Const_value_via_parts[ sym_a[ 0 ... -1 ] ]
          stem = sym_a.last

          @add_parser_enhancer_module.each do | mod |  # legacy

            cls_ = ::Class.new cls
            ick.const_set :"#{ stem }_with_Enhacement_#{ d += 1 }", cls_

            cls_.include mod
            mod.override.each do | m |
              cls_.send :alias_method, m, :"my_#{ m }"
            end
            cls = cls_
          end
        end

        LOADED__.add uow.input_path, cls
        cls
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end
  end
end
# :#tombstone: crazy formal parameter class with directory / f.s "smarts" and..
#              silly detailed error messages from requiring treetop parsers
