module Skylab::TMX

  module Front_Loader

    Produce_binfile_stub_class_from_bin_pn_and_prefix_and_box_and_stem_ =

      -> bin_pn, prefix, box_mod, stem do

        ::Class.new( Binfile_Stub_ ).class_exec do

          box_mod.const_set Lib_::Constantize[ stem ], self

          self::BIN_PN_ = bin_pn ; self::PREFIX_ = prefix ; self::STEM_ = stem
          self::Adapter = self
          self
        end
      end

    class Basic_Stub_ < CLI_Client_[]::Adapter::For::Face::Of::Hot

      def pre_execute  # we don't ever build an actual client ourselves
        true
      end

      def help  # parent client received a prefixed ('-h') option
        ::ARGV.empty? or fail "sanity - why? (#{ ::ARGV })"
        ::ARGV.unshift '--help'
        invoke ::ARGV
        nil
      end

      def invokee  # short-circuit the face CLI API ASAP
        self
      end
    end

    class Binfile_Stub_ < Basic_Stub_

      # this is for the simplest kind of tmx sub-node: the mystery script.
      # typically, scripts start as one-offs like this and then maybe grow
      # into something more structured as necessary.

      module For
        module Face
          module Of
            Hot = -> ns_sheet, stub_class do
              -> mechanics, _ do
                stub_class.new ns_sheet, stub_class, mechanics
              end
            end
          end
        end
      end

      def get_summary_a_from_sheet _ns_sheet
        [ basename ]
      end

      def invoke argv
        Invoke_bin_file_[ @mechanics.info_line_yielder, binfile_path, argv ]
          # might `exec`, might not
        nil
      end

    private

      def basename
        "#{ self.class::PREFIX_ }#{ self.class::STEM_ }"
      end

      def binfile_path
        @binfile_path ||= self.class::BIN_PN_.join( basename ).to_s
      end
    end

    SHEBANG_ = '#!'.freeze
    SHEBANG_LENGTH_ = SHEBANG_.length

    class Invoke_bin_file_

      def self.[] *a
        new( *a ).execute
      end

      def initialize y, binfile_path, argv
        @y, @binfile_path, @argv = y, binfile_path, argv
      end

      def execute
        if (( interpreter_directive = read_any_interpreter_directive ))
          if (( m = SHEBANG_H_[ interpreter_directive ] ))
            send m
          else
            bork "(unsupported interpreter directive - #{
              }#{ interpreter_directive })"
          end
        else
          bork "(does not look like script, will not run - #{ @binfile_path })"
        end
      end

      SHEBANG_H_ = {
        '/usr/bin/env ruby -w' => :load_ruby,
        '/usr/bin/env bash' => :exec_bash
      }.freeze

    private

      def read_any_interpreter_directive
        ::File.open @binfile_path, 'r' do |fh|
          if SHEBANG_ == fh.read( SHEBANG_LENGTH_ )
            shbng = fh.gets
            shbng and shbng.chop!
          end
          shbng
        end
      end

      def bork msg
        @y << msg
        nil
      end

      def load_ruby

        did_mutate_global_argv = false

        if @argv.object_id != ::ARGV.object_id
          ::ARGV.empty? or fail "sanity"
          did_mutate_global_argv = true
          ::ARGV.concat @argv
        end

        ::Kernel.load @binfile_path  # (`wrap` is an interesting 2nd param)

        if did_mutate_global_argv
          ::ARGV.clear
        end
        nil
      end

      def exec_bash
        ::Kernel.exec( [ @binfile_path, get_process_moniker ], * @argv )
        fail 'never see'
      end

      def get_process_moniker
        ::File.basename @binfile_path
      end
    end

    class One_shot_adapter_ < Basic_Stub_

      # this simple hot adapter is simple because you define it only with
      # one function that takes two arguments (prog_name, argv) and, and in
      # it you perform your invocation, and this builds the rest of the
      # adapter for you with sensible default behavior. in practice it is
      # useful for making adapters for some early headless-era sub-products,
      # some of which have custom client classes and-on monolithic single
      # scripts that they operate in with (e.g. the "strange hybrid" (not
      # so strange) [#bn-005])

    end

    def One_shot_adapter_.[] mod, five_p

      of_mod = MOD_A_.reduce mod do |m, i|
        if m.const_defined? i, false
          m.const_get i, false
        else
          m.const_set i, ::Module.new
        end
      end

      of_mod.const_defined?( :Hot, false ) and fail "sanity - Hot defined"

      of_mod.const_set :Hot, -> ns_sheet, client_mod do
        -> mechanics, swag do
          new five_p, ns_sheet, client_mod, mechanics
        end
      end
    end

    MOD_A_ = %i| Adapter For Face Of |.freeze

    class One_shot_adapter_

      def initialize five_p, ns_sheet, client_mod, mechanics
        super ns_sheet, client_mod, mechanics
        @five_p = five_p
        nil
      end

      def get_summary_a_from_sheet ns_sht
        [ get_anchored_program_name_separated_by( DASH_ ) ]
      end

      def invoke argv
        instance_exec get_anchored_program_name,
          * @mechanics.three_streams, argv, & @five_p
      end
    end
  end
end
