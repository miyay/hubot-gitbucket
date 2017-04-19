# Description:
#   GitBucket interaction script
#
# Configuration
#   HUBOT_GITBUCKET_TOKEN: GitBucket API access tokens
#
# Commands:
#   pr:123 - Show details about a GitBucket PullRequest
#   is:123 - Show URL about a GitBucket Issues
#   dev::pr:123
#
# Notes:
#   GitBucket API Plan https://gist.github.com/tanacasino/8bbce76bf2c16aea2646
#
# Author
#   miyay

bucket_url = GITBUCKET_URL
default_repository = "example_project/test_repository"
repositories = {
  "dev": "example_project/development"
}

targetRepository = (msg) ->
  name = msg.message.text.match(/^(.*)\::.*$/)
  target = (name && name[1] && repositories[name[1]]) || default_repository
  target

module.exports = (robot) ->
  robot.hear /pr:(\d+)/, (msg) ->
    room = msg.envelope.room.replace(/^#/, "")
    repository = targetRepository(msg)

    request = msg.http(bucket_url + "/api/v3/repos/" + repository + "/pulls/#{msg.match[1]}")
      .header("Authorization", "token #{process.env.HUBOT_GITBUCKET_TOKEN}")
      .get()
    request (err, res, body) ->
      if err
        callback err, body
        return
      pr = JSON.parse body

      if pr["message"]
        msg.send(pr["message"])
        return

      msg.send("Pull ##{pr['number']}: #{pr['title']}. #{pr['user']['login']} / #{pr['html_url']}")
      
  robot.hear /is:(\d+)/, (msg) ->
    room = msg.envelope.room.replace(/^#/, "")
    repository = targetRepository(msg)

    msg.send(bucket_url + "/" + repository + "/issues/" + msg.match[1])
