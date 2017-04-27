module Skylab::Basic

  module ByteStream

    # ## intro
    #
    # this is :[#062] a factory for locating the appropriate "byte stream
    # reference" given mixed input. there are no implementations in the
    # subject node, which is purely a factory that delegates all calls to
    # other nodes.
    #
    # this is also :[#here.3] the smatterings of what we might call
    # "the byte stream manifesto".
    #
    # when we say "byte stream" it is our fancy way of saying "an open
    # filehandle", or something that could give rise to an open filehandle
    # or something similar. [#tm-026.1] explains and justifies this and
    # other related terminology further.
    #
    # counterpart factories exist for both "upstream" and "downstream" which
    # we track individually (and perhaps uselessly) with :[#here.1] and
    # :[#here.2], respectively. NOTE there is now some movement to allow
    # "upstream" and "downstream" behavior to coexist in the same instance,
    # as we are seeing at [#sy-010] IO; but this idea is only just starting
    # to gel as we write this.


    # ## "philosophy" & purpose
    #
    # byte stream references are our answer to the problem of how to work
    # with byte streams in an abstract way when we want to be able to adapt
    # to a variety of storage "substrates" "for free" without having to know
    # exactly what the substrate is.
    #
    # a similar idea is that of the platform's `StringIO`, which "quacks"
    # like an IO but internally is a string.
    #
    # it's also exactly like how an IO handle can be read from/written to
    # indifferently whether it's in front of an open file on the filesystem,
    # or maybe a pipe, or maybe a network socket or perhaps something else.
    #
    # adapting this common inferface to a variety of input/output/storage
    # "substrates" allows the software to read data from and write data to
    # a large variety of "endpoints" "for free" while playing dumb as to
    # what the internal shape or nature of those endpoints is (to the extent
    # that the abstraction isn't leaky, which it certainly can be).


    # ## why not just use IO's?
    #
    # if the IO abstraction (a ubiquitous standard) is so similar, why not
    # just use actual IO's? first, two small reasons:
    #
    #   - we want our references to be able to have an arbitrary API
    #     we design for simple reflection (currently `describe_into_under`)
    #     so that our references can express themselves in UI emissions in
    #     ways we control. (we never monkeypatch, as an almost absolute rule.)
    #
    #   - our core interface is so minimal that we can adapt it trivially
    #     to arrays, for which there is no built-in adaptations for IO
    #     (nor should there be).
    #
    # but there's also a more fundamental reason: the idea of a "reference"
    # (what we used to call "identifier" here and "load ticket" generally)
    # is that it's not the thing itself, but a reference to the thing..
    # this allows participants uninvolved directly in the actual reading
    # and/or writing to pass around references without (for example) having
    # to hold an open handle to a resource they are not using, or worry what
    # to do if for example the referent to a path is not found.

    # ## application
    #
    # we extend this approach further (and narrower, probably) to work with
    # the kinds of "byte streams" that are useful to us; namely: when testing
    # it is often useful to write lines to an in-memory array (or maybe one
    # big string) instead of to a file.
    #
    # but it's just as possible that we would want to use this approach for
    # swapping in an in-memory database in place of a filesystem, or whatever
    # other weird experiments..


    # ## interface
    #
    # we try to avoid leaks in the abstractions by limiting our "ideal
    # minimal" interface to a minimal set of official exposures (methods).
    # although on the periphery there is much experimentation to expand
    # the allowable interaction idioms; the core operations are:
    #
    #   - reading, for which the byte stream reference must produce some
    #     mixed object to be used as a "minimal line reader", which is an
    #     object whose only known method is `gets` (which gets each next
    #     line until it produces falseish, meaning the end was reached).
    #     note there is no rewinding, and there is no (to read all bytes
    #     at once) `read`.
    #
    #     (this method name is `minimal_line_stream`.)
    #
    #   - writing, for which the byte stream reference must produce a
    #     "minimal line yielder for receiving lines", which is a mouthful
    #     of a way of saying an object that can be sent `<<` to receive
    #     each next *line* of output. (this method name was chosen because
    #     you can implement such an object trivially with a string, array,
    #     or IO handle all of which already respond to this method in the
    #     appropriate way (assuming your lines are terminated).)
    #
    #     (the method name is `to_minimal_yielder_for_receiving_lines`.)

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
          Home_.lib_.system_lib::Filesystem::ByteDownstreamReference.via_path s
        end

        def via_open_IO io
          Home_.lib_.IO_lib::ByteDownstreamReference.via_open_IO io
        end

        def via_line_array s_a
          Home_::List::ByteDownstreamReference.via_line_array s_a
        end

        def via_string s
          Home_::String::ByteDownstreamReference.via_big_string s
        end

        def via_qualified_knownness qualified_knownness
          o = BoundCall_via_Shape__[ qualified_knownness ]
          o and send o.method_name, * o.args
        end

        def via_yielder yld
          Home_::Yielder::ByteDownstreamReference.via_yielder yld
        end
      end  # >>
    end

    # ==

    module UpstreamReference

      class << self

        def via_path s
          Home_.lib_.system_lib::Filesystem::ByteUpstreamReference.via_path s
        end

        def via_open_IO io
          Home_.lib_.system_lib::IO::ByteUpstreamReference.via_open_IO io
        end

        def via_line_array s_a
          Home_::List::ByteUpstreamReference.via_line_array s_a
        end

        def via_string s
          Home_::String::ByteUpstreamReference.via_big_string s
        end

        def via_qualified_knownness qkn
          o = BoundCall_via_Shape__[ qkn ]
          o and send o.method_name, * o.args
        end
      end  # >>
    end

    # ==

    class BoundCall_via_Shape__ < Common_::Monadic

      def initialize qkn
        @qualified_knownness = qkn
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
