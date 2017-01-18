module Skylab::Zerk::TestSupport

  a = %i( red green blue )
  h = ::Hash[ a.map { |k| [k, true] } ]

  Fixture_Top_ACS_Classes::Class_72_Color = -> st, & pp do

    sym = st.head_as_is
    if h[ sym ]
      st.advance_one
      Common_::Known_Known[ sym ]
    else
      pp[ nil ].call :error, :bad_color
      UNABLE_
    end
  end
end
