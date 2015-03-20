require 'active_support/concern'

module Versacommerce
  class ThemeAPIClient
    module Resources
      module FileBehaviour
        extend ActiveSupport::Concern

        included do
          define_attribute_method :path
          attr_reader :path

          validates :path, presence: true
          validates :name, length: {in: 3..64}, if: proc { name.present? }
        end

        def path=(value)
          path = Pathname.new(value.sub(/\A\/*/, ''))

          unless path == @path
            path_will_change!
            @path = path
          end
        end

        def name
          path.basename.to_s
        end

        def ==(other)
          other.kind_of?(self.class) && path == other.path
        end
      end
    end
  end
end
