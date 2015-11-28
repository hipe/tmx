module Skylab::TanMan::TestSupport

  module Models::Meaning::Graph

    def self.[] tcc
      tcc.send :define_method, :graph_from, Graph_from_method___
    end

      Graph_from_method___ = -> * s_pair_a do

        _st = Home_::Callback_::Stream.via_nonsparse_array s_pair_a do | s, s_ |
          Home_::Models_::Meaning.new s, s_
        end

        Home_::Models_::Meaning::Graph__.new _st
      end
  end
end
