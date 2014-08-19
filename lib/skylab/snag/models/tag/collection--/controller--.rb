module Skylab::Snag

  class Models::Tag

    class Collection__

      class Controller__

        def initialize collection, listener
          @collection = collection ; @listener = listener
        end

        def add_tag_using_iambic stem_i, x_a
          self.class::Add__.new( @collection, @listener ).
            with_iambic( x_a ).add_i stem_i
        end

        def remove_tag_using_iambic stem_i, x_a
          self.class::Rm__.new( @collection, @listener ).
            with_iambic( x_a ).rm_i stem_i
        end

        def set_body_s s
          @collection.set_body_s s ; nil
        end

        class Edit___
          def initialize coll, lstn
            @collection = coll ; @listener = lstn
          end

          def with_iambic x_a
            process_iambic_fully x_a
            self
          end
        private
          def build_tag stem_i
            tag = Tag_.controller @listener
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
            @listener.receive_change_body_string s ; nil
          end

          def merge_listener x
            @listener.merge_in_other_listener_intersect x ; nil
          end
        end
      end
    end
  end
end
