
require 'datejs'
chrono = require 'chrono-node'

class Today

  constructor: (@adapter, @brain, @logger) ->
    @brain.today ?= { recorded: {}, away: {} }

  record: (who) ->
    @logger.info "Recording today status for #{who.username}"
    @brain.today.recorded[who.username] = true

  resetRecords: () ->
    @logger.info "Resetting today records"
    @brain.today.recorded = {}

  setAway: (who, input) ->
    date = chrono.parseDate(input)
    date.setHours 0
    false if Date.compare(date, Date.today()) == 1

    @logger.debug "Setting #{who.username} as away until #{date}"
    @brain.today.away[who.username] = date.toString()
    date

  setBack: (who) ->
    @logger.debug "Setting #{who.username} as back"
    delete @brain.today.away[who.username]

  isAway: (who) ->
    away_date = @brain.today.away[who.username]
    return false unless away_date

    away = Date.compare(Date.parse(away_date), Date.today()) == 1
    @setBack(who) if !away
    @logger.debug "#{who.username} is away until #{away_date}" if away
    away

  listAway: () ->
    away = []
    for user, date of @brain.today.away
      @logger.debug "#{user} stored as away until #{date}" if away
      member = @adapter.getUserProfile user
      if @isAway member
        member.away_until = Date.parse(date)
        away.push(member)
      else
        @setBack(member)
    away

  rollcall: (send = true, all = false) ->
    members = @adapter.getChannelMembers()

    return members if all

    sent = []
    for member in members
      continue if @brain.today.recorded[member.username] || @isAway(member)

      @logger.debug "Reminding #{member.username} to update their today status"
      @adapter.remind(member) if send
      sent.push(member)

    sent


module.exports = Today
