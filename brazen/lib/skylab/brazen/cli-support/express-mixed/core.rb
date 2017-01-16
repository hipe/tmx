module Skylab::Brazen

  module CLI_Support

    class Express_Mixed  # :[#068] for the list shape.

      # magic results are [#021]

      def sout= io  # convenience macro to create the line yielder

        @line_yielder = ::Enumerator::Yielder.new do | s |
          io.puts s
        end

        io
      end

      attr_writer(
        :expression_agent,
        :line_yielder,  # if you do this, don't bother with `sout`
        :mixed_non_primitive_value,
        :serr,
      )

      def execute

        if @mixed_non_primitive_value.respond_to? :gets
          @_is_single_item = false
          ___via_stream

        else
          @_is_single_item = true
          @_item = @mixed_non_primitive_value
          @mixed_non_primitive_value = Common_::SimpleStream.the_empty_stream
          _when_at_least_one_item
        end
      end

      def ___via_stream

        @_item = @mixed_non_primitive_value.gets

        if @_item
          _when_at_least_one_item

        else
          @serr.puts "empty."
          ACHIEVED_
        end
      end

      def _when_at_least_one_item

        ___resolve_name

        express_current_item =
          __niladic_proc_to_express_future_item_using_current_item_as_prototype

        @_count = 1
        begin

          express_current_item[]

          if ! @_keep_looping
            break
          end

          x = @mixed_non_primitive_value.gets
          x or break

          @_item = x
          @_count += 1
          redo
        end while nil

        if @_is_single_item
          if @_keep_looping
            SUCCESS_EXITSTATUS
          else
            GENERIC_ERROR_EXITSTATUS
          end
        else
          __finish_when_was_stream
        end
      end

      def ___resolve_name

        @_name = if @_item.respond_to? :ascii_only?
          NOTHING_
        elsif @_item.respond_to? :name  # #open [#107] will change this name
          @_item.name
        else

          cls = @_item.class

          name_s = cls.name
          if name_s
            Common_::Name.via_module_name name_s
          else
            Common_::Name.via_module cls.superclass
          end
        end
        NIL_
      end

      def __niladic_proc_to_express_future_item_using_current_item_as_prototype

        @_keep_looping = true

        x = @_item

        if x.respond_to? :express_of_via_into_under
          __niladic_proc_to_express_current_item_with_preparation x

        elsif x.respond_to? :express_into_under
          _niladic_proc_to_express_current_item_in_the_common_way

        elsif x.respond_to? :execute
          __niladic_proc_to_express_current_item_by_the_execute_method

        elsif (
          x.respond_to? :members or
          x.respond_to? :properties or
          x.respond_to? :to_component_knownness_stream
        )
          __niladic_proc_to_express_current_item_by_building_a_listing_expresser

        else
          ___niladic_proc_to_express_item_in_the_catch_all_default_manner
        end
      end

      def ___niladic_proc_to_express_item_in_the_catch_all_default_manner
        -> do
          @line_yielder << @_item
          NIL_
        end
      end

      def __niladic_proc_to_express_current_item_by_the_execute_method
        -> do
          @_keep_looping = @_item.execute
          NIL_
        end
      end

      def __niladic_proc_to_express_current_item_by_building_a_listing_expresser

        p = Here_::Build_listing_expresser___[ @expression_agent, @_item ]

        -> do
          @_keep_looping = p[ @_item, @line_yielder ]
          NIL_
        end
      end

      def __niladic_proc_to_express_current_item_with_preparation x

        pe = x.express_of_via_into_under @line_yielder, @expression_agent

        if pe
          -> do
            y = pe.call @_item
            if ! y
              @_keep_looping = y
            end
            NIL_
          end
        else
          _niladic_proc_to_express_current_item_in_the_common_way
        end
      end

      def _niladic_proc_to_express_current_item_in_the_common_way
        # -
          -> do
            y = @_item.express_into_under @line_yielder, @expression_agent
            if ! y
              @_keep_looping = y
            end
            NIL_
          end
        # -
      end

      def __finish_when_was_stream

        d = @_count
        nm = @_name
        serr = @serr

        if nm.respond_to? :verb_as_noun_lexeme
          lexeme = nm.verb_as_noun_lexeme
        end

        if ! lexeme and nm.respond_to? :noun_lexeme
          lexeme = nm.noun_lexeme
        end

        surface = if lexeme
          if 1 == d
            lexeme.singular
          else
            lexeme.plural
          end
        elsif nm
          if 1 == d
            nm.as_human
          else
            @expression_agent.calculate do
              plural_noun nm.as_human
            end
          end
        end

        if surface  # #tombstone-A (not sure we want to keep this)
        @expression_agent.calculate do
          if 1 == d
            serr.puts "(one #{ surface } total)"
          else
            serr.puts "(#{ d } #{ surface } total)"
          end
        end
        end

        if @_keep_looping
          SUCCESS_EXITSTATUS
        else
          GENERIC_ERROR_EXITSTATUS
        end
      end

      Here_ = self
    end
  end
end
# #tombstone-A: no more (total: N strings)
