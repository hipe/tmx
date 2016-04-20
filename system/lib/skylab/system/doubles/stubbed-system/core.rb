module Skylab::System

  module Doubles::Stubbed_System  # see [#028]

    class << self

      def enhance_client_class tcc

        tcc.send :define_method, :stubbed_system_conduit do

          cache = cache_hash_for_stubbed_system

          cache.fetch manifest_path_for_stubbed_system do |path|
            x = Here_::Readable_Writable_Based_.new path
            cache[ path ] = x
            x
          end
        end ;
      end  # >>

      def recording_session byte_downstream, & edit_p
        Here_::Recording_Session__.new( byte_downstream, & edit_p ).execute
      end
    end  # >>

    # ==

    class Popen3_Result_via_Proc_

      def initialize & three_p
        @__three_p = three_p
      end

      def produce

        sout_a = [] ; serr_a = []

        d = @__three_p[ :_nothing_, sout_a, serr_a ]

        _sout_st = Stubbed_IO_for_Read_.via_nonsparse_array sout_a
        _serr_st = Stubbed_IO_for_Read_.via_nonsparse_array serr_a
        _thread = Stubbed_Thread.new d

        [ :_dont_, _sout_st, _serr_st, _thread ]
      end
    end

    class Stubbed_IO_for_Read_ < Callback_::Stream

      def read
        s = gets
        if s
          buffer = s.dup
          begin
            s = gets
            s or break
            buffer << s
            redo
          end while nil
          buffer
        end
      end
    end

    # ==

    class Stubbed_Thread

      def initialize es
        @value = Stubbed_Thread_Value___.new es
      end

      attr_reader(
        :value
      )

      def exit
        self
      end
    end

    # ==

    Stubbed_Thread_Value___ = ::Struct.new :exitstatus

    # ==

    Here_ = self
  end
end
# #history: nabbed simplified rewrite from [gv]
