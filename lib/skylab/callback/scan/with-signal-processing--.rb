module Skylab::Callback

  class Scan

    class With_Signal_Processing__ < self

      # apologies to real life signal-processing. this is a goofball experiment:
      # we want to associate with our glorified proc a dictionary of callbacks.
      # in order for the topic proc to go thru its many transformations (maps,
      # reduces etc) all the while carrying with it these same callbak procs,
      # we deem it easiet to make (what is effectively) a singleton class for
      # each such topic proc. this way during transformations it does the
      # right thing automatically, because each object that spawns off of this
      # one has the same class with the same dictionary (struct) inside of it.

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
