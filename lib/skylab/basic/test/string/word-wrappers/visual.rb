module Skylab::Basic

  module TestSupport_Visual

    class String::Word_Wrappers < Client_

      def usage_args
        ' <width>:<height> <word> [<word> [..]]'
      end

      def execute

        _ = @argv.shift

        _a = /\A([^:]+):([^:]+)\z/.match( _ ).captures

        _d_a = _a.map( & :to_f )

        Basic_::String.word_wrappers.calm.with(

          :add_newlines,
          :aspect_ratio, _d_a,
          :downstream_yielder, @stdout,
          :input_words, @argv )

        nil
      end
    end
  end
end
