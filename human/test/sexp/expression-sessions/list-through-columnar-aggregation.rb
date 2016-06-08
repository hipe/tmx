module Skylab::Human::TestSupport

  module Sexp::Expression_Sessions::List_Through_Columnar_Aggregation

    def self.[] tcc
      tcc.include self
    end

    a = [ :list, :through, :columnar_aggregation ]
    define_method :subject_call_ do |*sx|
      sx[ 0, 0 ] = a
      Home_::Sexp.expression_session_via_sexp sx
    end

    def push * s_a
      i_a = subject.field_i_a
      x_a = []
      s_a.each_with_index do |s, d|
        x_a.push i_a.fetch( d ), s
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

    def expect_line s
      s_ = output_scn.gets
      s_.should eql s
    end

    def expect_no_more_lines
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
      Common_::Scn.new do
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
