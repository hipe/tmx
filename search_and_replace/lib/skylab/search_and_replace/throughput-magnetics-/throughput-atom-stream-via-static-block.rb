module Skylab::SearchAndReplace

  class ThroughputMagnetics_::Throughput_Atom_Stream_via_Static_Block

    def initialize charpos, ltss, big_string
      @big_string = big_string
      @charpos = charpos
      @LTSs = ltss
    end

    def execute

      @_state = :__initial_atom

      Common_.stream do  # #[#032]
        send @_state
      end
    end

    def __initial_atom

      @_current_charpos = @charpos
      @_LTS_st = Stream_[ @LTSs ]

      _reinit_atom_cache @_LTS_st.gets

      @_state = :__main

      :static
    end

    def __main

      x = @_atom_stream.gets
      if x
        x
      else
        lts = @_LTS_st.gets
        if lts
          _reinit_atom_cache lts
          @_atom_stream.gets  # guaranteed
        else
          @_state = :_PROBABLY_NEVER_but_you_could
          lts
        end
      end
    end

    def _reinit_atom_cache lts

      a = []
      d = @_current_charpos
      d_ = lts.charpos
      if d != d_
        a.push :content, @big_string[ d ... d_ ]
      end

      a.push :LTS_begin, lts.string, :LTS_end

      @_current_charpos = lts.end_charpos

      @_atom_stream = Stream_[ a ]
      NIL_
    end
  end
end
# #history: replaced genetic ancestor file(s) in a different location
