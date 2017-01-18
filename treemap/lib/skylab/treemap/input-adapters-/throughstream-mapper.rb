module Skylab::Treemap

  Input_Adapters_::Throughstream_Mapper = -> thru_IO, up_IO do

    # given an upstream and a "through" stream, produce a stream this is
    # indiscernible from the upstream but with this side-effect: with each
    # unit of input pulled from this stream (that is, in effect from the
    # upstream) "multiplex" (echo) that unit to the through stream as well
    # as delivering it to the downstream.

    Common_::MinimalStream.by do
      line = up_IO.gets
      if line
        thru_IO << line
      end
      line
    end
  end
end
