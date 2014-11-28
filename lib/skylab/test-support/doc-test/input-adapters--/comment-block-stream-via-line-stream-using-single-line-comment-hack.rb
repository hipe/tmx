module Skylab::TestSupport

  module DocTest

    module Input_Adapters__::Comment_block_stream_via_line_stream_using_single_line_comment_hack

      define_singleton_method :[] do |up|

        line = md = nil
        when_found = nil

        p = orig_p = -> do

          while line = up.gets
            md = HACK_RX__.match line
            if md
              found = true
              break
            end
          end

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
            if md
              local_margin_d_ = md[ 1 ].length
              if local_margin_d == local_margin_d_
                cb_a.push md
                md = nil
              else
                break
              end
            else
              break
            end
          end

          if line
            if ! md
              p = orig_p
            end
              # else stay with this same function
          else
            p = EMPTY_P_
          end

          DocTest::Input_Adapter_::Comment_block_via_single_line_matchdata_array[ cb_a ]
        end

        Callback_.stream do
          p[]
        end
      end

      HACK_RX__ = /\A([^#]*)#/
    end
  end
end
