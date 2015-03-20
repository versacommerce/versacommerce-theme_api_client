require 'versacommerce/theme_api_client/relation'

module Versacommerce
  class ThemeAPIClient
    module Relations
      class FileRelation < Relation
        def resource_class
          client.file_class
        end
      end
    end
  end
end
