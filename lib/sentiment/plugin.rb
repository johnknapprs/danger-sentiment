# frozen_string_literal: true

module Danger
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
  # @example Analyze all comments made on Pull Request
  #
  #          sentiment.analyze
  #
  # @see  johnknapprs/danger-sentiment
  # @tags sentiment, tone, language
  #
  class DangerSentiment < Plugin
    require 'rest-client'

    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [String]
    attr_accessor :api_token

    # A method that you can call from your Dangerfile
    # @return   [String]
    #
    def initialize(msg = 'You must call sentiment.configure before sentiment.evaluate can be used')
      super

      @api_token = ENV['PARALLEL_DOTS_API_KEY']
    end

    # Analyze all PullRequest Comments and post results
    # @return [String]
    #

    def post_analysis
      issues.each do |i|
        text_content = i[:comment_body]

        response = RestClient.post(
          'https://apis.paralleldots.com/v4/sentiment',
          {
            api_key: ENV['PARALLEL_DOTS_API_KEY'],
            text: text_content
          }
        )

        response = JSON.parse(response)
        markdown("Username: #{i[:username]}\nMessage: #{text_content}\n\n#{format_response(response)}\n")
      end
    end

    def formatted_analysis
      result = []

      issues.each do |i|
        text_content = i[:comment_body]

        response = RestClient.post(
          'https://apis.paralleldots.com/v4/sentiment',
          {
            api_key: api_token,
            text: text_content
          }
        )

        response = JSON.parse(response)
        result << "Username: #{i[:username]}\n\nMessage: #{text_content}\n\n#{format_response(response)}\n"
      end

      result.join
    end

    private

    def format_response(data)
      table = []
      table << '| sentiment | score |'
      table << '|---|---|'
      table << data['sentiment'].map { |k, v| "| #{k} | #{v} |" }

      table.join("\n")
    end

    # Array of hashes for posted Issues { username: , comment_id: comment_body: }
    #
    # @return   [Array<Hash>]

    def issues
      @issues ||= github.api
                        .issue_comments(respository_name, github.pr_json.number)
                        .reject { |c| c.body.include?('<!--') }
                        .collect do |c|
        {
          username: c.user.login,
          comment_id: c.id,
          comment_body: c.body
        }
      end
    end

    def respository_name
      github.pr_json.base.repo.full_name
    end
  end
end
