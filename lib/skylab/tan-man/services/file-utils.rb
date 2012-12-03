# this is just a proof of concept of the very basics of what a loadable
# service can look like / work like.  In this case the 'service'
# it does for us is simply centralizing where and how to load something
# and how we want to interface with it.  #experimental!

require 'fileutils'               # one main point of this is to have
                                  # exactly 1 place where this happens

module Skylab::TanMan
  class Services::FileUtils
    extend ::FileUtils            # so you can call Svcs::FU.pwd
    class << self
      ::FileUtils::METHODS.each do |m|
        public m
      end
    end

    include ::FileUtils           # so the service instance will have it
    ::FileUtils::METHODS.each { |m| public m }
  end

  Services::FileUtils::InstanceMethods = ::FileUtils
end
