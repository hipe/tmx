require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - effecters" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI

    context "(when a means to express is not found)" do

      shared_subject :_ex do

        begin
          argv 'wittgenshtein', 'nopeka'
        rescue Home_::CLI::CustomEffection_via_Client_and_MixedResult::Find::No => e
        end

        e
      end

      it "throws a particular exception" do
        _ex or fail
      end

      it "message.." do

        etc = '[A-Z][A-Za-z0-9_]+(?:::[A-Z][A-Za-z0-9_]+)+::Class_43_Complexica::'

        _rx = %r(\Aeither implement `express_into_under`#{
         } on #{ etc }Myterio_Effecter#{
          } -OR- put something at uninitialized constant #{ etc }#{
           }CLI::NonInteractive::CustomEffecters::#{
            }Wittgenshtein::\( \~ nopeka \))

        expect( _ex.message ).to match _rx
      end
    end

    context "(ok custom effecters effect)" do

      given do
        argv 'wittgenshtein', 'topeka'
      end

      it "exitstatus is highest value (not last value)" do

        expect( exitstatus ).to eql 7
      end

      it "the effecters outputted" do

        _exp = "shopluka\nboluka\nwopeego\ndiligente\n"
        assemble_big_string_on( :o ) == _exp or fail
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_43_Complexica ]
    end
  end
end
