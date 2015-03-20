require 'active_model'
require 'active_support/core_ext/module/delegation'

module Versacommerce
  class ThemeAPIClient
    class Resource
      include ActiveModel::Model
      include ActiveModel::Dirty

      class << self
        attr_accessor :client
        delegate :fetcher, to: :client
      end

      attr_writer :new_record

      def initialize(attributes = {})
        assign_attributes(attributes)
        clear_changes_information unless new_record?
      end

      def assign_attributes(attributes = {})
        attributes.each do |key, value|
          public_send("#{key}=", value)
        end
      end

      def save
        if valid?(current_context) && commit
          self.new_record = false
          changes_applied
          true
        else
          false
        end
      end

      def update(attributes = {})
        assign_attributes(attributes)
        save
      end

      def new_record?
        defined?(@new_record) ? @new_record : true
      end

      private

      def add_errors(errors)
        errors.each do |key, errors|
          errors.each { |error| self.errors[key] << error }
        end
      end

      def current_context
        new_record? ? :create : :update
      end
    end
  end
end
