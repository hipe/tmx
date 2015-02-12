module Skylab::TestSupport

  module DocTest

    module Input_Adapter_::Comment_block_via_single_line_matchdata_array

      define_singleton_method :[] do |md_a|

        Callback_::Stream.via_nonsparse_array md_a do |md|
          md
        end
      end
    end
  end
end
