module Skylab::SearchAndReplace

  class Interface_Models_::Files_by_Grep

    def description
      'list the matching filenames (but not the strings)'
    end

    def initialize egrep_regexp_s, ruby_regexp, f_b_f, nf

      @do_highlight = nil
      @files_by_find = f_b_f
      @for = :paths
      @grep_extended_regexp_string = egrep_regexp_s
      @name_ = nf
      @ruby_regexp = ruby_regexp
    end

    attr_reader(
      :name_,
      :grep_extended_regexp_string,
      :ruby_regexp,
    )

    attr_writer(
      :do_highlight,
    )

    def interpret_component st, & pp

      if st.no_unparsed_exists  # we are buttonlike

        Callback_::Bound_Call[ nil, dup._init_as_hot( & pp ), :_to_path_stream ]
      end
    end

    def to_file_path_stream * x_a, & pp

      call = dup._init_as_hot( & pp )
      Parameters_[ for: nil ].init call, x_a
      call._to_path_stream
    end

    def _init_as_hot & pp
      @_pp = pp ; self
    end

    # == line of demarcation of mutatability (cold above, hot below)

    def _to_path_stream

      _ok = __resolve_file_upstream_using_find
      _ok &&= ___file_stream_via_file_upstream
    end

    def ___file_stream_via_file_upstream

      o = Home_::Magnetics_::Grep_Path_Stream_via_Parameters.new( & @_pp )
      o.grep_extended_regexp_string = @grep_extended_regexp_string
      o.for = @for
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
  end
end

# #history: this splintered off of node [#003]
