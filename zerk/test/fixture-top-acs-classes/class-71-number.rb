module Skylab::Zerk::TestSupport

  rx = /\A-?\d+(\.\d+)?\z/

  Fixture_Top_ACS_Classes::Class_71_Number = -> st, & pp do

    if st.unparsed_exists
      x = st.head_as_is
      if x.respond_to? :divmod
        ok = true
      else
        md = rx.match x
        if md
          ok = true
          if md[ 1 ]
            x = x.to_f
          else
            x = x.to_i
          end
        end
      end
      if ok
        st.advance_one
        Common_::KnownKnown[ x ]
      else
        pp[ nil ].call :error, :expression, :invalid_number do |y|
          y << "didn't look like a simple number (had: #{ ick x })"
        end
        false
      end
    end
  end
end
