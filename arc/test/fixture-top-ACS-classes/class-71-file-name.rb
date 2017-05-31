module Skylab::Arc::TestSupport

  fn_rx = %r(\A[^/])
  fnm = nil

  Fixture_Top_ACS_Classes::Class_71_File_Name = -> arg_st, & oes_p_p do

    if arg_st.no_unparsed_exists
      # experimental to use #![#002]Detail-one
      Common_::KNOWN_UNKNOWN
    else
      fnm[ arg_st, & oes_p_p ]
    end
  end

  fnm = -> arg_st, & oes_p_p do

    x = arg_st.gets_one
    if x.length.zero?
      self._K
    elsif fn_rx =~ x
      Common_::KnownKnown[ x ]
    else
      _oes_p = oes_p_p[ nil ]
      _oes_p.call :error, :expression, :invalid_value do | y |
        y << "paths can't be absolute - #{ ick x }"
      end
      UNABLE_
    end
  end
end
