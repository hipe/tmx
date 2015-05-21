module Skylab::System::TestSupport

  module Services::Filesystem::Path_Tools::Pretty_Path::Test_Support

    class << self
      def [] tcm
        tcm.extend ModuleMethods

        tcm.send :define_method, :__parent_subject, ( Callback_.memoize do
          System_.services.filesystem.path_tools
        end )
      end
    end  # >>

    # <-

  module ModuleMethods

    def frame & p
      context( & p )
    end

    [ :home, :pwd ].each do |i|

      define_method i do | * a |
        method_i = :"#{ i }_x"
        if a.length.zero?
          send method_i
        else
          x = a.first
          define_singleton_method method_i do
            x
          end
        end
      end
    end

    def exemplifying s, * a, & p

      empty_p = -> {}  # `EMPTY_P`

      setup_frame_p = -> do

        _home_p = -> { home_x }
        _pwd_p = -> { pwd_x }

        System_::Services___::Filesystem::Path_Tools__::Clear__[ _home_p, _pwd_p ]

        setup_frame_p = empty_p
      end

      define_method :setup_frame do
        setup_frame_p[]
      end

      context s, * a, & p

    end

    def o input, expected, * a

      _verb_phrase_s = if expected == input
        'does not change'
      else
        "prettifies to #{ expected.inspect }"
      end

      it "#{ input.inspect } #{ _verb_phrase_s }", * a do

        setup_frame
        result_x = __parent_subject.pretty_path input
        result_x.should eql expected
      end
    end

    def home_x
    end

    def pwd_x
    end
  end
# ->
  end
end