class Integrations::Linear::ProcessorService
  pattr_initialize [:account!]

  def teams
    response = linear_client.teams
    return response if response[:error]

    response['teams']['nodes'].map(&:as_json)
  end

  def team_entites(team_id)
    response = linear_client.team_entites(team_id)
    return response if response[:error]

    {
      users: response['users']['nodes'].map(&:as_json),
      projects: response['projects']['nodes'].map(&:as_json),
      states: response['workflowStates']['nodes'].map(&:as_json),
      labels: response['issueLabels']['nodes'].map(&:as_json)
    }
  end

  def create_issue(params)
    response = linear_client.create_issue(params)
    return response if response[:error]

    {
      id: response['issueCreate']['issue']['id'],
      title: response['issueCreate']['issue']['title']
    }
  end

  def link_issue(link, issue_id)
    response = linear_client.link_issue(link, issue_id)
    return response if response[:error]

    {
      id: issue_id,
      link: link,
      link_id: response.with_indifferent_access[:attachmentLinkURL][:attachment][:id]
    }
  end

  def unlink_issue(link_id)
    response = linear_client.unlink_issue(link_id)
    return response if response[:error]

    {
      link_id: link_id
    }
  end

  def search_issue(term)
    response = linear_client.search_issue(term)

    return response if response[:error]

    response['searchIssues']['nodes'].map(&:as_json)
  end

  private

  def linear_hook
    @linear_hook ||= account.hooks.find_by!(app_id: 'linear')
  end

  def linear_client
    credentials = linear_hook.settings
    @linear_client ||= Linear.new(credentials['api_key'])
  end
end