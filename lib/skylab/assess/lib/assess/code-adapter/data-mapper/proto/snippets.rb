module ModelCommon
  def self.included(model)
    model.class_eval do
      include DataMapper::Resource
      property :id, DataMapper::Types::Serial, :required => true
    end
  end
end
