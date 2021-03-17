# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::Language::BlockString do
  describe "trimming whitespace" do
    def trim_whitespace(str)
      GraphQL8::Language::BlockString.trim_whitespace(str)
    end

    it "matches the examples in graphql-js" do
      # these are taken from:
      # https://github.com/graphql8/graphql-js/blob/36ec0e9d34666362ff0e2b2b18edeb98e3c9abee/src/language/__tests__/blockStringValue-test.js#L12
      # A set of [before, after] pairs:
      examples = [
        [
          # Removes common whitespace:
          "
          Hello,
            World!

          Yours,
            GraphQL8.
          ",
          "Hello,\n  World!\n\nYours,\n  GraphQL8."
        ],
        [
          # Removes leading and trailing newlines:
          "

          Hello,
            World!

          Yours,
            GraphQL8.

          ",
          "Hello,\n  World!\n\nYours,\n  GraphQL8."
        ],
        [
          # Removes blank lines (with whitespace _and_ newlines:)
          "\n    \n
          Hello,
            World!

          Yours,
            GraphQL8.

          \n     \n",
          "Hello,\n  World!\n\nYours,\n  GraphQL8."
        ],
        [
          # Retains indentation from the first line
          "    Hello,\n      World!\n\n    Yours,\n      GraphQL8.",
          "    Hello,\n  World!\n\nYours,\n  GraphQL8.",
        ],
        [
          # Doesn't alter trailing spaces
          "\n    \n    Hello,     \n      World!   \n\n    Yours,     \n      GraphQL8.  ",
          "Hello,     \n  World!   \n\nYours,     \n  GraphQL8.  ",

        ],
      ]

      examples.each_with_index do |(before, after), idx|
        transformed_str = trim_whitespace(before)
        assert_equal(after, transformed_str, "Example ##{idx + 1}")
      end
    end
  end
end
