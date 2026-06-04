# frozen_string_literal: true

require 'mitake/api'
require 'mitake/status_code'

module Mitake
  # The API response
  #
  # @since 0.1.0
  class Response
    include Model

    # @!attribute [r] raw
    # @return [Hash] the raw
    attribute :raw, Hash, readonly: true

    # @!attribute [r] source_id
    # @return [String] source_id
    attribute :source_id, String, readonly: true

    # @!attribute [r] status_code
    # @return [String] status_code
    attribute :status_code, String, readonly: true

    # @!attribute [r] error
    # @return [String] error
    attribute :error, String, readonly: true

    # @since 0.2.0
    # @api private
    def initialize(response)
      @raw = response
      @source_id = @raw.delete('source_id')
      @status_code = @raw.delete('status_code')

      @error = @raw.delete('Error')

      @raw.each do |key, value|
        instance_variable_set("@#{key}", value)
        self.class.send(:attr_reader, key)
      end
    end

    # @since 0.2.0
    # @api private
    def to_json(options = nil)
      {
        source_id: @source_id,
        status_code: @status_code,
        error: @error&.force_encoding('UTF-8')
      }.merge(@raw).to_json(options)
    end

    # @since 0.2.0
    # @api private
    def status
      StatusCode::CODES[@status_code]
    end

    # Does message is duplicate
    #
    # @return [TrueClass|FalseClass] is the message duplicate
    #
    # @since 0.2.0
    def duplicate?
      @duplicate == true
    end

    # Does message is success
    #
    # @return [TrueClass|FalseClass] Does message is success
    #
    # @since 0.2.0
    def success?
      @error.nil?
    end

    # Does message is failed
    #
    # @return [TrueClass|FalseClass] Does message is failed
    #
    # @since 0.2.0
    def failed?
      !success?
    end
  end
end
