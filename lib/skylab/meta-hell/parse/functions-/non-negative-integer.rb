module Skylab::MetaHell

  module Parse

    module Functions_::Non_Negative_Integer

      class << self

        def via_iambic_stream _
          P___
        end
      end  # >>

      P___ = -> do

        _RX = /\A\d+\z/

        -> input_stream do
          tok_o = input_stream.current_token_object
          if _RX =~ tok_o.value_x
            Parse_::Output_Node_.new tok_o.value_x.to_i
          end
        end
      end.call
    end
  end
end
