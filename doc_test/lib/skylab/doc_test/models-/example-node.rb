module Skylab::DocTest

  class Models_::ExampleNode

    # implement [#025] "common paraphernalia model"
    # (three laws)

    class << self

      alias_method :via_runs_and_choices_, :new
      undef_method :new
    end  # >>

    def initialize discussion_run, code_run, choices
      @_choices = choices
      @_code_run = code_run
      @_discussion_run = discussion_run
    end

    def to_line_stream
      to_particular_paraphernalia.to_line_stream
    end

    def to_particular_paraphernalia_under x
      @_choices.particular_paraphernalia_for_under self, x
    end

    def to_particular_paraphernalia
      @_choices.particular_paraphernalia_for self
    end

    def begin_description_string_session
      Models_::Description_String.via_discussion_run__ @_discussion_run, @_choices
    end

    def to_code_run_line_object_stream
      @_code_run.to_line_object_stream
    end

    def paraphernalia_category_symbol
      :example_node
    end

    def is_assertive  # (is same as "is example")
      true
    end
  end
end
# #tombstone (possibly temporary) - used Description_String
