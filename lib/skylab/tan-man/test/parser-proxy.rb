module Skylab::TanMan

  class TestSupport::ParserProxy

    # the point of this (somewhat experimentally) is to see if we can have
    # a 'pure' parser thing that is divorced from our client controller
    # with a minimal amount of dedicated logic (the answer was yes)

    include TanMan_::Models_::DotFile::Parser::InstanceMethods

    def initialize rc
      @do_send_parser_loading_info = true
      @verbose = nil
      super
    end


    public :parser

    attr_accessor :profile

    attr_accessor :receive_parser_loading_info_p

    attr_writer :verbose

    def verbose_dotfile_parsing
      @verbose and @verbose.call
    end

    def parser_result result
      @result = super
      if profile
        maybe_do_profile
      end
      @result
    end

  private

    def maybe_do_profile
      _is = input_adapter.type.
        is? TestLib_::TTT[]::Parser::InputAdapter::Types::FILE
      if _is
        do_profile
      end
    end

    def do_profile
      d = parse_time_elapsed_seconds * 1000
      path = input_adapter.pathname.basename.to_s
      send_info_string '      (%2.1f ms to parse %s)' % [ d, path ] ; nil
    end
  end
end
