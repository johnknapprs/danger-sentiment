require File.expand_path('spec_helper', __dir__)

module Danger
  describe Danger::DangerSentiment do
    it 'should be a plugin' do
      expect(Danger::DangerSentiment.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.sentiment

        # mock the PR data
        # you can then use this, eg. github.pr_author, later in the spec
        json = File.read(File.dirname(__FILE__) + '/support/fixtures/github_pr.json')
        allow(@my_plugin.github).to receive(:pr_json).and_return(json)
      end

      it 'Warns on a mondays' do
        monday_date = Date.parse('2016-07-11')
        allow(Date).to receive(:today).and_return monday_date

        @my_plugin.warn_on_mondays

        expect(@dangerfile.status_report[:warnings]).to eq(['Trying to merge code on a Monday'])
      end

      it 'Does nothing on a tuesday' do
        monday_date = Date.parse("2016-07-12")
        allow(Date).to receive(:today).and_return monday_date

        @my_plugin.warn_on_mondays

        expect(@dangerfile.status_report[:warnings]).to eq([])
      end
    end
  end
end
