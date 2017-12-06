# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMacros_::Method

    # this is a kewel proof of concept of how a "macro" can make a
    # complicated thing more simple (but there's a big But at the end).
    # the complicated things:
    #
    #   - change the name of a method in BOTH its method definition(s)
    #     and its (normally invoked) calls, in one operation.
    #
    #   - be able to replace these names without having to write a full
    #     user function (file).
    #
    # the But is this: this code is not very readable or abstracted.
    # incubating!

    # -

      def initialize listener, scn

        @_idioms_ = Home_::ForMacros::ParsingIdioms.new listener, scn
      end

      def _validate_
        self  # (we do all our parsing lazily)
      end

      # --

      def curate_replacement_function
        send( @_RF ||= :__replacement_function_initially )
      end

      def __replacement_function_initially
        x = __curate_replacement_function
        if x
          @__RF_value = x
          @_RF = :__RF_subsequently
          send @_RF
        else
          @_RF = :_TAINTED ; nil
        end
      end

      def __curate_replacement_function
        if @_idioms_.curate_fixed_string @__delimiter, :delimiter
          s = @_idioms_.curate_via_regex %r([a-zA-Z_0-9]+\z), :common_method_name
          if s
            __build_replacement_function s
          end
        end
      end

      def __build_replacement_function new_method_name_s

        new_method_name_sym = new_method_name_s.intern

        same = -> structured_node do

          _new_guy = structured_node.new_by do |o|
            o.method_name = new_method_name_sym
          end

          _new_guy.to_code_LOSSLESS_EXPERIMENT_
        end

        Home_::ForMacros::HandMadeReplacementFunction_EXPERIMENTAL.new do |sn|

          case sn._node_type_
          when :send ; same[ sn ]
          when :def  ; same[ sn ]
          else ; never
          end
        end
      end

      def curate_code_selector

        s = unsanitized_before_string
        s || sanity

        mod = Home_::CrazyTownMagnetics_::StructuredNode_via_Node

        _sel_1 = mod.selector_via_define_EXPERIMENTAL do |o|
          o.add_test_for_equals_string s, :method_name
          o.feature_symbol = :send
        end

        _sel_2 = mod.selector_via_define_EXPERIMENTAL do |o|
          o.add_test_for_equals_string s, :method_name
          o.feature_symbol = :def
        end

        Home_::ForMacros::CompoundCodeSelector_EXPERIMENTAL.new _sel_1, _sel_2
      end

      # --

      def unsanitized_before_string
        send( @_UBS ||= :__UBS_initially )
      end

      def __UBS_initially
        s = if __parse_delimiter
          __parse_unsanitized_before_string
        end
        if s
          @__UBS_value = s
          send( @_UBS = :__UBS_subsequently )
        else
          @_UBS = :_TAINTED ; UNABLE_
        end
      end

      def __RF_subsequently
        @__RF_value
      end

      def __UBS_subsequently
        @__UBS_value
      end

      def __parse_unsanitized_before_string
        @_idioms_.curate_via_regex @__delimiter_regex, :unsanitized_before_string
      end

      def __parse_delimiter
        s = @_idioms_.curate_one_of_these ':', '/', :delimiter  # etc
        if s
          @__delimiter = s
          @__delimiter_regex = %r([^#{ s }]+)  # be careful
          ACHIEVED_
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -

    # ==
    # ==
  end
end
# #born.
