# Rules for PullRequests using danger.systems/ruby

# Always require a description of work
if github.pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end

# Execute RSpec Tests
rspec_cmd = []
rspec_cmd << 'bundle exec rspec'
rspec_cmd << '--failure-exit-code 0'
rspec_cmd << '--no-drb'
rspec_cmd << '--require rspec_junit_formatter --format RspecJunitFormatter'
rspec_cmd << '--out rspec_junit.xml'
rspec_cmd = rspec_cmd.join(' ')

system(rspec_cmd)

# Post rspec results to GitHub
junit.parse('rspec_junit.xml')
junit.report

# Jira Issue Linking
jira.check(
  key: ['KEY', 'PM'],
  url: 'https://myjira.atlassian.net/browse',
  search_title: true,
  search_commits: false,
  fail_on_warning: false,
  report_missing: true,
  skippable: true
)

# Check plugin with Danger's own linter
system('bundle exec danger plugins lint')

rubocop.lint(inline_comment: true)

sentiment.analyze

