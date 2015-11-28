require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - iso. - desc intro" do

    extend TS_
    use :CLI_isomorphic_methods_client

    context "`description` (for an action)" do

      it "makes" do
        client_class_
      end

      it "shows" do

        invoke 'wingzors', '-h'

        _lib = Home_::TestSupport.lib_ :CLI_expect_section
        _lines = sout_serr_line_stream_for_contiguous_lines_on_stream :e

        tr = _lib.tree_via_line_stream_ _lines

        unstyle_styled = Home_::CLI::Styling::Unstyle_styled

        styled = -> line do
          line.chomp!  # meh
          unstyle_styled[ line ]
        end

        desc = tr.children.fetch 1

        styled[ desc.x.line ].should eql 'description'

        cx = desc.children
        cx.length.should eql 3
        cx.first.x.line.should eql "  line 1.\n"
        styled[ cx[ 1 ].x.line ].should eql "  line two."
        cx.last.x.line.should eql "\n"
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
