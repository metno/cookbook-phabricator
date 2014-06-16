actions :set, :delete
default_action :set

attribute :name,  :kind_of => String, :name_attribute => true, :required => true
attribute :path,  :kind_of => String, :required => true
attribute :value, :kind_of => [String, TrueClass, FalseClass], :required => false

attr_accessor :exists
