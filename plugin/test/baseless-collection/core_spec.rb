require_relative '../test-support'

module Skylab::Plugin::TestSupport

  module BC_Namespace  # <-

  TS_.describe "[pl] baseless collection" do

    TS_[ self ]
    use :memoizers
    use :baseless_collection

    context "normative - three dependencies" do

      it "builds" do
        _state.collection or fail
      end

      it "each plugin knows its name" do

        _sym_a = _state.collection.to_stream.map_by do | da |
          da.plugin_symbol
        end.to_a

        _sym_a.should eql %i( one two three_yay )
      end

      it "`break`ing out of an `accept` block works" do

        sym_a = []
        _state.collection.accept do | pu |
          sym = pu.plugin_symbol
          if :two == sym
            break
          end
          sym_a.push sym
        end

        sym_a.should eql [ :one ]
      end

      it "`next`ing from within an accept block works" do

        sym_a = []
        _state.collection.accept do | pu |
          sym = pu.plugin_symbol
          if :two == sym
            next
          end
          sym_a.push sym
        end

        sym_a.should eql %i( one three_yay )
      end

      it "`redo`ing from within an accept block works" do

        countdown = 2
        sym_a = []
        _state.collection.accept do | pu |
          sym = pu.plugin_symbol
          sym_a.push sym
          if :two == sym && ( countdown -= 1 ).nonzero?
            redo
          end
        end

        sym_a.should eql %i( one two two three_yay )
      end

      shared_subject :_state do

        sta = shared_state_.new

        svx = self.CLI_services_spy_.new do_debug, debug_IO
        sta.services = svx

        o = _subject.new
        o.eventpoint_graph = :_epg_
        o.modality_const = :CLI
        o.plugin_services = svx
        o.plugin_tree_seed = _plugins_module

        sta.collection = o.load_all_plugins && o
        sta
      end

      memoize :_plugins_module do

        module BC_Plugins_One
          class One < Common_Plugin_Base

          end
          class Two < Common_Plugin_Base

          end
          class Three_Yay < Common_Plugin_Base

          end
          self
        end
      end
    end

    def _subject
      Home_::BaselessCollection
    end
  end
# ->
  end
end
