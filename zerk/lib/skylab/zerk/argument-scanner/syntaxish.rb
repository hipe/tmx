module Skylab::Zerk

  module ArgumentScanner

    class Syntaxish  # :[#056]

      # one level of abstraction higher than an feature branch, exposes
      # and bundles together methods for techniques commonly associated
      # with feature branches.
      #
      # meant to help DRY up a fleet of operations thru composition not
      # inheritance - the operations init a member variable with the
      # subject and delegate to it those common implementation choices.
      #
      # be able to dup-and-mutate, maybe.
      #
      # this was originally called "hash-based syntax" then "syntax choices".
      # for now we are keeping its current horrible name to make it explicit
      # that this both has proximity to and is distinct from any concrete
      # conception of "syntax", which itself doesn't make clear at first
      # glance whether it should or shouldn't be expected to parse anything,
      # and whether or not it is tied to any single modality. with this
      # strange name, we reserve ourself some space for these choices.
      #
      # #a.s-coverpoint-2

      class << self
        alias_method :via_feature_branch, :new
        undef_method :new
      end  # >>

      # -

        def initialize ob
          @feature_branch = ob
        end

        def parse_all_into_from operation, argument_scanner
          Parse___.new(
            operation,
            argument_scanner,
            NOTHING_,  # coming soon
            @feature_branch
          ).execute
        end

        attr_reader(
          :feature_branch,
        )
      # -

      # ==

      class Parse___

        def initialize op, as, _COMING_SOON, ob
          @argument_scanner = as
          @feature_branch = ob
          @operation = op
        end

        def execute
          if @argument_scanner.no_unparsed_exists
            ACHIEVED_
          else
            @__matcher = @argument_scanner.matcher_for(
              :primary, :against_branch, @feature_branch )
            begin
              ok = __parse_primary
              ok || break
            end until @argument_scanner.no_unparsed_exists
            ok
          end
        end

        def __parse_primary
          item = @__matcher.gets
          if item
            if item.is_the_no_op_branch_item
              ACHIEVED_
            else
              @operation.at_from_syntaxish item
            end
          else
            item
          end
        end
      end

      # ==
    end
  end
end
# #history: moved to [ze] from slowie
# #history: abstracted from two operations
