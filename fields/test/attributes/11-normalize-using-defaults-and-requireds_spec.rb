require_relative '../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes   # #[#017]

  module Attributes

    TS_.describe "[fi] attributes - normailze using defaults & requireds" do

      TS_[ self ]
      use :memoizer_methods

      context "(those that are not optional are required.)" do

        shared_subject :_guy do
          class XNuDR_A

            ATTRIBUTES = Subject_module_[].call(
              alpha: :optional,
              beta: nil,
              gamma: :optional,
              delta: nil,
            )

            attr_writer( * ATTRIBUTES.symbols )

            self
          end
        end

        it "raises argument error" do
          _msg = "missing required attributes 'beta' and 'delta'"

          o = _guy.new
          begin
            _subject[ o ]
          rescue ::ArgumentError => e
          end

          e.message.should eql _msg
        end
      end

      def _subject
        Subject_module_[]::Lib::Normalize_using_defaults_and_requireds
      end
    end
  end
end
