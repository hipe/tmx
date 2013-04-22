module Skylab::Cull

  module Models::Event

    build_class = nil

    -> do  # `new`

      ok = ::Struct.new( :opt ).new

      define_singleton_method :new do |&blk|
        a = blk.parameters.reduce [] do |m, (t, n)|
          ok[ t ]
          m << n
          m
        end
        build_class[ a, blk ]
      end
    end.call

    build_class = -> a, blk do
      a.freeze
      st = ::Struct.new( *a )
      st.class_exec do
        define_method :message_function do
          vals = -> { values }
          -> do
            instance_exec( * vals[], &blk )
          end
        end
        aa = ( 0.upto( a.length - 1 ) ).to_a.freeze
        flip_h = ::Hash[ a.each_with_index.map.to_a ].freeze
        class << self
          alias_method :cull_build, :[]
        end
        define_singleton_method :[] do |h|
          aaa = aa.dup
          aaaa = [ ]
          h.each_pair do |k, v|
            idx = flip_h.fetch k
            aaa[ idx ] = nil
            aaaa[ idx ] = v
          end
          aaa.compact!
          if aaa.length.nonzero?
            raise ::ArgumentError, "missing #{ aaa.map { |i| a[i] } * ', ' }"
          end
          st.new( * aaaa )
        end
      end
      st
    end
  end
end
