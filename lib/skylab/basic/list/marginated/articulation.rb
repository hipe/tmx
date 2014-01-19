module Skylab::Basic

  # an answer to [#015] .. one day we might refactor underneath to etc.
  # but we intentionally built this from the outside in (yes, behavior-
  # driven) while avoiding looking at the other 2 similar neighbors so
  # that our interface is pure and minimal.
  #
  # also (now that i look) they operate fundamentally differently.
  # this one is more of a listener, the other enumerates its input
  # at calltime.

  class List::Marginated::Articulation

    -> do  # `initialize`

      define_method :initialize do | *a, &b |
        a << b if b
        1 == ( a ).length or raise ::ArgumentError, "need one separator #{
          }or one definition blocks. you provided #{ a.length }"
        b ||= -> do
          sep = a.fetch 0
          -> { any_subsequent_items -> x { "#{ sep }#{ x }" } }
        end.call
        io = Library_::StringIO.new
        o = Conduit_.to_struct b
        count = 0
        @add = -> str do
          if count.zero?
            s = ( o.any_first_item || -> ss { ss } ).call str
          else
            s = o.any_subsequent_items.call str
          end
          s and io.write s
          count += 1
          nil
        end
        @flush = -> do  # reset state completely! so you can run again
          count = 0
          io.rewind ; s = io.read ; io.rewind ; io.truncate 0 ; s   # sic
        end
        @count = -> { count }
        nil
      end
    end.call

    MetaHell::Function self, :@add, :<<, :flush, :count

    Conduit_ = MetaHell::Enhance::Conduit.new %i|
      any_first_item
      any_subsequent_items
    |  # NOTE keep the above consistent with neighbors!
  end
end
