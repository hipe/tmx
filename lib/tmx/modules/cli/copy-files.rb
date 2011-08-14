module Skylab::Tmx::Modules::Cli
  module CopyFiles
    class MalformedRequest < ::RuntimeError ; end
    def copy_files files, src_dir, dst_dir, &handlers_definition
      on = Handlers.new
      block_given? and yield(on)
      if (missing = on.class.available_handler_names - on.defined_handler_names).any?
        raise MalformedRequest.new("Please define handler(s) for: (#{missing.join(', ')})")
      end
      call = lambda do |proc, args|
        proc.call(* args[0..[proc.arity, -1].max])
      end
      responses = []
      files.each do |file|
        src = File.join(src_dir, file)
        dst = File.join(dst_dir, file)
        args = [src, dst, file]
        resp = if File.exist?(src)
          if File.exist?(dst)
            if File.read(src) == File.read(dst) ; call[on.identical, args]
            else                                ; call[on.different, args]           ; end
          else                                  ; call[on.missing_destination, args] ; end
        else                                    ; call[on.missing_source, args]      ; end
        resp or break
        responses.push resp
      end
      responses
    end
  end

  class CopyFiles::Handlers
    class << self
      def available_handler_names
        @available_handler_names ||= []
      end
      def block_attr_accessor *names
        names.each do |name|
          available_handler_names.push(name) unless available_handler_names.include?(name)
          lambda do |_name|
            define_method(_name) do |&block|
              if block
                @defined_handler_names.include?(_name) or @defined_handler_names.push(_name)
                instance_variable_set("@#{_name}", block); self
              else
                instance_variable_get("@#{_name}")
              end
            end
          end.call(name)
        end
      end
    end
    block_attr_accessor :identical, :different, :missing_source, :missing_destination

    def initialize
      @defined_handler_names = []
    end
    attr_reader :defined_handler_names
  end
end
