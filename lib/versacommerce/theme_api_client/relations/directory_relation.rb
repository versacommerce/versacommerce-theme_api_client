require 'versacommerce/theme_api_client/relation'

module Versacommerce
  class ThemeAPIClient
    module Relations
      class DirectoryRelation < Relation
        def resource_class
          client.directory_class
        end
      end
    end
  end
end
