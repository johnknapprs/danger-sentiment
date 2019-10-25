# frozen_string_literal: true

module Danger
  require "google/cloud/language"

  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  John Knapp/danger-sentiment
  # @tags monday, weekends, time, rattata
  #
  class DangerSentiment < Plugin
    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [Array<String>]
    attr_accessor :my_attribute

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #

    class MissingConfiguredError < StandardError
      def initialize(msg = 'You must call sentiment.configure before sentiment.evaluate can be used')
        super
      end
    end

    # This is a descriptiong of this method
    # @return  [void]
    def credentials_json(value = "#{ENV['HOME']}/key.json")
      File.exist?(value)
    end

    # This is a descriptiong of this method
    # https://github.com/dbgrandi/danger-prose/blob/v2.0.0/lib/danger_plugin.rb#L40#-L41
    # @return  [void]
    def warn_on_mondays
      warn "Trying to merge code on a Monday" if Date.today.wday == 1
    end

    private

    def sentiment(text_content)
      require 'google/cloud/language'

      language = Google::Cloud::Language.new

      response = language.analyze_sentiment(content: text_content, type: :PLAIN_TEXT)

      response.document_sentiment
    end

    def analyze
      warn('found key.json in home directory, attempting to authenticate') unless credentials_json
      language = Google::Cloud::Language.new

      text_content = "Yukihiro Matsumoto is great!"
      response     = language.analyze_sentiment content: text_content,
                                                type: :PLAIN_TEXT
      sentiment = response.document_sentiment

      markdown "Score: #{sentiment.score}"
    end
  end
end
