require "active_support/concern"

module Minidoc::Finders
  extend ActiveSupport::Concern

  DocumentNotFoundError = Class.new(StandardError)

  module ClassMethods
    def all
      find({})
    end

    def first
      find_one({})
    end

    def count(selector = {})
      collection.count(query: selector)
    end

    def exists?(selector = {})
      find_one(selector).present?
    end

    def find(id_or_selector, options = {})
      if id_or_selector.is_a?(Hash)
        options.merge!(transformer: method(:wrap))
        collection.find(id_or_selector, options)
      else
        raise ArgumentError unless options.empty?
        id = BSON::ObjectId(id_or_selector.to_s)
        wrap(collection.find_one(_id: id))
      end
    end

    def find_one(selector = {}, options = {})
      wrap(collection.find_one(selector, options))
    end

    def find_one!(selector = {}, options = {})
      find_one(selector, options) or raise DocumentNotFoundError
    end

    def find_one_or_initialize(attributes = {}, options = {})
      raise ArgumentError unless attributes.is_a?(Hash)
      find_one(attributes, options) || new(attributes)
    end

    private

    def from_db(attrs)
      doc = new(attrs)
      doc.instance_variable_set("@new_record", false)
      doc
    end

    def wrap(doc)
      return nil unless doc

      if doc.is_a?(Array) || doc.is_a?(Mongo::Cursor)
        doc.map { |d| from_db(d) }
      else
        from_db(doc)
      end
    end
  end
end
