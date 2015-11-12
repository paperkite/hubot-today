# Description
#   Tracks what members of a channel are working on today
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Patrick Hindmarsh <patrick@paperkite.co.nz>

Today = require './lib/today'
SlackToday = require './lib/adapters/slack'

SLACK_TOKEN=process.env.HUBOT_TODAY_SLASH_CMD_TOKEN
REPLY_WEBHOOK=process.env.HUBOT_TODAY_SLACK_REPLY_WEBHOOK

pre = [ "Thanks", "Cheers", "Gracias", "Obrigado", "Merci"]
post = [
  "have a great day", "let's get cracking then",
  "much appreciated", "may the force be with you",
  "you're awesome", "nice", "stunning", "let's do it"
]

module.exports = (robot) ->

  slack = new SlackToday(robot, REPLY_WEBHOOK)
  today = new Today(slack)

  robot.router.post "/today/slack-webhook", (req, res) ->
    return res.status(403).send('nope') unless req.body.token == SLACK_TOKEN

    user = slack.getUserProfile req.body.user_name
    today.record user, req.body.text

    thanks = pre[Math.floor(Math.random()*pre.length)]
    suffix = post[Math.floor(Math.random()*post.length)]

    res.send("#{thanks} @#{req.body.user_name}, #{suffix}!")
