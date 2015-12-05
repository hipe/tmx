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
          @was_a_stream = true
          __via_stream
        else
          @item = @upstream
          @upstream = Callback_::Scn.the_empty_stream
          @was_a_stream = false
          when_at_least_one_item
        end
      end

      def __via_stream
        @item = @upstream.gets
        if @item
          when_at_least_one_item
        else
          when_no_items
        end
      end

      def when_no_items
        @resources.serr.puts "empty."
        ACHIEVED_
      end

      def when_at_least_one_item

        __resolve_name

        p = __proc_for_express_all_items_via_first_item

        @count = 1
        begin
          p[]
          @ok or break
          @item = @upstream.gets
          @item or break
          @count += 1
          redo
        end while nil

        if @was_a_stream
          finish_when_at_least_one
        else
          @ok ? SUCCESS_EXITSTATUS : GENERIC_ERROR_EXITSTATUS
        end
      end

      def __resolve_name

        @name = if @item.respond_to? :name  # #open [#107] will change this name
          @item.name
        else

          cls = @item.class

          name_s = cls.name
          if name_s
            Callback_::Name.via_module_name name_s
          else
            Callback_::Name.via_module cls.superclass
          end
        end
        NIL_
      end

      def __proc_for_express_all_items_via_first_item

        o = @item
        if o.respond_to? :execute

          method :__express_item_via_execute

        elsif o.respond_to? :express_into_under

          if o.respond_to? :express_of_via_into_under

            pr = o.express_of_via_into_under @y, @expag
          end
          if pr
            @ok = true
            @__prepared_expresser = pr
            method :__express_item_via_prepared_expresser
          else
            @ok = true
            method :__express_item_via_into_under
          end

        elsif (
          o.respond_to? :members or
          o.respond_to? :properties or
          o.respond_to? :to_component_knownness_stream
        )
          _build_listing_expresser
        else

          method :__express_item_via_to_s
        end
      end

      def __express_item_via_execute

        @ok = @item.execute
        NIL_
      end

      def __express_item_via_prepared_expresser

        _y = @__prepared_expresser.call @item
        _y or @ok = false
        NIL_
      end

      def __express_item_via_into_under

        _y = @item.express_into_under @y, @expag
        _y or @ok = false
        NIL_
      end

      def __express_item_via_to_s

        @y << @item
        @ok = true
        NIL_
      end

      def _build_listing_expresser

        p = When_Result_::Looks_like_stream__::Build_listing_expresser[ @expag, @item ]
        -> do
          @ok = p[ @item, @y ]
          nil
        end
      end

      def finish_when_at_least_one

        d = @count
        nm = @name
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

        @ok ? SUCCESS_EXITSTATUS : GENERIC_ERROR_EXITSTATUS
      end

      Self_ = self
    end
  end
end
