module Skylab::Basic

  module ByteStream

    # ## intro
    #
    # this is :[#062] a factory for locating the appropriate "byte stream
    # reference" given mixed input. counterpart factories exist for
    # both "upstream" and "downstream" which we track individually (and
    # perhaps uselessly) with :[#here.1] and :[#here.2], respectively.
    #
    # when we say "byte stream" it is our fancy way of saying "an open
    # filehandle" (or something similar).
    #
    # note that there are no actual implementations here. this node is
    # purely a factory that delegates all calls to other nodes.
    #
    #
    #
    # ## purpose
    #
    # byte stream references are our answer to the problem of how to work
    # with byte streams in an abstract way when we want to be able to adapt
    # to a variety of storage "substrates" "for free" without having to know
    # exactly what the substrate is.
    #
    # it's exactly like how an IO handle can be read from/written to
    # indifferently whether it's in front of an open file on the filesystem,
    # or maybe a pipe, or maybe a network socket or perhaps something else.
    # this common inferface adapted to a variety of input/output/storage
    # "substrates" allow the software to talk to a larger variety of things
    # while playing dumb as to what the things are (to the extent that the
    # abstraction isn't leaky, which it certainly can be).
    #
    # we extend this approach further (and narrower, probably) to work with
    # the kinds of "byte streams" that are useful to us; namely: when testing
    # it is often useful to write lines to an in-memory array (or maybe one
    # big string) instead of to a file.
    #
    # but it's just as possible that we would want to use this approach for
    # swapping in an in-memory database in place of a filesystem, or whatever
    # other weird experiments..

    Byte_downstream_reference_via_mixed = -> x do

      # (this is similar to a counterpart of [#co-056.1] try-convert's for streams)

      if x.respond_to? :push

        DownstreamReference.via_line_array x

      elsif x.respond_to? :puts

        DownstreamReference.via_open_IO x

      elsif x.respond_to? :ascii_only?

        DownstreamReference.via_string x

      elsif x.respond_to? :yield

        DownstreamReference.via_yielder x
      end
    end

    # ==

    module DownstreamReference

      class << self

        def via_path s
          Home_.lib_.system_lib::Filesystem::ByteDownstreamReference.new s
        end

        def via_open_IO io
          Home_.lib_.IO_lib::ByteDownstreamReference.via_open_IO io
        end

        def via_line_array s_a
          Home_::List::ByteDownstreamReference.new s_a
        end

        def via_string s
          Home_::String::ByteDownstreamReference.new s
        end

        def via_qualified_knownnesses qualified_knownness_a
          o = BoundCall_via_Shape__[ qualified_knownness_a ]
          o and send o.method_name, * o.args
        end

        def via_yielder yld
          Home_::Yielder::ByteDownstreamReference.new yld
        end
      end  # >>
    end

    # ==

    module UpstreamReference

      class << self

        def via_path s
          Home_.lib_.system_lib::Filesystem::ByteUpstreamReference.new s
        end

        def via_open_IO io
          Home_.lib_.system_lib::IO::ByteUpstreamReference.via_open_IO io
        end

        def via_line_array s_a
          Home_::List::ByteUpstreamReference.new s_a
        end

        def via_string s
          Home_::String::ByteUpstreamReference.new s
        end

        def via_qualified_knownnesses qkn_a
          o = BoundCall_via_Shape__[ qkn_a ]
          o and send o.method_name, * o.args
        end
      end  # >>
    end

    # ==

    class BoundCall_via_Shape__ < Common_::Monadic

      def initialize qkn_a
        @qualified_knownness = qkn_a.fetch 0
      end

      def execute
        @mixed_value = @qualified_knownness.value_x
        send DIRECTION_SHAPE_RX___.match( @qualified_knownness.name_symbol )[ :shape ]
      end

      def path

        # #[#br-021] shape magic: it is convenient for lazy smart clients
        # to be able to pass stream-like mixed values in for a path.

        if @mixed_value.respond_to? :ascii_only?

          Common_::BoundCall.via_args_and_method_name @mixed_value, :via_path

        elsif @mixed_value.respond_to? :each_with_index

          Common_::BoundCall.via_args_and_method_name [ @mixed_value ], :via_line_array

        else
          stream
        end
      end

      def stream
        Common_::BoundCall.via_args_and_method_name @mixed_value, :via_stream
      end

      def string
        Common_::BoundCall.via_args_and_method_name @mixed_value, :via_string
      end
    end

    # ==

    DIRECTION_SHAPE_RX___ = /\A(?<direction>.+)_(?<shape> path | stream | string )\z/x

    # ==
  end
end
# #history: extracted from [br]. years of history before now.
