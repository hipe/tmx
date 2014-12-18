module Skylab::Brazen

  class CLI  # magic results are [#021]

    class When_Result_::Looks_like_stream

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

      def when_at_least_one_item

        @name = if @item.respond_to? :name_function
          @item.name_function
        else
          Callback_::Name.via_module @item.class
        end

        @count = 1
        begin
          via_item
          @ok or break
          @item = @upstream.gets
          @item or break
          @count += 1
          redo
        end while nil

        finish_when_at_least_one
      end

      def via_item
        if @item.respond_to? :execute
          via_item_execute
        else
          via_item_default
        end
        if ! @ok
          @count -= 1  # since it will short circuit ..
        end
        nil
      end

      def via_item_default
        @ok = @item.render_all_lines_into_under @y, @expag
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
        @expag.calculate do
          if 1 == d
            serr.puts "(one #{ nm.as_human } total)"
          else
            serr.puts "(#{ d } #{ plural_noun nm.as_human } total)"
          end
        end

        @ok ? SUCCESS_ : GENERIC_ERROR_
      end
    end
  end
end
