module Skylab::DocTest

  module Magnetics_::CommentBlockStream_via_LineStream_and_Single_Line_Comment_Hack
    # -
      define_singleton_method :[] do |up|

        line = md = nil
        when_found = nil

        p = orig_p = -> do

          begin
            line = up.gets
            line or break
            md = HACK_RX__.match line
            if md
              found = true
              break
            end
            redo
          end while nil

          if found
            p = when_found
            p[]
          else
            p = EMPTY_P_ ; nil
          end
        end

        when_found = -> do

          cb_a = [ md ]
          local_margin_d = md[ 1 ].length
          md = nil

          while line = up.gets
            md = HACK_RX__.match line
            md or break
            local_margin_d_ = md[ 1 ].length
            local_margin_d == local_margin_d_ or break
            cb_a.push md
            md = nil
          end

          if line
            if ! md
              p = orig_p
            end
              # else stay with this same function
          else
            p = EMPTY_P_
          end

          Common_::Stream.via_nonsparse_array cb_a
        end

        Common_.stream do
          p[]
        end
      end

      HACK_RX__ = /\A([^#]*)#/
    # -
  end
end
