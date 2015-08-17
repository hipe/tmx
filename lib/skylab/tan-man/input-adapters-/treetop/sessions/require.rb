module Skylab::TanMan

  module Input_Adapters_::Treetop

    class Sessions::Require  # see [#008]

      _Parameter = Home_.lib_.fields::Parameter

      _Parameter::Definer[ self ]

      meta_param :required, :boolean

      param :add_parser_enhancer_module, :DSL, :list, :default, nil

      param :add_treetop_grammar, :DSL, :list, :required

      param :force_overwrite, :boolean, :default, false

      param :input_path_head_for_relative_paths, :writer

      param :output_path_head_for_relative_paths, :writer

      # ~ internally we use the below against the above

      define_method :normalize, _Parameter::Controller::NORMALIZE_METHOD

      define_method :bound_parameters, _Parameter::Bound::PARAMETERS_METHOD

      def initialize( & oes_p )

        @on_event_selectively = oes_p
      end

      LOADED__ = Callback_::Box.new

      def execute  # see [#.A]

        # to save "time", we don't even normalize the parameters yet.

        key = @add_treetop_grammar.last

        if FILE_SEPARATOR_BYTE_ != key.getbyte( 0 )
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

        @formal_parameters = self.class.parameters

        ok = normalize
        ok &&= __resolve_units_of_work
        ok && Home_.lib_.TT  # either for compiling or for loading
        ok &&= __maybe_compile_some_files
        ok && __require_the_files
        ok && __produce_the_final_parser_class
      end

    private

      def __resolve_units_of_work

        uow_a = Treetop_::Actors_::Build_units_of_work.call(
          bound_parameters,
          @_filesystem,
          & @on_event_selectively )

        if uow_a
          @_units_of_work = uow_a
          ACHIEVED_
        else
          uow_a
        end
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
        _build_grammar_event :creating, :create_g_a, g_a
      end

      def __build_overwriting_event g_a
        _build_grammar_event :overwriting, :exist_g_a, g_a
      end

      def _build_grammar_event which_sym, ing_sym, g_a

        Callback_::Event.inline_neutral_with(
          which_sym,
          ing_sym, g_a,

        ) do | y, o |

          _s_a = o.send( ing_sym ).map do |g|
            pth g.output_path
          end

          y << "#{ o.ing_sym }: #{ _s_a * ', ' }"
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
          @_filesystem.mkdir_p mkdir_p, & @on_event_selectively  # #todo
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
        cls = Callback_::Const_value_via_parts[ sym_a ]

        if @add_parser_enhancer_module  # an array
          self._FUN
        end

        LOADED__.add uow.input_path, cls
        cls
      end

      FILE_SEPARATOR_BYTE_ = ::File::SEPARATOR.getbyte 0
    end
  end
end
# :#tombstone: crazy formal parameter class with directory / f.s "smarts" and..
#              silly detailed error messages from requiring treetop parsers
