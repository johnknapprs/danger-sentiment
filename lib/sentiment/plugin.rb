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
    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [String]
    attr_accessor :api_token

    # A method that you can call from your Dangerfile
    # @return   [String]
    #
    class MissingConfiguredError < StandardError
      def initialize(msg = 'You must call sentiment.configure before sentiment.evaluate can be used')
        super

        @api_token = ENV['PARALLEL_DOTS_API_KEY']
      end
    end

    # This is a descriptiong of this method
    # https://github.com/dbgrandi/danger-prose/blob/v2.0.0/lib/danger_plugin.rb#L40#-L41
    # @return  [void]
    def warn_on_mondays
      warn "Trying to merge code on a Monday" if Date.today.wday == 1
    end

    # Analyze all PullRequest Comments and post results
    # @return [String]
    #

    def analyze
      require 'rest-client'

      issues = github.api.issue_comments(respository_name, github.pr_json.number)
      issues = remove_default_comments(issues)
      issues = create_comments_hash(issues)

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

        formatted_response = []
        formatted_response << '| sentiment | score |'
        formatted_response << '|---|---|'
        formatted_response << add_response_to_table(response)

        formatted_response = formatted_response.join("\n")

        markdown("Username: #{i[:username]}\nMessage: #{text_content}\n\n#{formatted_response}\n")
      end
    end

    private

    def respository_name
      github.pr_json.base.repo.full_name
    end

    def add_response_to_table(response)
      response['sentiment'].map { |k, v| "| #{k} | #{v} |" }
    end

    def remove_default_comments(pr_comments)
      pr_comments.reject { |c| c.body.include?('<!--') }
    end

    def create_comments_hash(pr_comments)
      pr_comments.collect do |c|
        {
          username: c.user.login,
          comment_id: c.id,
          comment_body: c.body
        }
      end
    end
  end
end
