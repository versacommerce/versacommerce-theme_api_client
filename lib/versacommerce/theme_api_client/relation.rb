module Versacommerce
  class ThemeAPIClient
    class Relation
      include Enumerable

      attr_accessor :recursive
      attr_reader :client, :path

      def initialize(client, attributes = {})
        @client = client

        attributes.each do |key, value|
          public_send("#{key}=", value)
        end
      end

      def find(path, **options)
        resource_class.find(combined_path(path), **options)
      end

      def in_path(path, **options)
        tap do |relation|
          relation.path = path
          relation.recursive = options[:recursive] if options.key?(:recursive)
        end
      end

      def build(attributes = {})
        path = combined_path(attributes[:path])
        resource_class.new(attributes.merge(path: path))
      end

      def create(attributes = {})
        build(attributes).tap do |object|
          object.save
        end
      end

      def delete(path)
        resource_class.delete(combined_path(path))
      end

      def each(&block)
        files = resource_class.in_path(path, recursive)
        files.each(&block)
      end

      def path=(value)
        @path = case value
        when Pathname
          value
        else
          Pathname.new(value.gsub(/\A\/*/, ''))
        end
      end

      def inspect
        to_s
      end

      private

      def combined_path(path)
        self.path.join(path || '')
      end
    end
  end
end
