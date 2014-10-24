module Skylab::Face

  module Model

    module Event  # (this will be asorbed into [br] one day)

      class << self

        def new & p
          name_i_a = p.parameters.reduce [] do |m, (type_i, name_i)|
            VALID_TYPE__[ type_i ]
            m.push name_i
            m
          end
          Build_class__[ name_i_a, p ]
        end
      end

      VALID_TYPE__ = ::Struct.new( :opt ).new

      Build_class__ = -> name_i_a, p do
        name_i_a.freeze
        ::Struct.new( * name_i_a ).class_exec do
          define_method :message_proc do
            values_p = -> do
              values  # the struct method
            end
            -> do
              _x_a = values_p[]
              instance_exec( * _x_a, & p )
            end
          end
          aa = ( 0.upto( name_i_a.length - 1 ) ).to_a.freeze
          flip_h = ::Hash[ name_i_a.each_with_index.map.to_a ].freeze
          class << self
            alias_method :face_build, :[]
          end
          define_singleton_method :[] do |* x_a |
            if 1 == x_a.length
              # #todo this will be phased out - passing hashes
              self._WHERE
              x_a = x_a.first.each_pair.reduce [] do |m, a|
                m.concat a ; m
              end
            end
            aaa = aa.dup
            aaaa = []
            x_a.each_slice 2 do |k, v|
              idx = flip_h.fetch k
              aaa[ idx ] = nil
              aaaa[ idx ] = v
            end
            aaa.compact!
            if aaa.length.zero?
              new( * aaaa )
            else
              raise ::ArgumentError, "missing #{ aaa.map { |i| name_i_a[i] } * ', ' }"
            end
          end
          self
        end
      end

      class Aggregation

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
              Aggregate[ :a, @a ]
            end
          end
        end
      end

      Aggregate = new do |a|
        _scn = Callback_.scan.via_nonsparse_array a
        scn = Callback_::Scn.articulators.eventing(
          :gets_under, _scn,
          :iff_zero_items, -> y do
            y << "(empty)"
          end,
          :any_first_item, -> y, o do
            y << o.message_proc[]
          end,
          :any_subsequent_items, -> y, o do
            s = o.message_proc[]
            _sep = if Lib_::String_lib[].looks_like_sentence s
               SPACE_
            else
              ' - '
            end
            y << "#{ _sep }#{ s }"
          end )
        s_a = []
        while s = scn.gets
          s_a.push s
        end
        s_a * EMPTY_S_
      end
    end  # event
  end  # model
end  # [fa]
