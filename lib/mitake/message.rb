# frozen_string_literal: true

require 'mitake/model'
require 'mitake/recipient'
require 'mitake/response'
require 'mitake/boolean'
require 'mitake/status'

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
    map 'statuscode', 'status_code'

    # @!attribute [r] id
    # @return [String] the message id
    attribute :id, String, readonly: true

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

    # @!attribute webhook_url
    # @return [String|NilClass] the response callback url
    attribute :webhook_url, String

    # @!attribute [r] duplicate
    # @return [TrueClass|FalseClass] is the message duplicate
    attribute :duplicate, Boolean, readonly: true

    # @!attribute [r] sms_point_flag
    # @return [TrueClass|FalseClass] is the message point flag
    attribute :sms_point_flag, Boolean

    # @!attribute [r] response
    # @return [Response] the response
    attribute :response, Response, readonly: true

    # Send message
    #
    # @since 0.1.0
    # @api private
    def delivery
      @res ||= []
      return self if sent?

      self.class.execute(params) do |items|
        @res << (items && items.first)
        attrs = items && items.first && items.first.slice(*self.class.attribute_names)
        assign_attributes(attrs)
        @response = Response.new(items&.first)
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
      @response&.duplicate?
    end

    # Readable status code
    #
    # @return [String] the status code description
    #
    # @since 0.1.0
    def status
      @response&.status
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
        dlvtime: @schedule_at && @schedule_at.strftime('%Y%m%d%H%M%S'),
        vldtime: @expired_at && @expired_at.strftime('%Y%m%d%H%M%S'),
        dstaddr: @recipient.phone_number,
        destname: @recipient.name,
        response: @webhook_url,
        smsPointFlag: @sms_point_flag.to_i == 1 ? 1 : 0
      }.reject { |_, v| v.nil? }.to_h
    end
  end
end
