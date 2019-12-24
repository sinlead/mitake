# frozen_string_literal: true

require 'mitake/model'
require 'mitake/recipient'
require 'mitake/response'
require 'mitake/boolean'

module Mitake
  # Create Sort Message
  #
  # @since 0.1.0
  class Message
    include API
    include Model

    method 'Post'
    path '/api/mtk/SmSend?CharsetURL=UTF8'
    map 'msgid', 'id'
    map 'Duplicate', 'duplicate'

    # @!attribute [r] id
    # @return [String] the message id
    attribute :id, String

    # @!attribute source_id
    # @return [String] the customize identity
    attribute :source_id, String

    # @!attribute receipient
    # @return [Mitake::Recipient] the message recipient
    attribute :recipient, Recipient

    # @!attribute body
    # @return [String] the message body
    attribute :body, String

    # @!attribute schedule_at
    # @return [Time|NilClass] the schedule time to send message
    attribute :schedule_at, Time

    # @!attribute expired_at
    # @return [Time|NilClass] the valid time for this message
    attribute :expired_at, Time

    # @!attribute [r] duplicate
    # @return [TrueClass|FalseClass] is the message duplicate
    attribute :duplicate, Boolean

    # Send message
    #
    # @since 0.1.0
    # @api private
    def delivery
      return self if sent?

      self.class.execute(params) do |items|
        attrs = items&.first&.slice(*self.class.attributes)
        assign_attributes(attrs)
      end

      self
    end

    # Does message is sent
    #
    # @return [TrueClass|FalseClass] is the message sent
    #
    # @since 0.1.0
    def sent?
      !@id.nil?
    end

    # Does message is duplicate
    #
    # @return [TrueClass|FalseClass] is the message duplicate
    #
    # @since 0.1.0
    def duplicate?
      @duplicate == true
    end

    private

    # The request params
    #
    # @since 0.1.0
    # @api private
    def params
      {
        clientid: @source_id,
        smbody: @body,
        dlvtime: @schedule_at&.strftime('%Y%m%d%H%M%S'),
        vldtime: @expired_at&.strftime('%Y%m%d%H%M%S'),
        dstaddr: @recipient.phone_number,
        destname: @recipient.name
      }.reject { |_, v| v.nil? }.to_h
    end
  end
end
