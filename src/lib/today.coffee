
require 'datejs'
chrono = require 'chrono-node'

class Today

  constructor: (@adapter, @brain) ->
    @brain.today ?= { recorded: {}, away: {} }

  record: (who, what) ->
    @brain.today.recorded[who.username] = true
    @adapter.send who, what

  resetRecords: () ->
    @brain.today.recorded = {}

  setAway: (who, input) ->
    date = chrono.parseDate(input)
    date.setHours 0
    false if Date.compare(date, Date.today()) == 1

    console.log "Setting #{who.username} as away until #{date}"
    @brain.today.away[who.username] = date.toString()
    date

  setBack: (who) ->
    console.log "Setting #{who.username} as back"
    delete @brain.today.away[who.username]

  isAway: (who) ->
    away_date = @brain.today.away[who.username]
    return false unless away_date

    away = Date.compare(Date.parse(away_date), Date.today()) == 1
    @setBack(who) if !away
    console.log "#{who.username} is away until #{away_date}" if away
    away

  listAway: () ->
    away = []
    for user, date in @brain.today.away
      member = adapter.getUserProfile user
      if @isAway member
        member.away_until = Date.parse(date)
        away.push(member)
      else
        @setBack(member)
    away

  rollcall: (send = true) ->
    members = @adapter.getChannelMembers()
    sent = []
    for member in members
      continue if @brain.today.recorded[member.username] || @isAway(member)

      console.log "Reminding #{member.username} to update their today status"
      @adapter.remind(member) if send
      sent.push(member)

    sent


module.exports = Today
