module Skylab::DocTest

  class Models_::Context  # #[#025] common paraphernalia

    # this rewritten handling of context is experimental. it cannot be
    # considered to have "gelled" until [#001] synchronizing is in.

    class << self

      alias_method :via_valid_pair_array_and_choices__, :new
      undef_method :new
    end  # >>

    def initialize pair_a, cx
      @_choices = cx
      @_pairs = pair_a
    end

    def to_line_stream
      @_choices.particular_paraphernalia_for( self ).to_line_stream
    end

    def to_common_paraphernalia_stream

      Common_::Stream.via_nonsparse_array( @_pairs ).map_by do |pair|  # like #spot-4

        code_run = pair.value_x
        discu_run = pair.name_x

        if code_run.has_magic_copula
          Models_::ExampleNode.via_runs_and_choices_ discu_run, code_run, @_choices
        else
          Models_::UnassertiveCodeNode.via_runs_and_choices_ discu_run, code_run, @_choices
        end
      end
    end

    def paraphernalia_category_symbol
      :context_node  # eew/meh
    end
  end
end
