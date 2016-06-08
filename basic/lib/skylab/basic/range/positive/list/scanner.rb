module Skylab::Basic

  class Range::Positive::List::Scanner

    State_ = ::Struct.new :i, :rx, :a, :act

    Dsc_ = { '\d+' => 'integer' }

    def initialize
      _state_h = { }

      _state = complete = ick = nil
      curr = Range::Positive::Mutable_::OneWay.new

      reset = -> do
        curr.reset
        _state = _state_h.fetch :start
        _state.act[ nil ]  # (future-proof)
        complete = ick = nil
      end

      state = ->( *a ) do
        st = State_[ *a ]
        _state_h[ st.i ] = st
      end

      state[ :start, nil,  [ :beginning ], -> x do
                                        end ]
      state[ :beginning, /\d+/, [ :dash, :comma ],
                                           -> x do
                                          curr.begin = x.to_i
                                          complete = true
                                        end ]
      state[ :dash, /-/,      [ :ending ], -> _ do
                                          complete = false
                                        end ]
      state[ :comma, /,/,     [ :beginning ],  -> x do
                                          ick = true
                                        end ]
      state[ :ending, /\d+/,  [ :comma ],  -> x do
                                          curr.end = x.to_i
                                          complete = true
                                        end ]

      reset[]

      scn = Home_.lib_.empty_string_scanner

      @set_string = -> x do
        reset[]
        scn.string = x
      end

      up = nil

      @gets = -> do
        ok = true ; res = nil ; ick = nil
        while ! scn.eos?
          nxt = _state.a.reduce nil do |_, i|
            st = _state_h.fetch i
            str = scn.scan st.rx
            if str
              st.act[ str ]
              break st
            end
          end
          if nxt
            _state = nxt
            break if ick
          else
            res = up[ scn.rest, _state.a.map do |i|
              st = _state_h.fetch i
              a = [ st.i ]
              xx = Dsc_[ st.rx.source ] and a << xx
              a * ' '
            end ]
            break( ok = false )
          end
        end
        if ok
          if complete
            curr.flush
          end
        else
          res
        end
      end

      @set_unexpected_proc = -> x {  up = x }
    end

    Common_::Session::Ivars_with_Procs_as_Methods.call self,
      :@set_unexpected_proc, :unexpected_proc=,
        :@set_string, :string=, :gets

  end
end
