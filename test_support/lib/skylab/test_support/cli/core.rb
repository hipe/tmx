module Skylab::TestSupport

  module CLI

    class << self

      def new i, o, e, pn_a
        CLI::Test_Support_Client___.new i, o, e, pn_a
      end

      def visual_client
        CLI::Visual_Client___
      end

      def const_missing sym
        m = :"__#{ sym }__"
        if respond_to? m
          send m
        else
          super
        end
      end

      def __Client__
        CLI::Test_Support_Client___::Client
      end
    end  # >>
  end
end
# #tombstone: 2 CLI-related near-toplevel files with long history
