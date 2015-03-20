require 'versacommerce/theme_api_client/fetcher'
require 'versacommerce/theme_api_client/resources/directory'
require 'versacommerce/theme_api_client/relations/directory_relation'
require 'versacommerce/theme_api_client/resources/file'
require 'versacommerce/theme_api_client/relations/file_relation'
require 'versacommerce/theme_api_client/version'

module Versacommerce
  class ThemeAPIClient
    attr_accessor :authorization
    attr_writer :base_url, :fetcher

    def initialize(attributes = {})
      attributes.each do |key, value|
        public_send("#{key}=", value)
      end

      yield(self) if block_given?
    end

    def base_url
      @base_url || 'https://theme-api.versacommerce.de'
    end

    def directories(path: '', recursive: true)
      Relations::DirectoryRelation.new(self, path: path, recursive: recursive)
    end

    def directory_class
      @directory_class ||= Class.new(Resources::Directory).tap { |dir| dir.client = self }
    end

    def files(path: '', recursive: true)
      Relations::FileRelation.new(self, path: path, recursive: recursive)
    end

    def file_class
      @file_class ||= Class.new(Resources::File).tap { |dir| dir.client = self }
    end

    def fetcher
      @fetcher ||= Fetcher.new(self)
    end

    def directory_path(path = '')
      Pathname.new('directories').join(path)
    end

    def file_path(path = '')
      Pathname.new('files').join(path)
    end

    def download_path(path = '')
      Pathname.new('download').join(path)
    end

    def tree_path(path = '')
      Pathname.new('tree').join(path)
    end
  end
end
