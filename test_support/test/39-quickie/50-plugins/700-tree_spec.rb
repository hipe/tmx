require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - plugins - tree" do

    TS_[ self ]
    use :quickie_plugins

    it "fun conflict - arguments that conflict reference the eventpoint graph" do
      # :[#039.3] #lend-coverage to [ta], [ze]
      # #needs-invite
      call :tree, :list_files, :path, 'xx'
      expect :error, :expression, :ambiguous do |msgs|
        expect_these_lines_in_array msgs do |y|
          y << "both 'tree' and 'list_files' transition to 'finished'"
          y << "so you can't have both of them at the same time."
        end
      end
      expect_fail
    end

    # - context (hacked path)

      context "API (hack paths)" do

        it "renders tree, stemmy-nodes are scrunched into one line" do

          call :tree, :path, 'mock-key-1'

          use_fake_paths_ 'mock-key-1' do |y|
            y << "kniff/knaff/zingo/bongo"
            y << "kniff/knaff/portobello"
            y << "kniff/knaff/zingo/fongo"
          end

          _these = finish_by do |st|
            st.to_a
          end

          expect_these_lines_in_array _these do |y|
            y << "kniff/knaff"
            y << " ├zingo"
            y << " │ ├bongo"
            y << " │ └fongo"
            y << " └portobello"
          end
        end

        def prepare_subject_API_invocation invo
          prepare_subject_API_invocation_for_fake_paths_ invo
        end
      end
    # -

    # ==
    # ==
  end
end
# #born years later
