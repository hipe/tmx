module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Filechange

      class << self

        def via_normal_string s

          md = NUMSTAT_LINE_RX___.match s

          s_ = md[ :the_rest ]

          d = s_.index ROCKET_SHIP__

          if d
            is_rename = true
            source_path, destination_path = Parse_rename___[ d, s_ ]
          end

          new do

            @insertion_count = md[ :insertion_count ].to_i
            @deletion_count = md[ :deletion_count ].to_i
            @change_count = @insertion_count + @deletion_count
            if is_rename
              @is_rename =  true
              @source_path = source_path
              @destination_path = destination_path
            else
              @path = s_
            end
            freeze
          end
        end

        private :new
      end  # >>

      NUMSTAT_LINE_RX___ = /\A

        (?<insertion_count> \d+ ) \t

        (?<deletion_count> \d+ ) \t

        (?<the_rest>.+) \z/x

      ROCKET_SHIP__ = ' => '.freeze

      def initialize & edit_p
        @is_rename = false
        instance_exec( & edit_p )
      end

      attr_reader :insertion_count, :deletion_count, :change_count,

        :is_rename,
        :source_path,
        :destination_path

      def write_statistics x

        x.push @change_count

        NIL_
      end

      def end_path
        if @is_rename
          @destination_path
        else
          @path
        end
      end

      Parse_rename___ = -> rocket_d, s do

        # git does no escaping of filenames in their rendering here, so if
        # they contain any of the special characters used below, there is
        # a chance that our string math will save us (or at least bork
        # louder instead of failing silently )where regex would not but
        # this is unverified :[#019]

        close_d = s.index CLOSE_CURLY___
        if close_d

          open_d = s.rindex OPEN_CURLY___, rocket_d - 1

          head_s = s[ 0, open_d ]  # zero length OK

          tail_s = s[ close_d + 1 .. -1 ]  # zero length OK

          src_s = s[ open_d + 1 ... rocket_d ]  # zero length OK

          dst_s = s[ rocket_d + ROCKETSHIP_LENGTH__ ... close_d ]  # zero length OK

          source_path = if src_s.length.zero?
            ::File.join head_s, tail_s
          else
            "#{ head_s }#{ src_s }#{ tail_s }"
          end

          destination_path = if dst_s.length.zero?
            ::File.join head_s, tail_s
          else
            "#{ head_s }#{ dst_s }#{ tail_s }"
          end

          [ source_path, destination_path ]

        else

          [ s[ 0, rocket_d ], s[ rocket_d + ROCKETSHIP_LENGTH__ .. -1 ] ]
        end
      end

      CLOSE_CURLY___ = '}'
      OPEN_CURLY___ = '{'
      ROCKETSHIP_LENGTH__ = ROCKET_SHIP__.length

    end
  end
end
