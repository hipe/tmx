module Skylab::Zerk

  class InteractiveCLI

  class Buttonesque_Expression_Adapter_

    # the constituency of each button in any particular frame is a function
    # of all the buttons that happen to be in that frame at the moment,
    # taking into account (for each button) either its custom hotstring
    # delineation or its slug. as such the constituency of a button is not
    # a property to be stored within the load ticket but rather each button
    # should store a reference to the load ticket it represents.

    class Frame

      class << self
        alias_method :begin, :new
        private :new
      end  # >>

      def initialize

        @_black = {}
        @_load_ticket_d_via_slug_d = []
        @_load_tickets = []
        @_sct_a = []
        @_slug_a = []
      end

      def add lt  # by compound frame

        d = @_load_tickets.length
        @_load_tickets.push lt

        sct = lt.custom_hotstring_structure
        if sct
          @_black[ sct.hotstring_for_expression ] = true
          @_sct_a[ d ] = sct
        else
          @_load_ticket_d_via_slug_d.push d
          @_slug_a.push lt.name.as_slug
        end
        NIL_
      end

      def finish

        _hs_a = Basic_[]::Hash::Hotstrings[ @_black, @_slug_a ]

        _hs_a.each_with_index do | sct, slug_d |

          _slug = @_slug_a.fetch slug_d

          lt_d = @_load_ticket_d_via_slug_d.fetch slug_d

          _lt = @_load_tickets.fetch lt_d

          _button = Inferred_Button___.new sct.hotstring, sct.rest, _slug, _lt
          @_sct_a[ lt_d ] = _button
        end

        remove_instance_variable :@_sct_a
      end
    end

    class Inferred_Button___

      def initialize hs, rest, whole, lt
        @load_ticket = lt
        @hotstring_for_expression = hs
        @hotstring_to_resolve_selection = whole
        @tail = rest
      end

      def head
        NIL_
      end

      attr_reader(
        :hotstring_for_expression,
        :hotstring_to_resolve_selection,
        :load_ticket,
        :tail,
      )
    end

    Custom_Button____ = self
    class Custom_Button____

      def initialize s, s_, s__, lt
        @head = s
        @hotstring_for_expression = s_
        @load_ticket = lt
        @tail = s__
      end

      attr_reader(
        :head,
        :hotstring_for_expression,
        :load_ticket,
        :tail,
      )

      alias_method(
        :hotstring_to_resolve_selection,
        :hotstring_for_expression,
      )
    end
  end

  end
end
