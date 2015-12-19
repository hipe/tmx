module Skylab::Zerk

  module View_Maker_Maker___

    def self.new
      View_Maker__
    end

    class View_Maker__

      class << self
        alias_method :make_view_maker, :new
        private :new
      end  # >>

      def initialize stack, rsx

        b9r = rsx.boundarizer
        @_boundarizer = b9r
        @_boundarizing_line_yielder = b9r.line_yielder
        @_stack = stack
      end

      def express

        ada = @_stack.last

        button_nf_st = if ada.is_branchesque_
          ada.to_button_name_stream
        else
          ada.any_button_name_stream
        end

        if button_nf_st

          # (note we do not clear the boundarizer here - we want a blank)
          __location_area
          __body
          __buttons button_nf_st

        else
          ada.express_prompt  # might pass self later..
        end
        NIL_
      end

      def __location_area

        @_boundarizing_line_yielder << "<<location>>"
        @_boundarizer.touch_boundary
        NIL_
      end

      def __body

        @_boundarizing_line_yielder << "<<body>>"
        @_boundarizer.touch_boundary
        NIL_
      end

      def __buttons nf_st

        _ = nf_st.map_by do | nf |
          nf.as_slug
        end.to_a

        _hs_a = Home_.lib_.basic::Hash.determine_hotstrings _

        @_boundarizing_line_yielder << ( _hs_a.map do | hs |

          if hs
            "[#{ hs.hotstring }]#{ hs.rest }"

            # if one string is a head-anchored substring of the other it is
            # always ambiguous, not displayed except we produce nil as a clue

          end
        end.join SPACE_ )

        @_boundarizer.touch_boundary

        NIL_
      end
    end
  end
end
