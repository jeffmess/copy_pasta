# frozen_string_literal: true

module CopyPasta
  # Base class for errors specific to CopyPasta
  class Error < StandardError
    attr_reader :message

    def initialize(message: nil)
      @message = message
    end
  end

  class CollectionError < Error
  end
end
