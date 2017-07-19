module Skylab::BeautySalon

  class CrazyTownMagnetics_::FileChanges_via_Path_and_Function_and_Selector < Common_::MagneticBySimpleModel

    # -
      def initialize
        super
      end

      attr_writer(
        :path,
        :code_selector,
        :replacement_function,
        :listener,
      )

      def execute
        FileChanges___.new @path
      end

    # -

    class FileChanges___

      def initialize path
        @path = path
      end

      def to_diff_body_line_stream__

        _big_string = <<-O
          @@ -1,5 +1,5 @@
           module Xx
             def yy
          -    foo.shall resemble :hi
          +    expect( foo ).to resemble :hi
             end
           end
        O
        r = 10..-1
        scn = Home_.lib_.basic::String::LineStream_via_String[ _big_string ]
        Common_.stream do
          line = scn.gets
          if line
            line[ r ]
          end
        end
      end

      attr_reader(
        :path,
      )
    end

    # ==
    # ==
  end
end
# #born.
