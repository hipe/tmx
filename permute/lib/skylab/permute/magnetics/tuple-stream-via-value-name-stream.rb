module Skylab::Permute

  Magnetics = ::Module.new

  module Magnetics::TupleStream_via_ValueNameStream ; class << self

    # this is the core function behind our core operation.
    # recursively it makes streams out of the categories and their values.
    # whenever it is on the non-last category ("column", if you like), it
    # expands the current stream

    def call pair_st

      bx = __box_via_pair_stream pair_st

      if bx.length.zero?
        Common_::Stream.the_empty_stream
      else
        __via_nonempty_box bx
      end
    end

    def __via_nonempty_box bx

      categories = bx.to_pair_stream.to_a ; bx = nil

      struct_class = __struct_class_via_categories categories

      categories_length = categories.length

      last = categories_length - 1

      recurse = -> st, d do

        st_ = st.expand_by do |sct|
          x_a = categories.fetch( d ).value_x  # as #here
          Common_::Stream.via_times x_a.length do |d_|
            o = sct.dup
            o[ d ] = x_a.fetch d_
            o
          end
        end

        if last == d
          st_
        else
          recurse[ st_, d + 1 ]
        end
      end

      x_a = categories.fetch( 0 ).value_x  # as #here
      st = Common_::Stream.via_times x_a.length do |d|
        struct_class.new x_a.fetch d
      end
      if last.zero?
        st
      else
        recurse[ st, 1 ]
      end
    end

    alias_method :[], :call

    # --

    def __struct_class_via_categories cat_a

      sym_a = cat_a.map( & :name_x )

      const = GENERATED_STRUCT_CONSTS__.fetch sym_a do

        _d = GENERATED_STRUCT_CONSTS__.length + 1
        const_ = :"G#{ _d }"
        GeneratedStructs__.const_set const_, ::Struct.new( * sym_a )
        GENERATED_STRUCT_CONSTS__[ sym_a ] = const_
        const_
      end

      GeneratedStructs__.const_get const, false
    end
  end  # >>

    # (define these consts in the module, not its singleton class)

    GeneratedStructs__ = ::Module.new

    GENERATED_STRUCT_CONSTS__ = {}

  class << self

    # --

    def __box_via_pair_stream pair_st

      bx = Common_::Box.new
      begin
        pair = pair_st.gets
        pair || break
        x, k = pair
        bx.touch_array_and_push k, x
        redo
      end while nil
      bx
    end
  end ; end
end
# #tombstone: nima algorithm
