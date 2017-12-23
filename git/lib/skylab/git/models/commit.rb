# frozen_string_literal: true

module Skylab::Git

  module Models::Commit

    class LogStream < Common_::SimpleModel  # [sli]

      # (probably redundant with other guys. make bespoke with fresh thing at #history-A.2)

      def initialize
        yield self

        _cmd = [
          GIT_EXE_,
          'log',
          '--oneline',
          '--abbrev-commit',
        ]

        _processer = remove_instance_variable :@processer

        @_process = _processer.process_via_dir_and_command_tokens(
          remove_instance_variable( :@repository_directory ),
          _cmd,
        )
      end

      attr_writer(
        :repository_directory,
        :processer,
      )

      # --

      def gets_one_commit

        _line = @_process.gets_one_stdout_line
        Simple.new( * THIS_RX___.match( _line ).captures.map( & :freeze ) )
      end

      def CLOSE_EARLY
        remove_instance_variable( :@_process ).CLOSE_EARLY
      end
    end

    # ==

    class StatistitcatingPool

      # for a case like producing commit objects from every line of a file
      # which you `git blame` on, it makes sense to avoid allocating tons of
      # wasted memory that would otherwise be allocated for the many
      # redundant data values (consider repeated commit SHA's, author names,
      # dates, paths). #coverpoint1.1

      # (this is so named becuase it *could* (but does not yet) tell you
      # the statistics of all the commits created for it.)

      def initialize
        @_author_pool = {}
        @_commit_via_sha = {}
      end

      def commit_via_three sha, date, author

        o = @_commit_via_sha[ sha ]

        if o
          o.date_string == date || sanity
          o.author_name == author || sanity
        else

          _use_author_s = @_author_pool.fetch author do
            s = author.frozen? ? author : author.dup.freeze
            @_author_pool[ s ] = s
            s
          end

          o = Minimal___.new(
            sha: sha.freeze,
            date_string: date,
            author_name: _use_author_s,
          )
          @_commit_via_sha[ o.SHA_string ] = o
        end
        o
      end
    end

    # ==

    class Simple

      # (we were expecting maybe to cram some shared string view logic in here)

      def initialize sha, date=nil, time=nil, zone=nil, msg
        @date_string = date
        @SHA_string = sha
        @time_string = time
        @zone_string = zone
        @message_string = msg
        freeze
      end

      attr_reader(
        :date_string,
        :SHA_string,
        :time_string,
        :zone_string,
        :message_string,
      )
    end

    # ==

    class Minimal___

      def initialize(
        sha: nil,
        date_string: nil,
        author_name: nil
      )

        Home_.lib_.date_time
        @date_time = ::DateTime.strptime date_string, DATE_TIME_FORMAT__
        @SHA_string = sha
        @author_name = author_name
        freeze
      end

      def date_string
        @date_time.strftime DATE_TIME_FORMAT__
      end

      attr_reader(
        :author_name,
        :date_time,
        :SHA_string,
      )
    end

    # ==

    DATE_TIME_FORMAT__ = '%Y-%m-%d %H:%M:%S %z'
    THIS_RX___ = /\A(#{ SHORT_SHA_RXS_ })[ ](.+)\z/

    # ==
    # ==
  end
end
# #history-A.3: clean add of statisticating pool and minimal commit
# #history-A.2: injected some stuff
# #history: abstracted from one-off
