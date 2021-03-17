# frozen_string_literal: true
module GraphQL8
  module StaticValidation
    # Default rules for {GraphQL8::StaticValidation::Validator}
    #
    # Order is important here. Some validators return {GraphQL8::Language::Visitor::SKIP}
    # which stops the visit on that node. That way it doesn't try to find fields on types that
    # don't exist, etc.
    ALL_RULES = [
      GraphQL8::StaticValidation::NoDefinitionsArePresent,
      GraphQL8::StaticValidation::DirectivesAreDefined,
      GraphQL8::StaticValidation::DirectivesAreInValidLocations,
      GraphQL8::StaticValidation::UniqueDirectivesPerLocation,
      GraphQL8::StaticValidation::FragmentsAreFinite,
      GraphQL8::StaticValidation::FragmentsAreNamed,
      GraphQL8::StaticValidation::FragmentNamesAreUnique,
      GraphQL8::StaticValidation::FragmentsAreUsed,
      GraphQL8::StaticValidation::FragmentTypesExist,
      GraphQL8::StaticValidation::FragmentsAreOnCompositeTypes,
      GraphQL8::StaticValidation::FragmentSpreadsArePossible,
      GraphQL8::StaticValidation::FieldsAreDefinedOnType,
      GraphQL8::StaticValidation::FieldsWillMerge,
      GraphQL8::StaticValidation::FieldsHaveAppropriateSelections,
      GraphQL8::StaticValidation::ArgumentsAreDefined,
      GraphQL8::StaticValidation::ArgumentLiteralsAreCompatible,
      GraphQL8::StaticValidation::RequiredArgumentsArePresent,
      GraphQL8::StaticValidation::RequiredInputObjectAttributesArePresent,
      GraphQL8::StaticValidation::ArgumentNamesAreUnique,
      GraphQL8::StaticValidation::VariableNamesAreUnique,
      GraphQL8::StaticValidation::VariablesAreInputTypes,
      GraphQL8::StaticValidation::VariableDefaultValuesAreCorrectlyTyped,
      GraphQL8::StaticValidation::VariablesAreUsedAndDefined,
      GraphQL8::StaticValidation::VariableUsagesAreAllowed,
      GraphQL8::StaticValidation::MutationRootExists,
      GraphQL8::StaticValidation::SubscriptionRootExists,
      GraphQL8::StaticValidation::OperationNamesAreValid,
    ]
  end
end
