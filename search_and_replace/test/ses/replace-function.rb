module Skylab::SearchAndReplace::TestSupport

  module SES::Replace_Function  # 1x

    def self.[] tcc
      tcc.include self
    end

    def rf_ replace_function_string

      _p = event_log.handle_event_selectively

      _ = magnetics_::Replace_Function_via_String_and_Functions_Dir

      @replace_function = _[

        replace_function_string,

        :_no_work_dir_,

        & _p ]
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

    def want_ want_string
      expect( @output_string ).to eql want_string
    end
  end
end
