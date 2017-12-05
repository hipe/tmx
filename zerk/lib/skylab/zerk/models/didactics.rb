module Skylab::Zerk

  class Models::Didactics < SimpleModel_  # explained at [#055]

    class << self

      def define_conventionaly dida, op
        dida.operator = op
        NIL
      end
    end  # >>

    # -

      def initialize
        @below_didactics_by = nil
        @operator = nil
        yield self

        oper = remove_instance_variable :@operator
        if oper

          @__to_item_normal_tuple_stream =
            oper.method :to_item_normal_tuple_stream_for_didactics  # #tombstone #temporary

          description_proc_reader =
            oper.description_proc_reader_for_didactics  # [#here.D] curator can delegate

          is_branchy = oper.is_branchy
        end

        parent_by = remove_instance_variable :@below_didactics_by
        if parent_by
          _parent_dida = parent_by.call
          _k = @name.as_lowercase_with_underscores_symbol
          desc_p = _parent_dida.description_proc_for _k
          # subject description is "curated" IFF parent is known [#here.D]
        else
          desc_p = oper.method :describe_into  # balls
        end

        @description_proc = desc_p
        @description_proc_reader = description_proc_reader
        @is_branchy = is_branchy
      end

      attr_writer(
        :below_didactics_by,
        :name,
        :operator,
      )

      def to_item_normal_tuple_stream
        @__to_item_normal_tuple_stream.call
      end

      attr_reader(
        :is_branchy,
        :description_proc,
        :description_proc_reader,
      )
    # -
  end
end
