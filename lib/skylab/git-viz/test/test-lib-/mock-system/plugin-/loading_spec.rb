require_relative 'test-support'

module Skylab::GitViz::TestSupport::Test_Lib_::Mock_System::Plugin_

  describe "[gv] test-lib- mock system plugin- loading" do

    context "one" do

      before :all do

        class Mandango

          GitViz::Test_Lib_::Mock_System::Plugin_::Host[ self ]
          GitViz::Autoloader_[ self, TS__.dir_pathname.join( 'mandango' ) ]

          def initialize
            m = method :raise
            class << m
              alias_method :<<, :call
            end
            @y = m
          end

          def init_plugins
          end

          public :load_plugins, :emit_to_plugins

          spec = build_mutable_callback_tree_specification
          spec << :on_zwagolio
          Callback_Tree__ = spec.flush

          def ohai
            @did = :yep
            :bingo
          end
          attr_reader :did

        end
      end

      it "o" do
        man = Mandango.new
        man.load_plugins
        r = man.emit_to_plugins :on_zwagolio
        man.did.should eql :yep
        r.should eql :bingo
      end
    end
  end
end
