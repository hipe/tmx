require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI microservice toolkit - desc intro" do

    TS_[ self ]
    use :CLI_microservice_toolkit

    context "`description` (for an action)" do

      it "makes" do
        client_class_
      end

      context "(state)" do

        shared_subject :state_ do
          immutable_helpscreen_state_via_invoke_ 'wingzors', '-h'
        end

        it "succeeds" do
          expect( state_.exitstatus ).to be_zero
        end

        it "description section (NOT TIGHT)" do

          _ = state_.lookup "description"

          _act = _.to_string :unstyled

          expect( _act ).to eql <<-HERE.unindent
            description
              line 1.
              line two.

          HERE
        end

        it "option section (OK to toss?)" do

          _ = state_.lookup "option"

          _act = _.to_body_string :string

          expect( _act ).to match %r(\A[ ]+-h, --help[ ]{2,}this screen\n\n\z)
        end

        it "argument section" do

          t = state_.lookup "argument"

          expect( t.children.length ).to eql 1

          expect( t.children.first.x.unstyled_header_content ).to eql '<a>'
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
