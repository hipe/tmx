module Skylab::TanMan

  module Models_::Starter

    class Actions::Ls

      # this became the frontier case for trying to unify similar work
      # as an "operator branch", and using [#br-085] the reconceived
      # "item via operator branch".
      #
      # NOTE we have yet to go back and sponge up whatever similar redundant
      # code this is replacing.
      #
      # or main interest in such an effort is to
      #
      #   - succesfully implement the collection of starters as an
      #     operator branch.
      #
      #   - reuse this same collection as much as is reasonably possible
      #     across all of the silo's actions.
      #
      # as for the second point, currently we accomplish this through
      # a "dangerous memoization", that is, arbitrary details of invocation
      # state are placed into a true memoization; but this should be OK
      # as long as we don't mock the filesystem (or want to allow starters
      # to get added/removed to the starters directory during runtime),
      # both of which are the case currently.

      # -

        def initialize
          extend Home_::Model_::CommonActionMethods
          init_action_ yield
        end

        def execute

          _ob = dangerously_memoized_operator_branch_FOR_SILO_ONLY_
          _st = _ob.to_loadable_reference_stream
          _st  # hi.
        end

        -> do
          yes = true ; x = nil
          define_method :dangerously_memoized_operator_branch_FOR_SILO_ONLY_ do
            if yes
              yes = false
              x = __build_operator_branch
              x
            else
              x  # (#cov2.2 (all the tests in the file) will hit this)
            end
          end
        end.call

        def __build_operator_branch

          _path = __startingpoint_path
          _fs = _invocation_resources_.filesystem

          Home_.lib_.system_lib::Filesystem::
          Directory::OperatorBranch_via_Directory.define do |o|

            o.startingpoint_path = _path

            o.filesystem_for_globbing = _fs

            o.loadable_reference_via_path_by = -> path do
              CacheableDereferencableItem_FOR_SILO_ONLY.new path  # hi.
            end
          end
        end

        def __startingpoint_path  # was `path_for_directory_as_collection_`

          _head = Home_.sidesystem_path_  # (you don't often see us using this)

          ::File.join _head, 'data-documents', 'starters'
        end
      # -

      # ==

      class CacheableDereferencableItem_FOR_SILO_ONLY

        # (to compat with the operator branch

        def initialize path

          bn = ::File.basename path
          d = ::File.extname( bn ).length
          stem = d.zero? ? bn : bn[ 0 ... -d ]
          @normal_symbol = stem.gsub( DASH_, UNDERSCORE_ ).intern  # or whatever

          @natural_key_string = bn.freeze
          @path = path
          freeze
        end

        def intern
          # for [#fi-037.5.O] (in [br]!) emitter performer
          @normal_symbol
        end

        attr_reader(
          :natural_key_string,  # throwback to [br]
          :normal_symbol,
          :path,
        )
      end

      # ==
      # ==
    end
  end
end
# #history: broke out of model file years after, full rewrite to use o.b
