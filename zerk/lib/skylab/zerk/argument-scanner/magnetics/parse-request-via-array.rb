module Skylab::Zerk

  module ArgumentScanner

    class Magnetics::ParseRequest_via_Array < Common_::Monadic

      # experiment.

      # two things in one, one lowlevel and one highlevel

      # -
        def initialize x_a
          @option_array = x_a
        end

        def execute
          if __has_options
            __process_options
          end
          freeze
        end

        def __has_options
          x_a = remove_instance_variable :@option_array
          if x_a.length.zero?
            @successful_result_will_be_wrapped = true
            false
          else
            @_scn = Common_::Scanner.via_array x_a
            @successful_result_will_be_wrapped = false
            true
          end
        end

        # (don't cycle - no safeguard against it. n18n must stop somewhere)

        OPTIONS___ = {
          must_be: [ :__at_must_be ],
          must_be_integer: [ :must_be_trueish, :__must_be_int ],
          must_be_integer_that_is_non_negative: [ :must_be_integer, :__non_neg ],
          must_be_integer_that_is_positive_nonzero: [ :must_be_integer, :__posi_non ],
          must_be_trueish: [ :__must_be_trueish ],
          use_method: [ :__takes_one_argument ],
        }

        def __process_options

          @_options = OPTIONS___
          @_seen = {}

          begin
            _recurse @_scn.head_as_is
            @_scn.advance_one  # :#here-1
          end until @_scn.no_unparsed_exists

          remove_instance_variable :@_options
          remove_instance_variable :@_seen
          remove_instance_variable :@_scn
          NIL
        end

        def _recurse sym
          a = @_options.fetch sym
          len = a.length
          if 1 < len
            ( 0 .. len - 2 ).each do |d|
              _recurse a[ d ]
            end
          end
          @_current_meta_primary = sym
          if @_seen[ sym ]
            raise ::ArgumentError, __say
          end
          @_seen[ sym ] = true
          send a.last
          NIL
        end

        def __say
          "`#{ @_current_meta_primary }` is already implied by a meta-primary that came before it"
        end

        #==((

        def __posi_non
          _auto Must_be_positive_nonzero___
        end

        def __non_neg
          _auto Must_be_non_negative___
        end

        def __must_be_int
          _auto Must_be_integer___
        end

        def __must_be_trueish
          _auto Must_be_trueish___
        end

        #==))

        def __at_must_be
          @_scn.advance_one
          _push @_scn.head_as_is  # counterintuitively, leave it on scn b.c #here-1
        end

        def _auto p
          meta_primary_sym = @_current_meta_primary
          _p = -> x, o do
            o.receive_current_meta_primary_symbol__ meta_primary_sym
            p[ x, o ]
          end
          _push _p
        end

        def _push p
          ( @normalization_chain ||= [] ).push p
          NIL
        end

        def __takes_one_argument
          instance_variable_set :"@#{ @_scn.gets_one }", @_scn.gets_one
        end

        attr_reader(
          :normalization_chain,
          :successful_result_will_be_wrapped,
          :use_method,
        )
      # -

      # ==

      # type-specific normalization is perhaps outside of our central
      # scope, but parsing integers is too common a requirement for us
      # not to bundle something out-of-the-box for them.
      #
      # parsing integers from input is a decidedly modality-specific
      # responsibility: a CLI must always parse integers from strings
      # whereas an API must never. but after that initial "coarse pass",
      # we want common, higher-level normalizations to be available
      # across the modalities "for free" with a consistent interface.
      #
      # so here's where it gets experimental: with this singular result
      # we get from the modality adapter, we apply this NASTY but
      # too-easy-not-use semantic categorization.
      #
      #     if result is false-ish,
      #       if result is false,
      #         we assume the modality adapter emitted something,
      #         so we will not.
      #       otherwise (and result is nil),
      #         we must emit something.
      #     otherwise (and result is trueish)
      #       we assume it is an integer and apply our range validations.
      #
      # (this extremely local "microconvention" is :[#007.E].)
      #
      # the adapter might or might not be using [ba] number to parse the
      # number; we don't care. we ourselves do not use [ba] number for the
      # range validation only because it's too easy to bother.

      auto_express = nil

      Must_be_positive_nonzero___ = -> num, o do
        if 0 < num
          num
        else
          auto_express[ num, o ]
        end
      end

      Must_be_non_negative___ = -> num, o do
        if 0 <= num
          num
        else
          auto_express[ num, o ]
        end
      end

      Must_be_integer___ = -> x, o do

        # exactly [#007.D] (described above)

        d = o.argument_scanner.match_integer_
        if d
          d
        elsif d.nil?
          auto_express[ x, o ]
        else
          UNABLE_
        end
      end

      Must_be_trueish___ = -> x, o do
        if x
          x
        else
          auto_express[ x, o ]
        end
      end

      # ==

      auto_express = -> x, o do

        # "must be trueish" / :not_trueish
        # "must be integer" / :not_integer
        # "must be non negative" / :not_non_negative
        # "must be positive nonzero" / :not_positive_nonzero

        md = /\A
          must_be_ (?<longer>
            (?: (?!_that_is_). )+ (?: _that_is_ (?<shorter> .+ ) | .+)
          )
        \z/x.match o.current_meta_primary_symbol__

        slug = md[ :shorter ] || md[ :longer ]
        human = slug.gsub UNDERSCORE_, SPACE_

        ick = Basic_[]::String.via_mixed x
          # (or `say_strange_branch_item` from the expag if desired)

        _reason_sym = :"not_#{ slug }"

        o.primary_parse_error _reason_sym do |y|
          s = o.subject_moniker
          if s
            y << "#{ s } must be #{ human } (had #{ ick })."
          else
            y << "must be #{ human }: #{ ick }"
          end
        end

        UNABLE_
      end

      # ==
    end
  end
end
# #history: broke out of core magnetics file
