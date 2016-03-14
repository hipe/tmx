module Skylab::Fields

  module MetaAttributes::Enum

    Extra_Value_Event = Callback_::Event.prototype_with(
      :invalid_property_value,
      :x, nil,
      :predicate_string, nil,
      :property_name, nil,
      :enum_value_polymorphic_streamable, nil,
      :valid_value_mapper_from, nil,
      :adjective, nil,
      :error_category, :argument_error,
      :ok, false,
    ) do |y, o|
      Extra_Value_Event::Articulation___.new( y, o, self ).execute
    end

    class Extra_Value_Event::Articulation___

      # (experiment, like something similar at [#ac-007]..)

      def initialize y, o, ex
        @line_yielder = y
        @expag = ex
        @o = o
      end

      def execute
        __init
        __adjective
        __noun
        __value
        __predicate
        __did_you_mean
        __flush
      end

      def __adjective
        any_word @o.adjective ; nil
      end

      def __noun
        word @o.property_name.as_human
      end

      def __value
        me = self
        @expag.calculate do
          me.word ick me.o.x
        end
        if @o.enum_value_polymorphic_streamable
          if @o.predicate_string
            punct '.'
          else
            punct ','
          end
        end
      end

      def __predicate
        any_word @o.predicate_string
      end

      def __did_you_mean

        x = @o.enum_value_polymorphic_streamable
        if x

          x_a = ::Array.try_convert x
          if ! x_a
            x_a = x.flush_remaining_to_array
          end

          _p = o.valid_value_mapper_from || Valid_value_mapper___

          val = _p[ @expag ]

          x_a = x_a.map do | x_ |
            val[ x_ ]
          end

          _expecting = case 1 <=> x_a.length
          when -1
            "{ #{ x_a * ' | ' } }"
          when 0
            x_a.fetch 0
          when 1
            '{}'
          end

          word "expecting #{ _expecting }"
        end
      end

      def __init
        buffer = nil
        @_word = -> ss do
          buffer = ss.dup
          @_word = -> s do
            buffer.concat "#{ SPACE_ }#{ s }"
          end
          NIL_
        end
        @_punct = -> s do
          buffer.concat s
        end
        @_release_line = -> do
          remove_instance_variable :@_release_line
          x = buffer ; buffer = nil ; x
        end
      end

      def any_word s
        if s
          word s
        end
      end

      def word s
        @_word[ s ]
      end

      def punct s
        @_punct[ s ]
      end

      def __flush
        s = @_release_line[]
        @line_yielder << s
        NIL_
      end

      attr_reader :o

      Valid_value_mapper___ = -> expag do
        -> sym do
          sym.id2name
        end
      end
    end
  end
end
