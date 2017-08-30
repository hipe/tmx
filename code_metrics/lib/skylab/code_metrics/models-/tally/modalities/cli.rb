module Skylab::CodeMetrics

  class Models_::Tally

    class Modalities::CLI < Brazen_::CLI::Action_Adapter

      # the below method definitions with [#bs-028] "public API"-looking
      # names (i.e almost all of them) are overriding methods (and default
      # behavior) defined in the parent class.

      def description_proc_for_summary_of_under__ bound, exp

        # #[#br-002.1] finally here is the end of the line for this.
        # (we want to move this up or do away with the optimization..)
        # this is necessary because we are surprisingly uncommon in our
        # behavior of rendering properties in the first 2 lines of desc.

        prepare_for_employment_under exp.reflection  # makes a bold assumption about state

        expag = expression_agent  # after above

        p = bound.description_proc

        -> y do
          # right here is the context of the parent expag, which we don't want

          expag.calculate y, & p
        end
      end

      # -- implementing the syntax

      # our syntax of the three parts (
      #
      #     [<options>] <word>... -- <path>...
      #
      # ) was trivial to parse when it was only the last two parts: it
      # used to be a matter of simply finding any first stopper ("--")
      # and handling the error cases of no stopper, many stoppers, and
      # when there is a zero count of tokens to the left or right of the
      # stopper both.
      #
      # but adding support for the <options> part can be straightforward:
      # if we "parse off" the <path> part first (using logic along the
      # above lines), we can then use the stdlib option parser to parse
      # the first two parts. to boot this allows for the intermixing of
      # <option> and <word> expressions, something that would be a real
      # eyesore to do by hand here.
      #
      # we will verify the nonzero arity of this <path> term only later
      # at the arg parsing phase for no particular reason..

      def didactic_argument_properties

        # (assume called only once per rendering of help screen)

        a = super
        a = a.dup
        _hi = Brazen_::CLI_Support::Didactic_glyph[ :required, STOPPER__, :_stopper_ ]
        a[ -1, 0 ] = [ _hi ]
        a
      end

      def bound_call_from_parse_options

        # "parse off" the paths part first before we move on to options..

        argv = @resources.argv

        d = argv.rindex STOPPER__
        if d
          @_paths = argv[ d+1 .. -1 ]
          argv[ d .. -1 ] = EMPTY_A_
        else
          # no errors yet. note we are munging the case of "--" and no "--"
          @_paths = EMPTY_A_
        end

        super
      end

      STOPPER__ = '--'

      def init_categorized_properties

        # this won't make any sense without a deep understanding of
        # [#br-002.5] property categorization.

        # categorize our properties differently than what is default. by
        # default, the first of the two "glob" parameters would become an
        # option. but we have our special parsing ..

        o = build_property_categorization

        o.when_many = -> do

          @_paths_property = o.pop_many
          @_words_property = o.pop_many

          # (so it shows up on help screens and usage messages (note order):)

          o.categorize_as_argument @_words_property
          o.categorize_as_argument @_paths_property

          # other formals that take many arguments, always categorize them
          # as options (otherwise the default is try and make them globbing
          # final arguments).

          many = o.release_any_many
          if many
            many.each do | prp |
              o.categorize_as_option prp
            end
          end
          NIL_
        end

        o.make_aesthetic_readjustments = EMPTY_P_
        # do not let options become arguments. our argument slots are full.

        @categorized_properties = o.execute
        NIL_
      end

      def bound_call_from_parse_arguments

        # verify that we have one or more words and one or more paths

        words = @resources.argv.dup
        @resources.argv.clear
        paths = remove_instance_variable :@_paths

        same = -> args, prp do
          if args.length.zero?
            express do
              "need at least one #{ par prp }"
            end
            _failed
          end
        end

        bc = same[ words, @_words_property ]
        bc ||= same[ paths, @_paths_property ]
        if bc
          bc
        else
          @mutable_backbound_iambic.push :word, words
          @mutable_backbound_iambic.push :path, paths
          NIL_
        end
      end

      def _failed
        express_invite_to_general_help
        Common_::BoundCall.via_value Brazen_::CLI_Support::GENERIC_ERROR_EXITSTATUS
      end
    end
  end
end
