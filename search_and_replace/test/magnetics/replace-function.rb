module Skylab::SearchAndReplace::TestSupport

  module Magnetics::Replace_Function

    def self.[] tcc
      tcc.include self
    end

    def rf_ replace_function_string

      _oes_p = event_log.handle_event_selectively

      _ = __subject_module::Magnetics_::Replace_Function_via_String_and_Work_Dir

      @replace_function = _[

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

    def __subject_module
      Subject_module_[]
    end
  end
end
