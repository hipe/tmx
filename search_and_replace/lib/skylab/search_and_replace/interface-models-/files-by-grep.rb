module Skylab::SearchAndReplace

  class Interface_Models_::Files_by_Grep

    def description
      # 'see the matching strings (not just files)'
      'list the matching filenames (but not the strings)'
    end

    def initialize egrep_regexp_s, ruby_regexp, f_b_f, nf

      @custom_intent_symbol = :read_only
      @do_highlight = nil
      @files_by_find = f_b_f
      @grep_extended_regexp_string = egrep_regexp_s
      @name_ = nf
      @ruby_regexp = ruby_regexp
    end

    attr_writer(
      :custom_intent_symbol,
      :do_highlight,
    )

    attr_reader :name_

    def interpret_component st, & pp

      if st.no_unparsed_exists  # we are buttonlike

        Callback_::Bound_Call[ nil, dup, :___to_path_stream, & pp ]
      end
    end

    # == line of demarcation of mutatability (cold above, hot below)

    def ___to_path_stream & pp

      @_pp = pp
      _ok = __resolve_file_upstream_using_find
      _ok &&= ___file_stream_via_file_upstream
    end

    def ___file_stream_via_file_upstream

      o = Home_::Magnetics_::Grep_Path_Stream_via_Parameters.new( & @_pp )
      o.grep_extended_regexp_string = @grep_extended_regexp_string
      o.mode = :paths
      o.ruby_regexp = @ruby_regexp
      o.upstream_path_stream = @_file_upstream
      o.execute
    end

    def __resolve_file_upstream_using_find

      st = @files_by_find.invoke( & @_pp )
      if st
        @_file_upstream = st ; ACHIEVED_
      else
        st
      end
    end

    def ____FLOATING____file_session_stream_via_file_stream file_st, & pp

      _ = Home_::Magnetics_::File_Stream_via_Parameters.with(
        :upstream_path_stream, file_st,
        :grep_extended_regexp_string, @grep_extended_regexp_string,
        :ruby_regexp, @ruby_regexp,
        :do_highlight, @do_highlight,
        @custom_intent_symbol,
        & pp[ self ] )
      _
    end
  end
end

# #history: this splintered off of node [#003]
