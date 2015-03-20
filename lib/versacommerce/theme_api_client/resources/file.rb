require 'active_support/core_ext/module/delegation'
require 'versacommerce/theme_api_client/fetcher'
require 'versacommerce/theme_api_client/resources/file_behaviour'
require 'versacommerce/theme_api_client/resource'

module Versacommerce
  class ThemeAPIClient
    module Resources
      class File < Resource
        include FileBehaviour

        delegate :client, :fetcher, :file_path, :download_path, to: :class
        define_attribute_methods :content

        class << self
          delegate :fetcher, :file_path, :tree_path, :download_path, to: :client

          def in_path(path = '', recursive = true)
            recursive ? fetch_recursive(path) : fetch_non_recursive(path)
          end

          def find(path, load_content: false)
            response = fetcher.get(file_path(path))
            attributes = response.json

            new(attributes.merge(new_record: false)).tap do |file|
              file.reload_content if load_content && !file.has_content?
            end
          end

          def delete(path)
            fetcher.delete(file_path(path))
            true
          end

          def model_name
            ActiveModel::Name.new(self, nil, 'File')
          end

          private

          def fetch_recursive(path)
            directory = fetcher.get(tree_path(path)).json
            files_from_tree(directory)
          end

          def fetch_non_recursive(path)
            directory = fetcher.get(tree_path(path)).json

            directory.map do |child|
              if child['type'] == 'file'
                new(child.slice('path', 'stats').merge(new_record: false))
              end
            end.compact
          end

          def files_from_tree(directory, files = [])
            files.tap do |f|
              directory.each do |child|
                case child['type']
                when 'directory'
                  files_from_tree(child['children'], f)
                when 'file'
                  f << new(child.slice('path', 'content').merge(new_record: false))
                end
              end
            end
          end
        end

        attr_reader :content
        attr_accessor :stats

        def delete
          unless new_record?
            response = fetcher.delete(file_path(path))
            content_will_change!
            self.new_record = true
          end
        end

        def content=(value)
          unless value == @content
            content_will_change!
            @content = value.to_s
          end
        end

        def has_content?
          !!@content
        end

        def reload_content
          unless new_record?
            response = fetcher.get(download_path(path))
            self.content = response.to_s
            clear_attribute_changes(:content)
          end

          self
        end

        def inspect
          '#<File:0x%x>' % (object_id << 1)
        end

        private

        def commit
          response = if new_record?
            fetcher.post_form(file_path, serialized_attributes)
          else
            fetcher.patch_form(file_path(path_was), serialized_attributes)
          end

          if response.status.unprocessable_entity?
            add_errors(response.json['errors']) if response.json.key?('errors')
            false
          else
            true
          end
        end

        def serialized_attributes
          if has_content? && content_changed?
            content_file = HTTP::FormData::File.new(StringIO.new(content), filename: name)
            {'file[path]' => path.to_s, 'file[content]' => content_file}
          else
            {'file[path]' => path.to_s}
          end
        end
      end
    end
  end
end
