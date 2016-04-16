module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_43_Complexica

      module CLI

        module NonInteractive

          module CustomEffecters

            module Wittgenshtein

              class Topeka

                # this is an exemplar of a custom effecter

                class << self
                  def [] x, cli
                    new( x, cli ).execute
                  end
                end

                def initialize x, cli
                  @CLI = cli ; @x = x
                end

                def execute

                  @CLI.maybe_upgrade_exitstatus @x.d

                  @x.s_a.each do |s|
                    @CLI.sout.puts s
                  end

                  Home_::UNRELIABLE_
                end
              end
            end
          end
        end
      end
    end
  end
end
