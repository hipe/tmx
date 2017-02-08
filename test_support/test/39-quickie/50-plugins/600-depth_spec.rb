require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - plugins - depth" do

    TS_[ self ]
    use :memoizer_methods
    use :quickie_plugins

    context "(not hacked path)" do

      # - API

        it "API - must look like range" do

          call :depth, 'xx'
          expect :error, :expression, :primary_parse_error do |y|
            y == [ %('depth' must be an integer or range (had: "xx")) ] || fail
          end
          expect_fail
        end

        it "API - must be a forward range" do

          call :depth, '5-4'
          expect :error, :expression, :primary_parse_error do |y|
            y == [ "'depth' min must be less than or equal to max (min: 5, max: 4)" ] || fail
          end
          expect_fail
        end
      # -
    end

    # - context (hacked path)

      context "API - yay" do

        it "it reduces the list" do
          expect_these_lines_in_array_ _tuple[0] do |y|
            y << 'dip/dop/doop/deep/dope'
            y << 'fanduckle/fondookel/fif-diffle/foip'
          end
        end

        it "CHECK OUT HOW GREAT THIS LINGUISTICISM IS" do
          _tuple[1] == [ "(filtering out 1 spec file #{
           }because of its raw depth less than 3 #{
            }and 1 because of its depth greater than 4.)" ] || fail
        end

        shared_subject :_tuple do

          call :depth, '2-3', :list_files, :path, 'mock-key-1'

          use_fake_paths_ 'mock-key-1' do |y|
            y << 'dip/dop/doop/deep/dope'                  # 5 deep
            y << 'duck/duck/goose'                         # 3 deep
            y << 'uno/dos/tres/quatro/cinco/seis/siete'    # 7 deep
            y << 'fanduckle/fondookel/fif-diffle/foip'     # 4 deep
          end

          msgs = nil
          expect :info, :expression do |y|
            msgs = y
          end

          _these = finish_by do |st|
            st.to_a
          end

          [ _these, msgs ]
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
