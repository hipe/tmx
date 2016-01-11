module Skylab::Zerk

  module View_Controllers_::Compound_Frame

    # mainly, the 2-column table

    class << self

      def default_instance
        Placeholder_instance___
      end

      def common_instance
        Common_Instance___
      end
    end  # >>

    Placeholder_instance___ = -> params do

      mvc = params.main_view_controller
      stack = params.stack

      -> y do
        y << "«compound placeholder»"
        _ = stack.last.button_frame
        mvc.express_buttonesques _
        y
      end
    end

    class Common_Instance___

      class << self
        alias_method :[], :new
        private :new
      end  # >>

      def initialize params

        Require_field_library_[]

        @main_view_controller = params.main_view_controller
        @expression_agent = params.expression_agent
        @item_text_proc_for = Item_text_proc_for___
        @stack = params.stack
        freeze
      end

      def call y

        _boundary  # after the prompt and what was entered

        @main_view_controller.express_location_area

        Express_as_table___.new( y, self ).execute

        _boundary

        _button_frame = @stack.last.button_frame

        # (hypothetically there could be no buttons, and hypoth'ly s'OK)

        @main_view_controller.express_buttonesques _button_frame
        y
      end

      def _boundary
        @main_view_controller.touch_boundary ; nil
      end

      # --

      attr_reader(
        :expression_agent,
        :item_text_proc_for,
        :stack,
      )

      def __argument_to_pass_to_item_text_proc_for qkn

        # at writing the "for interface" stream that is our upstream wraps
        # those values that are primitivesque (per the association) with
        # a layer of wrapping so that modality-specific expression layers
        # can send the same ACS API calls to this reflection object that
        # they would to compound components.

        # however for the typical zerk client what the typical subject
        # callback would probably find least surprising is to receive a
        # qualified knowness about the component value with no wrapping.

        if qkn.association.model_classifications.looks_primitivesque

          # (hi.)
          if qkn.is_effectively_known

            _wrapper = qkn.value_x
            qkn = _wrapper.wrapped_qualified_knownness

          end  # else it was not wrapped
        end

        qkn
      end
    end

    class Express_as_table___

      # render a two-column table with names and "item text"  #[#br-096]

      def initialize y, up

        @argument_to_pass_to_item_text_proc_for =
          up.method :__argument_to_pass_to_item_text_proc_for

        @expression_agent = up.expression_agent
        @item_text_proc_for = up.item_text_proc_for
        @stack = up.stack
        @y = y
      end

      def execute
        __populate_columns
        ___express_columns
        @y
      end

      def ___express_columns

        col_A = @_col_A ; col_B = @_col_B
        fmt = "  %#{ @_max }s  %s"

        col_A.length.times do | d |
          lines = col_B.fetch d
          @y << ( fmt % [ col_A.fetch( d ), lines.fetch( 0 ) ] )
          if 1 < lines.length
            # (we could memoize a spacer thing)
            1.upto( lines.length - 1 ).each do | d_ |
              @y << ( fmt % [ EMPTY_S_, lines.fetch( d_ ) ] )
            end
          end
        end
        NIL_
      end

      def __populate_columns

        col_A = [] ; col_B = [] ; max = 0

        st = @stack.last.to_UI_frame_item_stream

        begin
          qkn = st.gets
          qkn or break

          p = @item_text_proc_for[ qkn ]
          p or redo  # decision-A

          _x = @argument_to_pass_to_item_text_proc_for[ qkn ]

          line = @expression_agent.calculate _x, & p  # decision-B
          line or redo  # decision-C

          col_B.push [ line ]

          s = qkn.name.as_slug
          len = s.length
          if max < len
            max = len
          end

          col_A.push s
          redo
        end while nil

        @_col_A = col_A ; @_col_B = col_B ; @_max = max ; nil
      end
    end  # end "express table

    module Item_text_proc_for___ ; class << self

      def [] lt

        p = lt.description_proc

        # :decision-A: at calltime the ACS can produce whatever it wants
        # for the proc (because associations are dynamic). it can produce
        # no proc at all, it can produce a proc that produces a false-ish
        # value, it can produce a proc that produces the empty string..

        # if we end up with a false-ish in the following logic, it means
        # "don't display an entry for this node at all (either in name
        # or item text)."

        if p
          p
        else
          ___inferred_item_text_proc_for lt
        end
      end

      # --

      def ___inferred_item_text_proc_for qkn

        if qkn.looks_primitivesque
          __inferred_item_text_proc_for_primitivesque qkn
        else
          ___inferred_item_text_proc_for_compoundesque qkn
        end
      end

      def ___inferred_item_text_proc_for_compoundesque qkn

        # in the "entity table" it doesn't "look right" to include an
        # entry for compounds inline with the primitivesque properties.
        # that's perhaps the defining feature of this interface: that
        # the terminal nodes are always displayed in the 2-column table,
        # and the non-terminal nodes (and operations) can be reached by
        # "buttonesques" at the bottom of the screen.

        NIL_
      end

      def __inferred_item_text_proc_for_primitivesque lt

        _is_listy = Is_listy_[ lt.association.argument_arity ]
        _is_known = lt.is_effectively_known

        if _is_listy
          if _is_known
            __inferred_item_text_proc_for_known_list lt
          else
            __inferred_item_text_proc_for_unknown_list lt
          end
        elsif _is_known
          __inferred_item_text_proc_for_known_atom lt
        else
          __inferred_item_text_proc_for_unknown_atom lt
        end
      end

      def __inferred_item_text_proc_for_unknown_list _qkn
        self._K
      end

      def __inferred_item_text_proc_for_known_list qkn

        p = _proc_for_item_text_via_known_atom_value_for qkn.association

        -> qkn_ do
          _s_a = qkn_.value_x.reduce [] do | m, x |
            s = calculate x, & p
            if s
              m << s
            end
            m
          end
          _s_a.join ', '  # ..
        end
      end

      def __inferred_item_text_proc_for_unknown_atom _qkn
        Inferred_item_text_proc_for_unknown_atom___
      end

      _ITEM_TEXT_FOR_EFFECTIVELY_UNKNOWN_ATOM = '(none)'

      Inferred_item_text_proc_for_unknown_atom___ = -> _qkn do
        _ITEM_TEXT_FOR_EFFECTIVELY_UNKNOWN_ATOM
      end

      def __inferred_item_text_proc_for_known_atom qkn

        p = _proc_for_item_text_via_known_atom_value_for qkn.association

        -> qkn_ do
          p[ qkn_.value_x ]
        end
      end

      def _proc_for_item_text_via_known_atom_value_for _association
        Say_known_atom___[]
      end

      Say_known_atom___ = Lazy_.call do

        o = Home_.lib_.basic::String.via_mixed.dup

        o.on_nonlong_stringish = -> s, _ do

          if QUOTEWORTHY_RX___ =~ s
            s.inspect
          else
            s
          end
        end

        o.to_proc
      end

      QUOTEWORTHY_RX___ = /[[:space:]'",]/

      # :decision-B: we could support multiline item texts by detecting if
      # the proc wants 2 parameters, but we haven't wanted it yet.
      # if we do, maybe:
      #
      #     lines = Home_.lib_.fields::N_lines_via_proc[ 2, @_expag, p ]

      # :decision-C: with this the association (the ACS) can decide whether
      # or not to list the item at all, like for cases of effectively
      # unknown

    end ; end  # end "item text proc for"
  end  # end file subject
end
