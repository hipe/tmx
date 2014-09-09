module Skylab::Snag

  class Models::Tag

    class Collection__

      class Controller__

        class Add__ < Edit___

          def initialize( * )
            @do_prepend = false
            super
          end

          def add_i stem_i
            @tag = build_tag stem_i
            if @tag.is_valid
              add_tag
            else
              @tag.last_callback_result
            end
          end

        private

          def add_tag
            found_tag = find_existing_tag @tag
            if found_tag
              when_already_exists
            else
              add_nonexisting_tag
            end
          end

          def when_already_exists
            _ev = bld_already_exists_event
            _r = @delegate.receive_error_event _ev
            _r  # :+[#049] whether this is an error is up to the caller
          end

          def bld_already_exists_event
            Event_[].inline :already_exists,  # :+[#044] inline events exper.
                :identifier, identifier, :tag_s, @tag.render do |y, o|
              y << "#{ val o.identifier.render } is already tagged #{
                }with #{ val o.tag_s }"
            end
          end

          def add_nonexisting_tag
            line = get_body_s
            sep = line.length.zero? ? EMPTY_S_ : SPACE_
            _new = if @do_prepend
              "#{ @tag.render }#{ sep }#{ line }"
            else
              "#{ line }#{ sep }#{ @tag.render }"
            end
            set_body_s _new
            when_added
          end

          def when_added
            _ev = Added__.new @tag.render, verb_i
            @delegate.receive_info_event _ev
            ACHIEVED_
          end

          def verb_i
            @do_prepend ? :prepend : :append
          end

          Added__ = Event_[].new :tag_s, :verb_i do
            message_proc do |y, o|
              y << "#{ Snag_::Lib_::NLP[]::EN::POS::Verb[
                o.verb_i.to_s ].preterite } #{ val o.tag_s }" ; nil
            end
          end

          Snag_::Lib_::Entity[][ self, -> do

            def delegate
              merge_delegate iambic_property
            end

            def prepend
              @do_prepend = true
            end
          end ]
        end
      end
    end
  end
end
