require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require "minidoc"
require "minidoc/test_helpers"

I18n.enforce_available_locales = false
I18n.load_path << File.expand_path("../locale/en.yml", __FILE__)

class User < Minidoc
  self.collection_name = "users"

  attribute :name, String
  attribute :age, Integer
end

class SecondUser < Minidoc
  self.collection_name = "users"

  attribute :age, Integer
end

$mongo = Mongo::MongoClient.from_uri(ENV["MONGODB_URI"] || "mongodb://localhost/minidoc_test")
Minidoc.connection = $mongo
Minidoc.database_name = $mongo.db.name

alt_url = "mongodb://#{$mongo.host}/#{$mongo.db.name}_2"
$alt_mongo = Mongo::MongoClient.from_uri(alt_url)

RSpec.configure do |config|
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random

  Kernel.srand config.seed

  config.before(:each) do
    Minidoc::TestHelpers.clear_databases([$mongo, $alt_mongo])
  end
end
