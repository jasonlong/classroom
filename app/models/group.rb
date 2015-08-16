class Group < ActiveRecord::Base
  include GitHubTeamable

  has_one :organization, through: :grouping

  belongs_to :grouping

  has_and_belongs_to_many :repo_accesses, before_add:    :add_member_to_github_team, unless: :new_record?,
                                          before_remove: :remove_from_github_team

  validates :github_team_id, presence: true
  validates :github_team_id, uniqueness: true

  validates :grouping, presence: true

  validates :title, presence: true

  private

  # Internal: Add the RepoAccess User to the Groups GitHub team
  #
  # repo_access - The RepoAccess that will be added to the group
  #
  # Returns if it was successful
  def add_member_to_github_team(repo_access)
    github_team = GitHubTeam.new(organization.github_client, github_team_id)
    github_user = GitHubUser.new(repo_access.user.github_client)

    github_team.add_team_membership(github_user.login)
  end

  # Internal: Remove the RepoAccess's User from the Groups GitHub team
  #
  # repo_access - The RepoAccess that will be removed to the group
  #
  # Returns if it was successful
  def remove_from_github_team(repo_access)
    github_team = GitHubTeam.new(organization.github_client, github_team_id)
    github_user = GitHubUser.new(repo_access.user.github_client)

    github_team.remove_team_membership(github_user.login)
  end
end
