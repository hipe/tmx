module Skylab::Snag

  class Models::Tag

    class Collection__

      class Controller__

        def initialize collection, delegate
          @collection = collection ; @delegate = delegate
        end

        def using_iambic_stream_add_tag st, stem_i
          self.class::Add__.new( @collection, @delegate ).
            using_iambic_stream_add_symbol st, stem_i
        end

        def using_iambic_stream_remove_tag st, stem_i
          self.class::Rm__.new( @collection, @delegate ).
            using_iambic_stream_remove_symbol st, stem_i
        end

        def set_body_s s
          @collection.set_body_s s ; nil
        end

        class Edit___

          include Callback_::Actor.methodic_lib.iambic_processing_instance_methods

          def initialize coll, lstn
            @collection = coll ; @delegate = lstn
          end

        private

          def build_tag stem_i
            tag = Tag_.controller @delegate
            tag.stem_i = stem_i
            tag
          end

          def find_existing_tag tag
            @collection.find_any_existing_tag_via_tag tag
          end

          def identifier
            @collection.identifier
          end

          def get_body_s
            @collection.get_body_s
          end

          def set_body_s s
            @delegate.receive_change_body_string s ; nil
          end

          def merge_delegate x
            @delegate.merge_in_other_listener_intersect x
            KEEP_PARSING_
          end
        end
      end
    end
  end
end
