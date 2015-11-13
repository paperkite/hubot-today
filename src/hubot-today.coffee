# Description
#   Tracks what members of a channel are working on today
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot I'm away until [someday]
#   hubot who is away?
#   hubot I'm back now
#   hubot send today reminders
#   hubot who needs a today reminder?
#   hubot reset today records
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Patrick Hindmarsh <patrick@paperkite.co.nz>

Today = require './lib/today'
SlackToday = require './lib/adapters/slack'

SLACK_TOKEN=process.env.HUBOT_TODAY_SLASH_CMD_TOKEN
SLACK_CHANNEL=process.env.HUBOT_TODAY_SLACK_CHANNEL
REPLY_WEBHOOK=process.env.HUBOT_TODAY_SLACK_REPLY_WEBHOOK

pre = [ "Thanks", "Cheers", "Gracias", "Obrigado", "Merci"]
post = [
  "have a great day", "let's get cracking then",
  "much appreciated", "may the force be with you",
  "you're awesome", "nice", "stunning", "let's do it"
]

reminders = [
  "Hey, just a quick reminder you haven't done your " +
    "#today-in-pk update yet",
  "Hey, sorry to bug you but can you please do your " +
    "#today-in-pk update soon?",
  "Hi, it doesn't look like you've done your " +
    "#today-in-pk update yet, would you mind?",
  "Morning, are you able to do your #today-in-pk " +
    "update when you have a moment?"
]


module.exports = (robot) ->

  slack = new SlackToday(robot, REPLY_WEBHOOK, SLACK_CHANNEL, reminders)
  today = new Today(slack, robot.brain.data)

  robot.router.post "/today/slack-webhook", (req, res) ->
    return res.status(403).send('nope') unless req.body.token == SLACK_TOKEN

    user = slack.getUserProfile req.body.user_name
    today.record user, req.body.text

    thanks = pre[Math.floor(Math.random()*pre.length)]
    suffix = post[Math.floor(Math.random()*post.length)]

    res.send("#{thanks} @#{req.body.user_name}, #{suffix}!")

  robot.router.post "/today/reset", (req, res) ->
    console.log req.body
    return res.status(403).send('nope') unless req.body.token == SLACK_TOKEN
    today.resetRecords()

    res.send("ok")

  robot.respond /i.?m away (?:until (?:the )?)?(.*)/i, (res) ->
    user = slack.getUserProfile res.message.user.name
    date = today.setAway(user, res.match[1])
    if date
      date = date.toString("dddd dS MMMM, yyyy")
      res.reply "Ok, I've set you away until #{date}"
    else
      res.reply "sorry I didn't understand, can you be more specific?"

  robot.respond /(?:who.?s|who is) away\?/i, (res) ->
    away = []
    for user, date of today.listAway()
      date = Date.parse(date).toString("dddd dS MMMM, yyyy")
      away.push("#{user} away until #{date}")

    if away.length
      res.reply "These people are away:\n" + away.join("\n")
    else
      res.reply "Nobody is away at the moment!"

  robot.respond /i.?m back now/i, (res) ->
    user = slack.getUserProfile res.message.user.name
    today.setBack(user)

    res.reply "Sweet as, you are not marked away anymore!"

  robot.respond /send today reminders/i, (res) ->
    sent = today.rollcall().length
    res.reply "I've sent out #{sent} reminders :+1:"

  robot.respond /who needs a today reminder\?/i, (res) ->
    users = []
    for user in today.rollcall(false)
      users.push(user.username)

    if users.length
      res.reply "These people are guilty:\n#{users.join(", ")}"
    else
      res.reply "Everyone is onto it, all up to date today!"

  robot.respond /reset today records/i, (res) ->
    today.resetRecords()

    res.reply "Right, records have been reset for today"