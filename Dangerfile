# Rules for PullRequests using danger.systems/ruby

# Always require a description of work
if github.pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end

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

# Rubocop Linter
rubocop.lint(inline_comment: true)

sentiment.post_analysis
