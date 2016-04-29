module Skylab::MyTerm::TestSupport

  module Stubs::System_Conduit_02_Yay

    class << self

      def produce_new_instance
        @__instance.dup
      end
    end  # >>

    sc = Home_.lib_.system_lib::Doubles::Stubbed_System::Inline_Pool_Based.new

    sc._add_entry_by_ do |cmd_s_a|

      if 'convert' == cmd_s_a.first
        cmd_s_a[ 1 ] == '-font' or fail
        cmd_s_a[ 3 ] == 'label:djibouti' or fail
        -> _, _, _ do
          0
        end
      end
    end

    sc._add_entry_by_ do |cmd_s_a|

      if 'return version' == cmd_s_a[ -3 ]
        -> _, o, _ do
          o << "5.6.789\n"
          0
        end
      end
    end

    sc._add_entry_by_ do |cmd_s_a|

      md = %r(\A[ ]*set background image to "([^"]+)").match cmd_s_a[6]

      if md
        -> _, o, _ do
          o << "script result: apparently set bg image to #{ md[1] }\n"
          0
        end
      end
    end

    @__instance = sc
  end
end
