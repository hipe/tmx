module Skylab::Headless

  module CLI::Option__

    module Parser__

      class Scanner__ < Callback_.scan.immutable_with_random_access  # :+[#053]

        # a custom scanner class (has random access with caching) made just
        # for option parsers, specifically for querying for a specific option
        # based on its normalized name (e.g 'dry_run') and resulting in an
        # abstract option ("model") object that can reflect on meta-info about
        # the object; like whether it takes arguments, what its shortname is,
        # etc.

        class << self

          def [] op_x
            _scan = Option_.scan op_x
            _scan_ = _scan.map_by do |sw|
              Option_.build_via_switch sw
            end
            build_with :scn, _scan_, :key_method_name, :normalized_parameter_name
          end

          def weak_identifier_for_switch sw
            Weak_identifier_for_switch__[ sw ]
          end
        end

        def fetch query_x, & p
          if query_x.respond_to? :id2name
            super query_x, & p
          else
            raise ::TypeError, say_not_symbol( query_x )  # or build back in
          end
        end

        def say_not_symbol x
          "no implicit convertion of #{ Headless_.lib_.strange x } to symbol"
        end

        Weak_identifier_for_switch__ = -> do

          long_rx, short_rx = CLI.option.values_at :long_rx, :short_rx

          -> sw, else_p=nil do
            stem = if sw.long.length.nonzero?
              md = long_rx.match sw.long.first
              md && "--#{ md[ :long_stem ] }"
            else
              md = short_rx.match sw.short.first
              md && "-#{ md[ :short_stem ] }"
            end
            if stem
              stem
            elsif else_p
              else_p[]
            else
              raise ::RuntimeError, "can't infer weak identifier from switch"
            end
          end
        end.call
      end
    end
  end
end
