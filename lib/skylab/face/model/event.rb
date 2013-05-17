module Skylab::Face

  module Model::Event

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
          alias_method :face_build, :[]
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

  class Model::Event::Aggregation

    def initialize
      @a = nil
    end

    def << x
      if x
        ( @a ||= [ ] ) << x
      end
      nil
    end

    def flush
      if @a
        if 1 == @a.length
          @a.fetch 0
        else
          Model::Event::Aggregate[ a: @a ]
        end
      end
    end
  end

  Model::Event::Aggregate = Model::Event.new do |a|
    o = ''
    Face::Services::Basic::List::Evented::Articulation a do
      iff_zero_items               ->     { o << '(empty)' }
      any_first_item               ->   x { o << "#{ x.message_function[] }" }

      any_subsequent_items -> x do
        if Services::Headless::CLI::FUN.looks_like_sentence[ o ]
          sep = ' '
        else
          sep ' - '
        end
        o << "#{ sep }#{ x.message_function[] }"
      end
    end
    o
  end
end
