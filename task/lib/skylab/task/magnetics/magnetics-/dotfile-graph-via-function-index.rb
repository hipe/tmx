class Skylab::Task

  module Magnetics

    class Magnetics_::DotfileGraph_via_FunctionIndex < Common_::Actor::Monadic

      # exactly [#010]. here for now we stream the work in little clusters

      def initialize fi
        @_function_index = fi
        @label_wordwrap_ratio = [ 5, 1 ]  # w x h, to wordwrap the labels by
      end

      def execute

        @_AoT_counter = nil
        @_function_forward_references = nil
        @_OoT_counter = nil
        @_term_forward_references = Common_::Box.new

        w_h = @label_wordwrap_ratio
        if w_h
          _ml = Make_label_maker___[ w_h ]
        else
          _ml = IDENTITY_
        end
        @_make_label = _ml

        @_product_symbol_stream = @_function_index.to_product_symbol_stream__

        @_m = :__first
        Common_.stream do
          send @_m
        end
      end

      def __first
        @_m = :_main
        "digraph g {\n"
      end

      def _main
        sym = @_product_symbol_stream.gets
        if sym
          fits_that_produce = @_function_index.get_functions_that_produce__ sym
          if 1 == fits_that_produce.length
            fit = fits_that_produce.fetch 0
            if fit.is_monadic
              __express_comes_from fit, sym
            elsif fit.has_one_product
              __express_as_a_classic_dependency_graph_of_one_to_many fit, sym
            else
              __express_as_a_forward_reference_to_the_function fit, sym
            end
          else
            __when_multiple_functions_produce_it fits_that_produce, sym
          end
        else
          __render_the_nodes
        end
      end

      def __when_multiple_functions_produce_it fits, sym

        d = ( @_OoT_counter ||= 0 ) + 1
        @_OoT_counter = d

        @_fit_st = Common_::Stream.via_nonsparse_array fits

        @_m = :_express_remainder_of_function_stream

        @_OoT = "#{ OOT__ }#{ d }"

        _sym = _touch_forward_reference_to_term sym
        _render_arc _sym, @_OoT
      end

      def _express_remainder_of_function_stream

        fit = @_fit_st.gets
        if fit
          if fit.is_monadic  # then #cp1-4
            _sym = fit.prerequisite_term_symbols.first
            _ref = _touch_forward_reference_to_term _sym
            _render_arc @_OoT, _ref
          elsif fit.has_one_product  # #cp1-5
            _all_of_these_then fit, :_express_remainder_of_function_stream
          else  # #cp1-6
            _ref = _touch_forward_reference_to_function fit
            _render_arc @_OoT, _ref
          end
        else
          remove_instance_variable :@_fit_st
          @_m = :_main
          send @_m
        end
      end

      def __express_comes_from fit, sym  # #cp1-1

        _rhs = fit.prerequisite_term_symbols.first
        _rhs_ref = _touch_forward_reference_to_term _rhs
        _lhs_ref = _touch_forward_reference_to_term sym
        _render_arc "comes from", _lhs_ref, _rhs_ref
      end

      def __express_as_a_forward_reference_to_the_function fit, sym  # #cp1-3

        _ref = _touch_forward_reference_to_term sym
        _fref = _touch_forward_reference_to_function fit
        _render_arc "comes from", _ref, _fref
      end

      def __express_as_a_classic_dependency_graph_of_one_to_many fit, sym  # #cp1-2

        @_sym_ref = _touch_forward_reference_to_term sym
        @_st = fit.to_prerequisite_term_symbol_stream_
        @_m = :__express_one_arc_of_classic_dependency
        send @_m
      end

      def __express_one_arc_of_classic_dependency

        sym = @_st.gets
        if sym
          _ref = _touch_forward_reference_to_term sym
          _render_arc "depends on", @_sym_ref, _ref
        else
          remove_instance_variable :@_sym_ref
          remove_instance_variable :@_st
          @_m = :_main
          send @_m
        end
      end

      # --

      def _touch_forward_reference_to_function fit

        _bx = ( @_function_forward_references ||= Common_::Box.new )

        _o = _bx.touch fit.function_offset do
          Common_::Pair.via_value_and_name fit, "#{ FUN___ }#{ fit.function_offset }"
        end

        _o.name_x
      end

      def _touch_forward_reference_to_term sym

        @_term_forward_references.touch sym do
          if IS_KEYWORD___[ sym ]
            :"_not_keyword__#{ sym }__"
          else
            sym
          end
        end  # result is symbol to use internally
      end

      IS_KEYWORD___ = {
        digraph: true,
        # ..
      }

      # --

      def __render_the_nodes
        d = remove_instance_variable :@_OoT_counter
        if d
          @_next_num = Count_up_to__[ d ]
          @_m = :__render_next_one_of_these
        else
          @_m = :_render_any_numbered_function_referents
        end
        send @_m
      end

      def _render_any_numbered_function_referents
        d = remove_instance_variable :@_AoT_counter
        if d
          @_next_num = Count_up_to__[ d ]
          @_m = :__render_next_all_of_these
        else
          @_m = :_render_any_non_numbered_function_referents
        end
        send @_m
      end

      Count_up_to__ = -> last do  # assume first item is 1
        current = 0
        p = -> do
          current += 1
          if last == current
            p = EMPTY_P_
          end
          current
        end
        -> do
          p[]
        end
      end

      def __render_next_one_of_these
        d = @_next_num[]
        if d
          "  #{ OOT__ }#{ d } [label=\"(one of these)\"]\n"
        else
          @_m = :_render_any_numbered_function_referents
          send @_m
        end
      end

      def __render_next_all_of_these
        d = @_next_num[]
        if d
          "  #{ AOT__ }#{ d } [label=\"(all of these)\"]\n"  # #here
        else
          @_m = :_render_any_non_numbered_function_referents
          send @_m
        end
      end

      def _render_any_non_numbered_function_referents

        if @_function_forward_references
          _reinit_FR_stream
          @_m = :_render_next_function_referent
        else
          @_m = :_render_term_referents
        end
        send @_m
      end

      def _render_next_function_referent

        pair = @_function_referent_stream.gets
        if pair
          _all_of_these_TWO_then pair, :_render_next_function_referent  # hehe tail call-ish
        else
          _reinit_FR_stream
          @_m = :__render_next_function_referent_as_node
          send @_m
        end
      end

      def _reinit_FR_stream
        @_function_referent_stream = @_function_forward_references.to_value_stream
        NIL_
      end

      def __render_next_function_referent_as_node
        pair = @_function_referent_stream.gets
        if pair
          _render_node "(all of these)", pair.name_x  # #here
        else
          @_m = :_render_term_referents
          send @_m
        end
      end

      def _all_of_these_TWO_then pair, m

        # (in progress - this is like the other but we already know the
        #  shortname that we are supposed to use for the dootily)

        @_after_all_of_these = m
        @_AoT = pair.name_x

        @_precon_st = pair.value_x.to_prerequisite_term_symbol_stream_
        @_m = :_all_of_these_main
        send @_m
      end

      def _all_of_these_then fit, m

        @_after_all_of_these = m
        d = ( @_AoT_counter ||= 0 ) + 1
        @_AoT_counter = d
        @_AoT = "#{ AOT__ }#{ d }"

        @_precon_st = fit.to_prerequisite_term_symbol_stream_
        @_m = :_all_of_these_main
        _render_arc @_OoT, @_AoT
      end

      AOT__  = '_aot'
      FUN___ = '_f'
      OOT__  = '_oot'

      def _all_of_these_main
        sym = @_precon_st.gets
        if sym
          _ref = _touch_forward_reference_to_term sym
          _render_arc @_AoT, _ref
        else
          remove_instance_variable :@_AoT
          remove_instance_variable :@_precon_st
          @_m = remove_instance_variable :@_after_all_of_these
          send @_m
        end
      end

      def _render_term_referents  # assume some (there's always some, right?)

        # (as a reminder, here only, symbolic keys were
        # were used and the values were only ever `true`.)

        _bx = remove_instance_variable :@_term_forward_references
        @__term_referent_pair_stream = _bx.to_pair_stream
        @_m = :__render_next_term_referent
        send @_m
      end

      def __render_next_term_referent

        pair = @__term_referent_pair_stream.gets
        if pair

          # first, make it look like a normal, word-wrappable string

          _label_sym = pair.name_x
          _internal_ref_sym = pair.value_x

          s = _label_sym.id2name
          s.gsub! UNDERSCORE_, SPACE_

          # then, actually wrap it

          _s_ = @_make_label[ s ]

          _render_node _s_, _internal_ref_sym
        else
          remove_instance_variable :@__term_referent_pair_stream
          @_m = :__finish
          send @_m
        end
      end

      def _render_arc label=nil, src_sym, dest_sym

        if label
          _label_s = " [label=\"#{ label }\"]"
        end

        "  #{ src_sym } -> #{ dest_sym }#{ _label_s }\n"
      end

      def _render_node label_words, ref  # assume label words does not contain any kind of quotes

        if NODE_KEYWORD___ == ref
          Home_._FIXME_dot_language_keyword_used_as_node_identifier
        end

        "  #{ ref } [label=\"#{ label_words }\"]\n"
      end

      NODE_KEYWORD___ = 'node'

      def __finish
        @_m = :__done
        "}\n"
      end

      def __done
        NOTHING_
      end

      # ==

      Make_label_maker___ = -> w_h do

        # first, curry a "prototype" of the function:

        ww = Home_.lib_.basic::String.word_wrappers.calm.new
        ww.aspect_ratio = w_h

        _ESCAPED_NEWLINE = "\\n"

        build_yielder_for_buffer = -> buffer do

          p = -> ss do
            p = -> s do
              buffer << _ESCAPED_NEWLINE << s
            end
            buffer << ss
          end

          ::Enumerator::Yielder.new do |s|
            p[ s ]
          end
        end

        -> words_string do

          # then for each string that is needed to be wrapped, we call the
          # curried function with a special yielder that does our custom
          # logic for separating lines by using this escape sequence

          buffer = ""
          _y = build_yielder_for_buffer[ buffer ]

          _inst = ww.new_with(
            :downstream_yielder, _y,
            :input_string, words_string,
          )

          _inst.execute  # result is always yielder, uninteresting here

          buffer
        end
      end

      EMPTY_P_ = -> do
        NOTHING_
      end
    end
  end
end
# #history: rewrote from yielder-based to stream-based
