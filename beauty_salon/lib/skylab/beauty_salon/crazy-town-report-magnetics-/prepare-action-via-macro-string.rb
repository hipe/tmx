# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownReportMagnetics_::PrepareAction_via_MacroString <  # 1x.
      Common_::MagneticBySimpleModel

    # -

      # (:[#007.N] the only entrypoint in to whole word filtering is
      # currently thru macros

      # interface with the action to convert a macro string into the
      # necessary pieces implied by it ..

      attr_writer(
        :receive_file_path_process,
        :writable_parameters_hash,
        :macro_string,
        :file_path_upstream_via_arguments,
        :user_resources,
        :listener,
      )

      def execute
        ok = true
        ok &&= __ensure_conditional_anti_requirement
        ok &&= __resolve_macro_args
        ok &&= __resolve_macro_dirs_when_macro_args
        ok &&= __resolve_unsanitized_before_string
        ok &&= __resolve_file_path_upstream_via_macro_dirs
        ok &&= __finish_prepare_for_macro
        ok
      end

      def __finish_prepare_for_macro
        if @_macro_args.finished_parsing_early
          ACHIEVED_
        else
          __cha_cha
        end
      end

      def __cha_cha
        self._FOR_EXAMPLE
        h = @writable_parameters_hash
        h[ :code_selector ] = :Xxxx
        h[ :replacement_function ] = :Yxxx
        ACHIEVED_
      end

      def __resolve_file_path_upstream_via_macro_dirs

        _x = remove_instance_variable :@__unsanitized_before_string

        pcs = Home_::CrazyTownReportMagnetics_::FilePathUpstream_via_WholeWord.call_by do |o|

          o.have_dirs remove_instance_variable :@__macro_dirs

          o.set_whole_word_match_fixed_string _x

          o.set_name_pattern "#{ GLOB_STAR_ }#{ Autoloader_::EXTNAME }"

          rsx = remove_instance_variable :@user_resources
          o.piper = rsx.piper
          o.spawner = rsx.spawner
          o.process_waiter = rsx.process_waiter
          o.listener = @listener
        end
        if pcs
          remove_instance_variable( :@receive_file_path_process )[ pcs ]
          ACHIEVED_
        end
      end

      def __resolve_unsanitized_before_string
        _s = @_macro_args.unsanitized_before_string
        _store :@__unsanitized_before_string, _s
      end

      def __resolve_macro_dirs_when_macro_args
        _p = remove_instance_variable :@file_path_upstream_via_arguments
        _dirs = _p.call do |o|
          o.have_conditional_requirement__ :macro, :files
        end
        _store :@__macro_dirs, _dirs
      end

      def __resolve_macro_args

        _sct = MacroInvocationParseTree_via_MacroString___.call_by do |o|
          o.string = remove_instance_variable :@macro_string
          o.listener = @listener
        end

        _store :@_macro_args, _sct
      end

      def __ensure_conditional_anti_requirement

        # there is no guarantee that the report even accepts these parameters.
        # (we allow #coverpoint4.1 the list files report to preview the whole-
        # word filtering of the macro even tho it does no search/replace)

        h = __readable_parameters_hash
        bads = [ :code_selector, :replacement_function ].select do |k|
          h[ k ]
        end
        if bads.length.nonzero?
          self._COVER_ME__whine_about_conditionally_blacklisted_parameters_present__
        else
          ACHIEVED_
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      def __readable_parameters_hash
        @writable_parameters_hash
      end
    # -

    class MacroInvocationParseTree_via_MacroString___ < Common_::MagneticBySimpleModel

      def string= s
        @_scn = Home_.lib_.string_scanner.new s ; s
      end

      attr_writer(
        :listener,
      )

      def execute
        ok = __parse_macro_slug
        ok &&= __resolve_macro_class_via_macro_slug
        ok && __pass_off_to_specific_guy
      end

      def __pass_off_to_specific_guy
        @__macro_class.new(
          remove_instance_variable( :@listener ),
          remove_instance_variable( :@_scn ),
        )._validate_
      end

      def __resolve_macro_class_via_macro_slug

        _ob = This_ob___[]
        _slug = remove_instance_variable :@__macro_slug
        _key = _slug.gsub( DASH_, UNDERSCORE_ ).intern

        lref = _ob.procure_by do |o|
          o.needle_symbol = _key
          o.item_lemma_symbol = :macro
          o.listener = @listener
        end

        if lref
          @__macro_class = lref.dereference_loadable_reference
          ACHIEVED_
        end
      end

      This_ob___ = Lazy_.call do
        _mod = Home_::CrazyTownMacros_
        ::Skylab::Zerk::ArgumentScanner::OperatorBranch_via_AutoloaderizedModule.define do |o|
          o.module = _mod
          o.sub_branch_const = :not_used_BS
        end
      end

      def __parse_macro_slug
        @__macro_slug = @_scn.scan( /[-_[:alnum:]]*/i )  # cannot fail
        ACHIEVED_
      end

      define_method :_express_error, DEFINITION_FOR_THE_METHOD_CALLED_EXPRESS_ERROR_
    end

    module Home_::MethodsForUserOfMacroParsingIdioms
    private

      def init_macro_parsing_idioms p, scn
        @_idioms_ = MacroParsingIdioms___.new p, scn ; nil
      end

      def curate_one_of_these * s_a, sym
        @_idioms_.curate_one_of s_a, sym
      end

      def curate_via_regex rx, sym
        @_idioms_.curate_via_regex rx, sym
      end

    public
      def finished_parsing_early
        @_idioms_.finished_parsing_early
      end
    end

    class MacroParsingIdioms___

      def initialize p, scn
        @_scn = scn
        @listener = p
      end

      def curate_one_of s_a, sym
        s = @_scn.peek 1
        if s and s_a.include? s
          @_scn.pos += 1
          s.freeze
        else
          __fail_one_of_these s_a, sym
        end
      end

      def __fail_one_of_these s_a, sym

        _error :argument_error do |y, me|

          _ = simple_inflection do
            oxford_join ::String.new, Scanner_[ s_a ], ' or ' do |s|
              s.inspect
            end
          end

          me._express_expecting_into_under y, _, sym, self
        end
      end

      def curate_via_regex rx, ivar
        s = @_scn.scan rx
        if s
          s.freeze
        else
          _error :argument_error do |y, me|
            me._express_expecting_into_under y, ivar, self
          end
        end
      end

      def _express_expecting_into_under y, middle=nil, human_sym, expag

        _postfix_contextualization = if @_scn.eos?
          " at end of macro string"
        else
          " near \"#{ @_scn.peek 5 }\""
        end

        s = human_sym.id2name
        _slug_s = if '@' == s[0]
          /\A@_*/.match( s ).post_match
        else
          s
        end
        _hum = _slug_s.gsub UNDERSCORE_, SPACE_

        if middle
          _mid = " #{ middle }"
        end

        y << "expecting #{ _hum }#{ _mid }#{ _postfix_contextualization }"
      end

      def finished_parsing_early
        @_scn.eos?
      end

      define_method :_error, DEFINITION_FOR_THE_METHOD_CALLED_EXPRESS_ERROR_
    end

    # ==
    # ==
  end
end
# #born.
