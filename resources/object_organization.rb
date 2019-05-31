actions :get, :set
default_action :get

attribute :object_type, kind_of: String, required: true, default: 'vmwarevm'
