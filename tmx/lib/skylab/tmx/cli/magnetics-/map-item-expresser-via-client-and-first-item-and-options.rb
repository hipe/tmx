module Skylab::TMX

  class CLI

    class Magnetics_::MapItemExpresser_via_Client_and_FirstItem_and_Options

      # for CLI (as designed and then covered), the "constituency" (i.e set
      # identity) and order (i.e left to right) of those non-first columns
      # that are displayed are only ever determined by the use of "-select"
      # terms, and in a direct way: of those "-select" terms in the argument
      # array ("ARGV"), each first occurrence (left to right) of an
      # attribute name determines its corresponding placement in the output
      # tuples (items).
      #
      # this means that even if a modifier (like "-order") must "implicitly"
      # select an attribute in order to function, this attribute will not be
      # expressed in the output unless it also appears in a "-select" term.
      #
      # fortunately we don't need to get be quite so "weedy" here: the
      # "map modification index" is suppposed to hide all of that from us,
      # giving us only the (any) attributes we need to display (in order).
      #
      # this facility can be characterized as the latest in a strain of
      # "tuple pagers" (first notated at [#br-064] and then reconceived at
      # [#ze-047]). the latter's hefty comment serves as both a good general
      # introduction to the principle here and also (in its specifics) an
      # oblique but decisive justification for why it is necessary to add
      # yet another such facility to the lineage.
      #
      # :#spot-1

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize client, first_item
        @client = client
        @first_item = first_item
        @record_separator_string = SPACE_
        @unknown_value_string = DASH_
      end

      attr_writer(
        # :record_separator_string - when designed & covered
      )

      def execute

        if __there_is_a_modification_index
          if __there_are_attributes_that_are_selected_explicitly
            __will_express_structured_expression
          else
            _will_express_name_only
          end
        else
          _will_express_name_only
        end
      end

      def __there_is_a_modification_index
        _ = @client.API_invocation_.operation_session.modification_index
        _store :@__map_modification_index, _
      end

      def __there_are_attributes_that_are_selected_explicitly
        _mmi = remove_instance_variable :@__map_modification_index
        _a = _mmi.get_any_explicitly_selected_attributes__
        _store :@__explicitly_selected_attributes, _a
      end

      def __will_express_structured_expression

        attr_a = remove_instance_variable :@__explicitly_selected_attributes
        record_separator_string = @record_separator_string
        unknown_value_string = @unknown_value_string
        y = _build_output_line_yielder

        -> item do

          buffer = item.get_filesystem_directory_entry_string

          attr_a.each do |attr|

            buffer << record_separator_string

            had = true
            x = item.box.fetch attr.normal_symbol do
              had = false
            end

            if had
              buffer << Uniform_inefficient_type_inferential_based_expression_for_now__[ x ]
            else
              buffer << unknown_value_string
            end
          end

          y << buffer
          NIL
        end
      end

      def _will_express_name_only
        y = _build_output_line_yielder
        -> item do
          item.express_into y
          NIL
        end
      end

      def _build_output_line_yielder
        sout = @client.sout
        ::Enumerator::Yielder.new do |line|
          sout.puts line  # hi.
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # ==

      Uniform_inefficient_type_inferential_based_expression_for_now__ = -> x do
        if x
          if ::TrueClass === x
            "«yes»"
          elsif x.respond_to? :ascii_only?
            if x.include? SPACE_
              x.inspect
            else
              x
            end
          else
            x.to_s
          end
        elsif x.nil?
          "«nil»"
        else
          "«no»"
        end
      end

      # ==

      SPACE_ = ' '

      # ==
    end
  end
end
