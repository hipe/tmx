module Skylab::Brazen

  module Entity

    class Event

      class Wrappers__::Universal_exception

        Actor_[ self, :properties,
          :exception ]

        def execute
          @iambic = [ produce_name_i, :exception, @exception ]
          add_values_to_iambic
          e = @exception
          build_event_via_iambic @iambic do |y, o|
            y << e.message
          end
        end

        def produce_name_i
          s_a = @exception.class.name.split Callback_::CONST_SEP_
          sub_slice = s_a[ -3, 2 ]
          sub_slice ||= s_a
          s_a_ = sub_slice.map { |s| s.sub TRAILING_UNDERSCORES_RX__, EMPTY_S_ }
          s_a_.join( UNDERSCORE_ ).downcase.intern ; nil
        end
        TRAILING_UNDERSCORES_RX__ = /_+\z/

        def add_values_to_iambic
          @exception.members.each do |i|
            @iambic.push i, @exception.send( i )
          end ; nil
        end

        include Event::Builder_Methods

      end
    end
  end
end
