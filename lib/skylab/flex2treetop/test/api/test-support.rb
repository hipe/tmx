require_relative '../my-test-support'

module Skylab::Flex2Treetop::MyTestSupport

  module API

    module ModuleMethods
      include Headless::ModuleMethods
    end

    module InstanceMethods
      include Headless::InstanceMethods

      # ~ test phase

      # ~~ isolate these API parameter terms to accomodate syntax changes

      def emitters
        errstrm = _IO_spy_group[ :stderr ]
        puts_p = errstrm.method :puts
        [ :emit_info_line_p, puts_p,
          :emit_info_string_p, puts_p,
          :pp_IO_for_show_sexp, errstrm ]
      end

      def outpath x
        [ :paystream_via, :path, x ]
      end

      # ~~

      def add_any_outstream_to_IO_spy_group grp  # #hook-out
        grp.add_stream :stdout, :_no_outstream_
      end  # (API actions probably never write to STDOUT)

      def mini
        fixture :mini
      end

      def _API_invoke * x_a
        @result = Flex2Treetop::API.invoke x_a[ 0 ],
          :program_name, PROGNAME,
          :errstream, _IO_spy_group[ :stderr ], * x_a[ 1 .. -1 ]
      end
    end

    PROGNAME = 'f2tt'.freeze
  end
end
