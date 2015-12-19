module Skylab::BeautySalon::TestSupport

  module Models::Search_And_Replace::Actors::Build_Replace_Function::Support

    def self.[] tcc
      TS_::Expect_Event[ tcc ]
      tcc.include self
    end

    def rf_ replace_function_string

      _oes_p = event_log.handle_event_selectively

      @replace_function = __subject_module::Actors_::Build_replace_function[

        replace_function_string,

        :_no_work_dir_,

        & _oes_p ]
      NIL_
    end

    def rx_ rx
      @ruby_regexp = rx ; nil
    end

    def against_ input_string
      @output_string = input_string.gsub @ruby_regexp do
        @replace_function.call $~
      end
      NIL_
    end

    def expect_ expect_string
      @output_string.should eql expect_string
    end

    define_method :unindent_, Models::Search_And_Replace::UNINDENT_

    def __subject_module
      Models::Search_And_Replace::Subject_module_[]
    end
  end
end
