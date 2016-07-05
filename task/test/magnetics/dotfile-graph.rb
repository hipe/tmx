module Skylab::Task::TestSupport

  module Magnetics::Dotfile_Graph

    def self.[] tcc
      tcc.include self
    end

    # -

      def dotfile_graph_reflection_via_ * s_s_a

        _tss = token_stream_stream_via_ s_s_a
        _itc = item_ticket_collection_via_item_resolver_and_token_stream_stream_ nil, _tss
        o = magnetics_module_
        _fi = o::FunctionIndex_via_ItemTicketCollection[ _itc ]
        _dfg = o::DotfileGraph_via_FunctionIndex[ _fi ]
        DotfileGraph_Reflection___.new _dfg
      end

    # -

    # ==

    class DotfileGraph_Reflection___

      def initialize st

        buff = ""
        begin
          line = st.gets
          line || break
          buff << line
          redo
        end while nil
        @ONE_BIG_STRING = buff
      end

      attr_reader(
        :ONE_BIG_STRING,  # (see note where this is read)
      )
    end
  end
end
