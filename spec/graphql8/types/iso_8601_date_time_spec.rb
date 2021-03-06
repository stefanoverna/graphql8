# frozen_string_literal: true
require "spec_helper"
require "graphql8/types/iso_8601_date_time"
describe GraphQL8::Types::ISO8601DateTime do
  module DateTimeTest
    class DateTimeObject < GraphQL8::Schema::Object
      field :year, Integer, null: false
      field :month, Integer, null: false
      field :day, Integer, null: false
      field :hour, Integer, null: false
      field :minute, Integer, null: false
      field :second, Integer, null: false
      field :zone, String, null: false
      # Use method: :object so that the DateTime instance is passed to the scalar
      field :iso8601, GraphQL8::Types::ISO8601DateTime, null: false, method: :object
    end

    class Query < GraphQL8::Schema::Object
      field :parse_date, DateTimeObject, null: true do
        argument :date, GraphQL8::Types::ISO8601DateTime, required: true
      end

      def parse_date(date:)
        # Date is parsed by the scalar, so it's already a DateTime
        date
      end
    end


    class Schema < GraphQL8::Schema
      query(Query)
    end
  end


  describe "as an input" do

    def parse_date(date_str)
      query_str = <<-GRAPHQL
      query($date: ISO8601DateTime!){
        parseDate(date: $date) {
          year
          month
          day
          hour
          minute
          second
          zone
        }
      }
      GRAPHQL
      full_res = DateTimeTest::Schema.execute(query_str, variables: { date: date_str })
      full_res["errors"] || full_res["data"]["parseDate"]
    end

    it "parses valid dates" do
      res = parse_date("2018-06-07T09:31:42-07:00")
      expected_res = {
        "year" => 2018,
        "month" => 6,
        "day" => 7,
        "hour" => 9,
        "minute" => 31,
        "second" => 42,
        "zone" => "-07:00",
      }
      assert_equal(expected_res, res)
    end

    it "adds an error for invalid dates" do
      expected_errors = ["Variable date of type ISO8601DateTime! was provided invalid value"]

      assert_equal expected_errors, parse_date("2018-06-07T99:31:42-07:00").map { |e| e["message"] }
      assert_equal expected_errors, parse_date("xyz").map { |e| e["message"] }
      assert_equal expected_errors, parse_date(nil).map { |e| e["message"] }
    end
  end

  describe "as an output" do
    it "returns a string" do
      query_str = <<-GRAPHQL
      query($date: ISO8601DateTime!){
        parseDate(date: $date) {
          iso8601
        }
      }
      GRAPHQL

      date_str = "2010-02-02T22:30:30-06:00"
      full_res = DateTimeTest::Schema.execute(query_str, variables: { date: date_str })
      assert_equal date_str, full_res["data"]["parseDate"]["iso8601"]
    end

    describe "with time_precision = 3 (i.e. 'with milliseconds')" do
      before do
        @tp = GraphQL8::Types::ISO8601DateTime.time_precision
        GraphQL8::Types::ISO8601DateTime.time_precision = 3
      end

      after do
        GraphQL8::Types::ISO8601DateTime.time_precision = @tp
      end

      it "returns a string" do
        query_str = <<-GRAPHQL
        query($date: ISO8601DateTime!){
          parseDate(date: $date) {
            iso8601
          }
        }
        GRAPHQL

        date_str = "2010-02-02T22:30:30.123-06:00"
        full_res = DateTimeTest::Schema.execute(query_str, variables: { date: date_str })
        assert_equal date_str, full_res["data"]["parseDate"]["iso8601"]
      end
    end
  end

  describe "structure" do
    it "is in introspection" do
      introspection_res = DateTimeTest::Schema.execute <<-GRAPHQL
      {
        __type(name: "ISO8601DateTime") {
          name
          kind
        }
      }
      GRAPHQL

      expected_res = { "name" => "ISO8601DateTime", "kind" => "SCALAR"}
      assert_equal expected_res, introspection_res["data"]["__type"]
    end
  end
end
