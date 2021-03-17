# frozen_string_literal: true
require "graphql8/static_validation/message"
require "graphql8/static_validation/arguments_validator"
require "graphql8/static_validation/definition_dependencies"
require "graphql8/static_validation/type_stack"
require "graphql8/static_validation/validator"
require "graphql8/static_validation/validation_context"
require "graphql8/static_validation/literal_validator"


rules_glob = File.expand_path("../static_validation/rules/*.rb", __FILE__)
Dir.glob(rules_glob).each do |file|
  require(file)
end

require "graphql8/static_validation/all_rules"
