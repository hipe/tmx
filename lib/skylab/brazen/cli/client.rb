module Skylab::Brazen

  class CLI

    # ~ #comport:face this whole file. (just to fit in 'tmx')

    module Client
      module Adapter
        module For
          module Face
            module Of
              class Hot
                def self.[] kernel, token
                  Adapter___.make_adapter kernel, token
                end

                class Maker
                  def initialize mod
                    @mod = mod
                  end

                  def make_adapter kernel, token
                    Adapter__.new @mod, kernel, token
                  end
                end

                class Adapter__

                  def initialize *a
                    @mod, @given_NS_sheet, @parent_top_client = a
                  end

                  def call * a
                    @parent_top_client_kernel, @given_slug = a
                    self
                  end

                  def get_summary_a_from_sheet sht
                  end

                  def get_autonomous_quad argv
                    s_a = @parent_top_client_kernel.
                      get_normal_invocation_string_parts
                    [ @mod::CLI.new( *
                        @parent_top_client_kernel.three_streams, s_a ),
                      :invoke,
                      [ argv ],
                      nil ]
                  end

                  def is_autonomous
                    true
                  end

                  def is_visible
                    true
                  end

                  def name
                    @given_NS_sheet.name
                  end

                  def pre_execute
                    self
                  end
                end

                Adapter___ = Maker.new Brazen_
              end
            end
          end
        end
      end
    end
  end
end
