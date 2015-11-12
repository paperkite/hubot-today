dateformat = require 'dateformat'
Slack = require 'node-slack'

class SlackToday

  constructor: (@robot, @webhook_url) ->
    @slack = new Slack @webhook_url

  send: (who, what) ->
    date = dateformat(new Date, "dddd dS mmmm")
    @slack.send({
      text: "#{what}\n_#{date}_ cc/ <@#{who.username}>\n",
      username: "#{who.name} (via TodayBot)",
      icon_url: who.image
    })

  getUserProfile: (user_name) ->
    user = @robot.brain.userForName(user_name)

    profile = { name: user_name, username: user_name }
    if user && user.slack
      profile.name = user.slack.real_name
      profile.email = user.slack.profile.email
      profile.image = user.slack.profile.image_72

    profile

module.exports = SlackToday
