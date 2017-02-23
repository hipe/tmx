module Skylab::Plugin

  class Magnetics::OperatorBranch_via_DirectoryOneDeeper  # :[#012].

    # (look for this reference in [br] - we are making a close cousin)

    # three laws.

    # synopsis - created to clean up what [sy] does with its "services"
    #   local architecture. after the fact, re-housed as an operator
    #   branch due to its behavior similarity to its (name head) sibling..
    #

    # generally this is contrary to our most recent plugin architectures
    # because it assumes not that plugin nodes reside directly under one
    # node, but rather that they reside exactly two levels under the node,
    # and all have the same name. (anciently we did it this way too.)
    #
    # so imagine you have the participating subsystems "some guy" and
    # "some other guy". they must contain a *file* with a certain one
    # filename of your choosing. imagine it is "adapter.kode".
    #
    # so then you should have the plugin-like files:
    #
    #      /foo/bar/some/branch-module/some-guy/adapter.kode
    #      /foo/bar/some/branch-module/some-other-guy/adapter.kode
    #
    # define the plugin collection like this:
    #
    #     col = subject.define do |o|
    #       o.entry = 'adapter.kode'
    #       o.branch_module = Some::BranchModule
    #     end
    #
    # and then discover your participating sidesystems like this:
    #
    #      st = col.to_asset_ticket_stream
    #      plugin = st.gets
    #      plugin.normal_symbol  # => :some_guy
    #      plugin = st.gets
    #      plugin.normal_symbol  # => :some_other_guy
    #
    #  (none of this is a doc-test)

    class << self
      def define & p
        Collection___.define( & p )
      end
    end  # >>

    class Collection___ < SimpleModel_

      def initialize

        @_is_finished_caching = false
        @_load_ticket_box = Common_::Box.new
        @_to_LTS = :__to_asset_ticket_stream_initially

        yield self
        # can't freeze because caches state modes
      end

      attr_writer(
        :branch_module,
        :entry,
        :system,
      )

      def dereference sym
        if @_is_finished_caching
          @_load_ticket_box.fetch sym
        else
          __dereference_when_no_yet_cached sym
        end
      end

      def __dereference_when_no_yet_cached sym
        h = @_load_ticket_box.h_
        x = h[ sym ]
        if ! x
          st = to_asset_ticket_stream
          begin
            x = st.gets
            x.normal_symbol == sym && break
            redo
          end while above
        end
        x
      end

      def to_asset_ticket_stream
        send @_to_LTS
      end

      def __to_asset_ticket_stream_initially  # assumes at least 1 item

        # when there's nothing cached

        # (for now we use the real filesystem to stop the insanity somewhere,
        #  but etc, we could ..)

        _head_path = @branch_module.dir_path

        _glob = ::File.join _head_path, '*', @entry

        _big_file_list = @system.glob _glob

        scn = Common_::Scanner.via_array _big_file_list

        @__long_path_scanner = scn
        @_to_LTS = :__to_asset_ticket_stream_midway

        _to_this_one_stream
      end

      def __to_asset_ticket_stream_midway

        first_st = @_load_ticket_box.to_value_stream
        p = -> do
          x = first_st.gets
          if x
            x
          else
            p = _to_this_one_stream
            p[]
          end
        end
        Common_.stream do
          p[]
        end
      end

      def _to_this_one_stream
        bx = @_load_ticket_box
        scn = @__long_path_scanner
        p = -> do
          _long_path = scn.gets_one
          lt = LoadTicket_via_Path___.new _long_path
          bx.add lt.normal_symbol, lt
          if scn.no_unparsed_exists
            @_to_LTS = :__to_asset_ticket_stream_finally
            remove_instance_variable :@__long_path_scanner
            @_is_finished_caching = true
            freeze
            bx.freeze
            p = EMPTY_P_
          end
          lt
        end
        Common_.stream do
          p[]
        end
      end

      def __to_asset_ticket_stream_finally
        @_load_ticket_box.to_value_stream
      end
    end

    # ==

    class LoadTicket_via_Path___

      def initialize path
        @normal_symbol =
          ::File.basename( ::File.dirname path ).gsub( DASH_, UNDERSCORE_ ).intern
            # (above is faster than regexp per benchmark [#bm-014])
      end

      attr_reader(
        :normal_symbol,
      )
    end

    # ==

    EMPTY_P_ = -> { NOTHING_ }

    # ==
  end
end
# #history: will have been abstracted (spiritually) from [sy] services
