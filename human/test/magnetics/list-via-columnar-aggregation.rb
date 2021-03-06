module Skylab::Human::TestSupport

  module Magnetics::List_Via_Columnar_Aggregation  # this name ich muss sein

    def self.[] tcc
      tcc.include self
    end

    a = [ :list, :via, :columnar_aggregation ]
    define_method :subject_call_ do |*sx|
      sx[ 0, 0 ] = a
      Home_::Sexp.__expression_session_via_sexp sx
    end

    def push_mixed * x_a
      _push x_a, To_s___
    end

    To_s___ = :to_s.to_proc

    def push_symbols * sym_a
      _push sym_a, Id2name___
    end

    Id2name___ = :id2name.to_proc

    def push * s_a
      _push s_a, Home_::IDENTITY_
    end

    def _push in_x_a, p
      i_a = subject.field_i_a
      x_a = []
      in_x_a.each_with_index do |x, d|
        x_a.push i_a.fetch( d ), p[ x ]
      end
      push_input_frame_iambic x_a ; nil
    end

    def with * a_a
      concat_input_a_a a_a ; nil
    end

    def concat_input_a_a a_a
      @input_scn ||= bld_input_scn
      @a_a.concat a_a ; nil
    end

    def push_input_frame_iambic x_a
      @input_scn ||= bld_input_scn
      @a_a.push x_a ; nil
    end

    def want_line s
      s_ = output_scn.gets
      expect( s_ ).to eql s
    end

    def want_no_more_lines
      s = output_scn.gets
      s and fail "no: #{ s.inspect }"
    end

    def output_scn
      @output_scn ||= bld_output_scn
    end

    def bld_output_scn
      @input_scn ||= bld_input_scn
      subject.map_reduce_under @input_scn
    end

    def bld_input_scn
      @a_a = []
      Common_::MinimalStream.by do
        @a_a.shift
      end
    end

    def debug_flush
      output_scn
      count = 0 ; io = debug_IO
      while x = @output_scn.gets
        count += 1
        io.puts "#{ count }: #{ x.inspect }"
      end
      if count.zero?
        io.puts "(no output)"
      end ; nil
    end
  end
end
