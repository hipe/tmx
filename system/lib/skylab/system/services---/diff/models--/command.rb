module Skylab::TanMan

  class Services::Diff::Command < ::Struct.new :file_path_before,
                                               :file_path_after,
                                               :prepared_options
    def string
       [ 'diff',
         prepared_options.join(' '),
         file_path_before.to_s,
         file_path_after.to_s
       ].join ' '
    end

  private

    def initialize file_path_before, file_path_after
      self[:file_path_before] = ::Pathname.new( file_path_before.to_s )
      self[:file_path_after] = ::Pathname.new( file_path_after.to_s )
      self[:prepared_options] = ['--normal'] # whatever
    end
  end
end
