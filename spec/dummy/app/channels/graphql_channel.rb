# frozen_string_literal: true
class GraphqlChannel < ActionCable::Channel::Base
  QueryType = GraphQL8::ObjectType.define do
    name "Query"
    field :value, types.Int, resolve: Proc.new { 3 }
  end

  SubscriptionType = GraphQL8::ObjectType.define do
    name "Subscription"
    field :payload, PayloadType do
      argument :id, !types.ID
    end
  end

  PayloadType = GraphQL8::ObjectType.define do
    name "Payload"
    field :value, types.Int
  end

  # Wacky behavior around the number 4
  # so we can confirm it's used by the UI
  module CustomSerializer
    def self.load(value)
      if value == "4x"
        ExamplePayload.new(400)
      else
        GraphQL8::Subscriptions::Serialize.load(value)
      end
    end

    def self.dump(obj)
      if obj.is_a?(ExamplePayload) && obj.value == 4
        "4x"
      else
        GraphQL8::Subscriptions::Serialize.dump(obj)
      end
    end
  end

  class GraphQL8Schema < GraphQL8::Schema
    query(QueryType)
    subscription(SubscriptionType)
    use GraphQL8::Subscriptions::ActionCableSubscriptions,
      serializer: CustomSerializer
  end

  def subscribed
    @subscription_ids = []
  end

  def execute(data)
    query = data["query"]
    variables = data["variables"] || {}
    operation_name = data["operationName"]
    context = {
      # Make sure the channel is in the context
      channel: self,
    }

    result = GraphQL8Schema.execute({
      query: query,
      context: context,
      variables: variables,
      operation_name: operation_name
    })

    payload = {
      result: result.to_h,
      more: result.subscription?,
    }

    # Track the subscription here so we can remove it
    # on unsubscribe.
    if result.context[:subscription_id]
      @subscription_ids << result.context[:subscription_id]
    end

    transmit(payload)
  end

  def make_trigger(data)
    GraphQL8Schema.subscriptions.trigger("payload", {"id" => data["id"]}, ExamplePayload.new(data["value"]))
  end

  def unsubscribed
    @subscription_ids.each { |sid|
      GraphQL8Schema.subscriptions.delete_subscription(sid)
    }
  end

  # This is to make sure that GlobalID is used to load and dump this object
  class ExamplePayload
    include GlobalID::Identification
    def initialize(value)
      @value = value
    end

    def self.find(value)
      self.new(value)
    end

    attr_reader :value
    alias :id :value
  end
end
