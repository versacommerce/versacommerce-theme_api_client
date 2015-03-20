require 'active_support/core_ext/module/delegation'
require 'versacommerce/theme_api_client/fetcher'
require 'versacommerce/theme_api_client/resources/file_behaviour'
require 'versacommerce/theme_api_client/relations/file_relation'
require 'versacommerce/theme_api_client/resource'

module Versacommerce
  class ThemeAPIClient
    module Resources
      class Directory < Resource
        include FileBehaviour

        delegate :client, :fetcher, :directory_path, to: :class

        class << self
          delegate :fetcher, :directory_path, :tree_path, to: :client

          def in_path(path = '', recursive = true)
            recursive ? fetch_recursive(path) : fetch_non_recursive(path)
          end

          def find(path, **options)
            fetcher.head(directory_path(path))
            new(path: path, new_record: false)
          end

          def delete(path)
            fetcher.delete(directory_path(path))
            clear_changes_information
            self.new_record = true
          end

          def model_name
            ActiveModel::Name.new(self, nil, 'Directory')
          end

          private

          def fetch_recursive(path)
            directory = fetcher.get(tree_path(path)).json
            directories_from_tree(directory)
          end

          def fetch_non_recursive(path)
            fetcher.get(directory_path(path)).json['directories'].map do |directory|
              new(directory.merge(new_record: false))
            end
          end

          def directories_from_tree(directory, directories = [])
            directories.tap do |dirs|
              directory.each do |child|
                if child['type'] == 'directory'
                  dirs << new(child.slice('path').merge(new_record: false))
                  directories_from_tree(child['children'], dirs)
                end
              end
            end
          end
        end

        def directories(recursive: false)
          client.directories(path: path, recursive: recursive)
        end

        def files(recursive: false)
          client.files(path: path, recursive: recursive)
        end

        def delete
          unless new_record?
            response = fetcher.delete(directory_path(path))
            response.status.no_content?
          end
        end

        def inspect
          '#<Directory:0x%x>' % (object_id << 1)
        end

        private

        def commit
          response = if new_record?
            fetcher.post(directory_path, serialized_attributes)
          else
            fetcher.patch(directory_path(path_was), serialized_attributes)
          end

          if response.status.unprocessable_entity?
            add_errors(response.json['errors']) if response.json.key?('errors')
            false
          else
            true
          end
        end

        def serialized_attributes
          {directory: {path: path.to_s}}
        end
      end
    end
  end
end
