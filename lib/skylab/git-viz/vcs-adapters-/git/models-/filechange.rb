module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Filechange

      ROCKET__ = ' => '

      class << self

        def via_normal_string s

          md = NUMSTAT_LINE_RX___.match s

          if md
            insertion_count = md[ :insertion_count ].to_i
            deletion_count = md[ :deletion_count ].to_i
          else

            md = /\-\t-\t(?<the_rest>.+)/.match s

            if md
              $stderr.write"([#032]-esque)"
              insertion_count = 0
              deletion_count = 0
            end
          end

          s_ = md[ :the_rest ]

          d = s_.index ROCKET__

          if d
            is_rename = true
            source_path, destination_path = Parse_rename__[ d, s_ ]
          end

          if is_rename
            _new_rename source_path, destination_path
          else
           __new_common insertion_count, deletion_count, s_
          end
        end

        def any_via_possible_rename_line line

          md = RENAME_RX___.match line
          if md

            _content = md[ :content ]

            _content_begin = md.offset( :content ).fetch 0
            _rocket_begin = md.offset( :rocket ).fetch 0

            _adjusted_rocket_begin = _rocket_begin - _content_begin

            _path, _path_ = Parse_rename__[ _adjusted_rocket_begin, _content ]

            _new_rename _path, _path_
          end
        end

        RENAME_RX___ = /\A [ ] rename [ ]

        (?<content> .+ (?<rocket> #{ ::Regexp.escape ROCKET__ } ) .+ )

          [ ]\(\d{1,3}%\)  # e.g " (100%)"

        \n?\z/x

        def __new_common insertion_count, deletion_count, path

          new do
            @change_count = insertion_count + deletion_count
            @deletion_count = deletion_count
            @insertion_count = insertion_count
            @path = path
            freeze
          end
        end

        def _new_rename path, path_

          new do
            @change_count = 0
            @deletion_count = 0
            @destination_path = path_
            @insertion_count = 0
            @is_rename = true
            @source_path = path
            freeze
          end
        end

        private :new
      end  # >>

      NUMSTAT_LINE_RX___ = /\A

        (?<insertion_count> \d+ ) \t

        (?<deletion_count> \d+ ) \t

        (?<the_rest>.+) \z/x

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

      Parse_rename__ = -> rocket_d, s do

        # git does no escaping of filenames in their rendering here, so if
        # they contain any of the special characters used below, there is
        # a chance that our string math will save us (or at least bork
        # louder instead of failing silently )where regex would not but
        # this is unverified #open :[#019]

        close_d = s.index CLOSE_CURLY___
        if close_d

          open_d = s.rindex OPEN_CURLY___, rocket_d - 1

          head_s = s[ 0, open_d ]  # zero length OK

          tail_s = s[ close_d + 1 .. -1 ]  # zero length OK

          src_s = s[ open_d + 1 ... rocket_d ]  # zero length OK

          dst_s = s[ rocket_d + ROCKET_LENGTH__ ... close_d ]  # zero length OK

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

          [ s[ 0, rocket_d ], s[ rocket_d + ROCKET_LENGTH__ .. -1 ] ]
        end
      end

      CLOSE_CURLY___ = '}'
      OPEN_CURLY___ = '{'
      ROCKET_LENGTH__ = ROCKET__.length

    end
  end
end
