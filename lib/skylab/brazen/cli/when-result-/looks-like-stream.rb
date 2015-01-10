module Skylab::Brazen

  class CLI  # magic results are [#021]

    class When_Result_::Looks_like_stream  # :[#068] for the list shape.

      def initialize ada, x
        @adapter = ada
        @upstream = x
        @expag = ada.expression_agent
        io = ada.resources.sout
        @y = ::Enumerator::Yielder.new do | s |
          io.puts s
        end
      end

      def execute
        @item = @upstream.gets
        if @item
          when_at_least_one_item
        else
          when_no_items
        end
      end

      def when_no_items
        @adapter.resources.serr.puts "empty."
        ACHIEVED_
      end

      def when_at_least_one_item

        @name = if @item.respond_to? :name
          @item.name
        else
          Callback_::Name.via_module @item.class
        end

        @via_item = if @item.respond_to? :execute or
          @item.respond_to? :render_all_lines_into_under or
            ! @item.class.respond_to? :properties
          method :per_item
        else
          __build_listing_expresser
        end

        @count = 1
        begin
          @via_item[]
          @ok or break
          @item = @upstream.gets
          @item or break
          @count += 1
          redo
        end while nil

        finish_when_at_least_one
      end

      def __build_listing_expresser
        p = When_Result_::Looks_like_stream__::Build_listing_expresser[ @expag, @item ]
        -> do
          @ok = p[ @item, @y ]
          nil
        end
      end

      def per_item
        if @item.respond_to? :execute
          via_item_execute
        elsif @item.respond_to? :render_all_lines_into_under
          @ok = @item.render_all_lines_into_under @y, @expag
        else
          @y << @item
          @ok = true
        end
        if ! @ok
          @count -= 1  # since it will short circuit ..
        end
        nil
      end

      def via_item_execute
        @ok = @item.execute
        nil
      end

      def finish_when_at_least_one

        d = @count
        nm = @name
        serr = @adapter.resources.serr

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

        @ok ? SUCCESS_ : GENERIC_ERROR_
      end

      Self_ = self
    end
  end
end
