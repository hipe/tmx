module Skylab::TestSupport

  class Slowie

    class Models_::Globber

      # the term "glob" as a noun must only ever refer to the string with a
      # '*' in it. it must not be used to refer to any other related
      # noun-ish (like the resultant list of files, or like a performer that
      # produces such a list). the term "glob" *may* be used as a verb if
      # it's unambiguously referring to the act of producing a list/stream
      # of files from such a glob string.
      #
      # a "globber", then, is a performer that performs such a "glob"
      # operation. an intrinsic part of its (ostensibly immutable) identity
      # is the "glob" string. this "globber" then acts like a proc that
      # takes no arguments - its main method results in a stream of path
      # strings.
      #
      # it can be called multiple times; each time producing such a stream
      # that reflects the the state of the filesystem at that time of the
      # call.
      #
      # :#slowie-spot-1

      class << self
        alias_method :prototype_by, :new
        undef_method :new
      end  # >>

      def initialize

        yield self

        # (the below was `__build_find_test_files_prototype`)

        @__prototype_for_the_find_command = Home_.lib_.system.find.new_with(
          :freeform_query_infix_words, FIND_FILES_ONLY___,
          :filename, @test_file_name_pattern,
          & @listener
        )

        freeze
      end

      attr_writer(
        :listener,
        :test_file_name_pattern,
        :system_conduit,
        :xx_example_globber_option_xx,
      )

      # -- as prototype that produces an instance:

      def globber_via_directory dir
        __dup.__init dir
      end

      alias_method :__dup, :dup
      undef_method :dup

      def __init dir

        _find_proto = remove_instance_variable :@__prototype_for_the_find_command

        @__find_command = _find_proto.new_with :path, dir

        freeze
      end

      def to_path_stream
        @__find_command.path_stream_via @system_conduit
      end
    end

    # ==

    FIND_FILES_ONLY___ = %w(-type f).freeze

    # ==
  end
end
# #history: abstracted from what is at the time the "magnetics" node
