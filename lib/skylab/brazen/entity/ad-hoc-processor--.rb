module Skylab::Brazen

  module Entity

    class Ad_Hoc_Processor__

      def initialize scan, reader, writer
        @name_i = scan.gets_one
        @p = scan.gets_one
        produce_kernel( reader, writer ).add self
        freeze
      end
      attr_reader :name_i
    private
      def produce_kernel reader, writer
        reader.module_exec do
          if const_defined? I
            if const_defined? I, false
              const_get I, false
            else
              const_set I, const_get( I, false ).dup
            end
          else
            const_set I, Kernel__.new( reader, writer )
          end
        end
      end
      I = :AD_HOC_PROCESSORS__
    public

      def scan_any scan
        @p[ scan ]
      end

      class Kernel__

        def initialize reader, writer
          @box = Box_.new
          @reader = reader ; @writer = writer
        end

        attr_reader :box

        def add processor
          meth_i = :"lookup_#{ processor.name_i }_ad_hoc_processor"
          @box.add processor.name_i, meth_i
          @writer.send :define_method, meth_i do processor end
          nil
        end

        def build_scan scan, reader, writer
          Scan__.new scan, reader, writer, self
        end
      end

      class Scan__

        def initialize scanner, reader, writer, kernel
          @kernel = kernel
          @reader = reader
          @scanner = scanner
          @writer = writer
          freeze
        end

        attr_reader :kernel, :reader, :scanner, :writer

     # ~ public API methods for parent machinery

        def scan_any
          meth_i = @kernel.box[ @scanner.current_token ]
          if meth_i
            d = @scanner.current_index
            processor = @reader.send meth_i
            processor.scan_any self
            d != @scanner.current_index
          end
        end

      # ~ public API methods for ad hoc processers

        def advance_one
          @scanner.advance_one
        end

        def current_token
          @scanner.current_token
        end

        def gets_one
          @scanner.gets_one
        end
      end
    end
  end
end
