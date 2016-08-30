module Skylab::DocTest::TestSupport

  module My_API

    def self.[] tcc
      Home_.lib_.zerk.test_support::API[ tcc ]
      tcc.include self
    end

    # -

      def my_API_common_generate_ h  # mutates h

        if ! h.key? :output_adapter
          h[ :output_adapter ] = :quickie
        end

        x_a = [ :synchronize ]
        h.each_pair do |k, x|
          x_a.push k, x
        end
        call_via_iambic x_a
      end

      # -- (a little odd here but meh)

      def scan_all_examples_ o

        example_count = 0

        @line_scanner = o

        it_rx = /\A(?<margin>(?:  ){1,})it \"/

        begin
          d = o.skip_blank_lines
          if 1 == d
            md = it_rx.match o.line
            if md
              o.advance_until_line_that_equals "#{ md[ :margin ] }end\n"
              example_count += 1
              redo
            end
            fail __say_not_an_example
          end

        end while nil

        remove_instance_variable :@line_scanner

        Summary_of_ScanAllExamples___.new example_count
      end

      Summary_of_ScanAllExamples___ = ::Struct.new :example_count

      def __say_not_an_example
        "not an example #{ @line_scanner.at_where 'near' }"
      end

      def subject_API
        Home_::API
      end
    # -
  end
end
