module Skylab::TanMan

  class Kernel__

    class Properties

      module Models__

        class Stack < Base_

          def initialize top_frame
            @a = [ top_frame ]
            yield self
            @a.reverse!.freeze
            freeze
          end

          def push_frame x
            bad_a = x.names - @a.first.names
            bad_a.length.nonzero? and raise ::ArgumentError,
              TanMan_::Lib_::Entity[].say_unrecognized_properties( bad_a )
            @a.push x ; nil
          end

          def retrieve_value i
            scn = get_frame_scanner
            while frame_ = scn.gets
              found = frame_.any_retriever_for i
              found and break
            end
            found or raise ::NameError, "no member '#{ i }'"
            found.retrieve_value i
          end

        private

          def get_frame_scanner
            Scan_[].nonsparse_array @a
          end
        end

        class Hash_Adapter < Base_

          def initialize h
            @h = h ; @memo_h = {}
            freeze
          end

          def names
            @h.keys
          end

          def any_retriever_for i
            if @h.key? i
              self
            end
          end

          def retrieve_value i
            @memo_h.fetch i do
              @memo_h[ i ] = @h.fetch( i )[]
            end
          end
        end
      end
    end
  end
end
