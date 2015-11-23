require 'datejs'
Slack = require 'node-slack'

class SlackToday

  constructor: (@robot, @webhook_url, @channel, @remindPhrases) ->
    @slack = new Slack @webhook_url

  send: (who, what) ->
    date = Date.today().toString("dddd dS MMMM")
    @slack.send({
      text: what,
      channel: @channel,
      username: "#{who.name} (via Pootle)",
      icon_url: who.image,
      link_names: 1
    })

  remind: (who) ->
    envelope = { room: who.username }
    reminder = @remindPhrases[Math.floor(Math.random()*@remindPhrases.length)]
    @robot.send(
      envelope,
      "#{reminder}\nJust use the `/today` command to make your update.\n\n" +
      "PS. If you are away, just reply to this DM with something like " +
      "\"I'm away until next Tuesday\" or " +
      "\"I'm away until 20th " + Date.today().next().month().toString("MMMM")
    )

  getUserProfile: (user_name) ->
    user = @robot.brain.userForName(user_name)
    convertUser user

  getChannelMembers: ->
    channel = @robot.adapter.client.getChannelByName @channel
    members = []
    for user_id in channel.members
      user = @robot.brain.userForId(user_id)
      members.push(convertUser(user)) unless user.slack.is_bot

    members

  convertUser = (user) ->
    {
      username: user.name
      name: user.slack.real_name,
      email: user.slack.profile.email
      image: user.slack.profile.image_72
    }

module.exports = SlackToday
