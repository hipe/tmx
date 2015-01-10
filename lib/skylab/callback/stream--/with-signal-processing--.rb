module Skylab::Callback

  class Stream__

    class With_Signal_Processing__ < self  # read #open [#059] (in [#044])

      class << self

        num = 0

        define_method :[] do |p, pairs|
          cls = ::Class.new self
          const_set :"Generated_#{ num += 1 }___", cls  # easier to track down
          i_a = [] ; p_a = []
          pairs.each_slice 2 do |i, p_|
            i_a.push i ; p_a.push p_
          end
          st = produce_struct i_a
          cls.const_set :SIGNAL_HANDLERS___, st.new( * p_a )
          cls.new( & p )
        end

      private

        def produce_struct i_a
          i = :"Generated_#{ i_a * UNDERSCORE_ }_Struct___"
          if const_defined? i
            const_get i
          else
            const_set i, ::Struct.new( * i_a )
          end
        end
      end

      def receive_signal i
        self.class::SIGNAL_HANDLERS___[ i ].call
      end
    end
  end
end
