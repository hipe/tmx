module Skylab::Callback

  class Box

    class Struct_proxy  # see [#062]

      # note this is just the actor that builds the proxy, not the proxy iteslf

      class << self
        def [] a, h, bx
          new( a, h, bx ).execute
        end
        private :new
      end

      def initialize a, h, bx
        @a = a ; @h = h ; @bx = bx
      end

      def execute
        if @a.length.zero?
          false
        else
          work
        end
      end

      def work
        cls = ::Struct.new( * @a )
        cls.include InstanceMethods
        cls.new( * @a.map { | i | @h.fetch i } )
      end

      module InstanceMethods

        def at * i_a
          i_a.map do | sym |
            self[ sym ]
          end
        end

        def get_names
          members
        end

        def fetch i
          block_given? and self._IMPLEMENT_ME
          self[ i ]
        end
      end
    end
  end
end
