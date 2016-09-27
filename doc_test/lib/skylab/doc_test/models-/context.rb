module Skylab::DocTest

  class Models_::Context  # #[#025]

    class << self

      alias_method :via_valid_pair_array_and_choices__, :new
      undef_method :new
    end  # >>

    def initialize pair_a, tfcp, cx
      @_choices = cx
      @_pairs = pair_a
      @__test_file_context_proc = tfcp
    end

    def to_line_stream & p
      to_particular_paraphernalia.to_line_stream( & p )
    end

    def to_particular_paraphernalia
      @_choices.particular_paraphernalia_for self
    end

    def to_stem_paraphernalia_stream

      Stream_[ @_pairs ].map_by do |pair|  # like #spot-4

        code_run = pair.code_run
        discu_run = pair.discussion_run

        if code_run.has_magic_copula
          Models_::ExampleNode.via_runs_and_choices_ discu_run, code_run, @_choices
        else
          Models_::UnassertiveCodeNode.via_runs_and_choices_(
            discu_run, code_run, @__test_file_context_proc, @_choices )
        end
      end
    end

    def paraphernalia_category_symbol
      :context_node  # we're using the solution-specific name as the general name
    end
  end
end
