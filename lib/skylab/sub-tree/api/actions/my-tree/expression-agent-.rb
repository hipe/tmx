module Skylab::SubTree

  class API::Actions::My_Tree

    class Expression_Agent__

      alias_method :calculate, :instance_exec

    private

      SubTree::Lib_::EN_add_methods[ self, :private, %i( and_ both ) ]

      def par i
        "<#{ Hak_lbl__[ i ] }>"
      end
      Hak_lbl__ = SubTree::Lib_::Hack_label_proc[]

    end

    EXPRESSION_AGENT_ = Expression_Agent__.new
  end
end
