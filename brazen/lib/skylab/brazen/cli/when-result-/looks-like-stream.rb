module Skylab::Brazen

  class CLI  # magic results are [#021]

    class When_Result_::Looks_like_stream  # :[#068] for the list shape.

      def initialize x, ada, expag, resources
        @adapter = ada
        @expag = expag
        @resources = resources
        @upstream = x
        io = resources.sout
        @y = ::Enumerator::Yielder.new do | s |
          io.puts s
        end
      end

      def execute

        if @upstream.respond_to? :gets
          @_is_single_item = false
          __via_stream

        else
          @_is_single_item = true
          @_item = @upstream
          @upstream = Callback_::Scn.the_empty_stream
          _when_at_least_one_item
        end
      end

      def __via_stream

        @_item = @upstream.gets

        if @_item
          _when_at_least_one_item

        else
          @resources.serr.puts "empty."
          ACHIEVED_
        end
      end

      def _when_at_least_one_item

        __resolve_name

        express_current_item =
          __niladic_proc_to_express_future_item_using_current_item_as_prototype

        @_count = 1
        begin

          express_current_item[]

          if ! @_keep_looping
            break
          end

          x = @upstream.gets
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

      def __resolve_name

        @_name = if @_item.respond_to? :name  # #open [#107] will change this name
          @_item.name
        else

          cls = @_item.class

          name_s = cls.name
          if name_s
            Callback_::Name.via_module_name name_s
          else
            Callback_::Name.via_module cls.superclass
          end
        end
        NIL_
      end

      def __niladic_proc_to_express_future_item_using_current_item_as_prototype

        @_keep_looping = true

        x = @_item

        if x.respond_to? :express_into_under
          __niladic_proc_to_express_current_item_in_the_common_way x

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
          @y << @_item
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

        p = When_Result_::Looks_like_stream__::Build_listing_expresser[ @expag, @_item ]

        -> do
          @_keep_looping = p[ @_item, @y ]
          NIL_
        end
      end

      def __niladic_proc_to_express_current_item_in_the_common_way x

        if x.respond_to? :express_of_via_into_under

          pe = x.express_of_via_into_under @y, @expag
        end

        if pe
          -> do
            y = pe.call @_item
            if ! y
              @_keep_looping = y
            end
            NIL_
          end
        else
          -> do
            y = @_item.express_into_under @y, @expag
            if ! y
              @_keep_looping = y
            end
            NIL_
          end
        end
      end

      def __finish_when_was_stream

        d = @_count
        nm = @_name
        serr = @resources.serr

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
        elsif 1 == d
          nm.as_human
        else
          @expag.calculate do
            plural_noun nm.as_human
          end
        end

        @expag.calculate do
          if 1 == d
            serr.puts "(one #{ surface } total)"
          else
            serr.puts "(#{ d } #{ surface } total)"
          end
        end

        if @_keep_looping
          SUCCESS_EXITSTATUS
        else
          GENERIC_ERROR_EXITSTATUS
        end
      end

      Self_ = self
    end
  end
end
