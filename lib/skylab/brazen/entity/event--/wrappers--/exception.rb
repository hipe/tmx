module Skylab::Brazen

  module Entity

    class Event__

      class Wrappers__::Exception

        Actor_[ self, :properties,
          :exception ]

        def execute
          @iambic = [ produce_name_i, :exception, @exception ]
          e = @exception
          e.respond_to? :members and add_values_to_iambic
          build_event_via_iambic @iambic do |y, o|
            y << e.message
          end
        end

        def produce_name_i
          s_a = @exception.class.name.split Callback_.const_sep
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
      end
    end
  end
end
