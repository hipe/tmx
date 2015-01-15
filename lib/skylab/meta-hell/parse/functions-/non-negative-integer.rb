module Skylab::MetaHell

  module Parse

    class Functions_::Non_Negative_Integer < Parse::Function_::Field

      define_method :call, -> do

        _RX = /\A\d+\z/

        -> input_stream do
          tok_o = input_stream.current_token_object
          if _RX =~ tok_o.value_x
            input_stream.advance_one
            Parse_::Output_Node_.new tok_o.value_x.to_i
          end
        end
      end.call
    end
  end
end
