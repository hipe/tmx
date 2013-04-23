module Skylab::Basic

  module List::Evented::Articulation

    def self.[] enum, def_blk

      enum.respond_to? :next or enum = List::To::Enum[ enum ]

      line = nil ; count = 0
      gets = -> do
        begin
          line = enum.next
          count += 1
          true
        rescue ::StopIteration
          line = nil
          nil
        end
      end

      call = -> f, *a do
        f[ *a ] if f
      end

      o = Conduit_.to_struct def_blk
      call[ o.always_at_the_beginning ]
      if gets[]
        call[ o.any_first_line, line ]
        while gets[]
          call[ o.any_subsequent_lines, line ]
        end
      else
        call[ o.iff_zero_items ]
      end
      if count.nonzero?
        call[ o.at_the_end_iff_nonzero_items ]
      end

      count
    end

    Conduit_ = MetaHell::Enhance::Conduit.new %i|
      always_at_the_beginning
      iff_zero_items
      any_first_line
      any_subsequent_lines
      at_the_end_iff_nonzero_items
    |
  end
end
