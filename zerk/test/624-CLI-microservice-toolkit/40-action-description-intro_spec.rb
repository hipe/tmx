require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - iso. - desc intro" do

    TS_[ self ]
    use :CLI_isomorphic_methods_client

    context "`description` (for an action)" do

      it "makes" do
        client_class_
      end

      context "(state)" do

        shared_subject :state_ do
          immutable_helpscreen_state_via_invoke_ 'wingzors', '-h'
        end

        it "succeeds" do
          state_.exitstatus.should be_zero
        end

        it "description section (NOT TIGHT)" do

          _ = state_.lookup "description"

          _act = _.to_string :unstyled

          _act.should eql <<-HERE.unindent
            description
              line 1.
              line two.

          HERE
        end

        it "option section (OK to toss?)" do

          _ = state_.lookup "option"

          _act = _.to_body_string :string

          _act.should match %r(\A[ ]+-h, --help[ ]{2,}this screen\n\n\z)
        end

        it "argument section" do

          t = state_.lookup "argument"

          t.children.length.should eql 1

          t.children.first.x.unstyled_header_content.should eql '<a>'
        end
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_04 < subject_class_

          description do | y |
            y << "  line 1."
            y << "  line #{ highlight 'two' }."
          end

          def wingzors a
          end

          self
        end
      end
    end
  end
end
# :+#tombstone: markdown-like lists in descs get special formatting
