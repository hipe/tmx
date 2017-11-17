module Skylab::TanMan

  module Models_::Starter

    class Actions::Ls

      # this became the frontier case for trying to unify similar work
      # as an "feature branch", and using [#br-085] the reconceived
      # "item via feature branch".
      #
      # NOTE we have yet to go back and sponge up whatever similar redundant
      # code this is replacing.
      #
      # or main interest in such an effort is to
      #
      #   - succesfully implement the collection of starters as an
      #     feature branch.
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

          _fb = _dangerously_memoized_feature_branch
          _st = _fb.to_loadable_reference_stream
          _st  # hi.
        end

        -> do
          yes = true ; x = nil
          define_method :_dangerously_memoized_feature_branch do
            if yes
              yes = false
              x = __build_feature_branch
              x
            else
              x  # (#cov2.2 (all the tests in the file) will hit this)
            end
          end
        end.call

        def __build_feature_branch

          _path = __startingpoint_path
          _fs = _invocation_resources_.filesystem

          Home_.lib_.system_lib::Filesystem::
          Directory::FeatureBranch_via_Directory.define do |o|

            o.loadable_reference_via_path_by = -> path do
              CacheableDereferencableItem__.new path  # hi.
            end

            o.startingpoint_path = _path

            o.item_lemma_symbol = :starter

            o.filesystem_for_globbing = _fs
          end
        end

        def __startingpoint_path  # was `path_for_directory_as_collection_`

          _head = Home_.sidesystem_path_  # (you don't often see us using this)

          ::File.join _head, 'data-documents', 'starters'
        end
      # -

      class << self
        def lookup_starter_by_ & p
          LookupStarter___.call_by( & p )
        end
      end  # >>

      class LookupStarter___ < Common_::MagneticBySimpleModel

        def initialize
          @primary_channel_symbol = nil
          super
        end

        attr_writer(
          :listener,
          :microservice_invocation,
          :primary_channel_symbol,
          :starter_tail,
        )

        def execute

          needle_item = CacheableDereferencableItem__.new @starter_tail

          _op = Here_.new do @microservice_invocation end

          _fb = _op._dangerously_memoized_feature_branch

          item = _fb.procure_by do |o|

            o.needle_item = needle_item

            o.will_be_fuzzy

            o.primary_channel_symbol = @primary_channel_symbol

            o.listener = @listener
          end

          if item
            DidFind___.new item
          else
            DidNotFind___.new needle_item
          end
        end
      end

      DidNotFind___ = ::Struct.new :needle_item do
        def did_find
          FALSE
        end
      end

      DidFind___ = ::Struct.new :found_item do
        def did_find
          TRUE
        end
      end

      # ==

      class CacheableDereferencableItem__

        # (to compat with the feature branch

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

      Actions = nil
      Here_ = self

      # ==
      # ==
    end
  end
end
# #history: broke out of model file years after, full rewrite to use o.b
