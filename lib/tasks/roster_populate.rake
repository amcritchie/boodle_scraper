namespace :rosters do
  desc "Populate roster for Week 1, Season 2025 Buffalo Bills"
  task populate: :environment do
    season = 2024
    week = 1
    team_slug = :buf
    team_slug = "BUF"

    team = Team.find_by(slug: team_slug)
    raise "Team not found" unless team

    if game = Game.find_by(season: season, week: week, home_team: team_slug)
        home = true
    elsif game = Game.find_by(season: season, week: week, away_team: team_slug)
        home = false
    else
        raise "Game not found"
    end

    puts game.inspect
    puts team.inspect

    teammates = Player.by_team(team_slug)

    # Fetch players by position
    qb = teammates.by_position(:quarterback).order(overall_grade: :desc).first
    rb = teammates.by_position(:runningback).order(overall_grade: :desc).first
    wrs = teammates.by_position(:wide_receiver).order(overall_grade: :desc).limit(2)
    te = teammates.by_position(:tight_end).order(overall_grade: :desc).first
    flex = teammates.where(position: [:runningback, :wide_receiver, :tight_end]).order(overall_grade: :desc).where.not(id: [rb&.id, wrs.map(&:id), te&.id]).first
    center = teammates.by_position(:center).order(overall_grade: :desc).first
    guards = teammates.by_position(:gaurd).order(overall_grade: :desc).limit(2)
    tackles = teammates.by_position(:tackle).order(overall_grade: :desc).limit(2)

    des = teammates.by_position(:defensive_end).order(overall_grade: :desc).limit(2)
    edges = teammates.by_position(:edge_rusher).order(overall_grade: :desc).limit(1)
    lbs = teammates.by_position(:linebackers).order(overall_grade: :desc).limit(2)
    safeties = teammates.by_position(:safeties).order(overall_grade: :desc).limit(2)
    cbs = teammates.by_position(:cornerback).order(overall_grade: :desc).limit(2)
    # flex_defense = teammates.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(overall_grade: :desc).where.not(id: [des.map(&:id), edges.map(&:id), lbs.map(&:id), safeties.map(&:id), cbs.map(&:id)]).limit(2)
    flex_defense = teammates.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(overall_grade: :desc).where.not(id: (des.map(&:id) + edges.map(&:id) + lbs.map(&:id) + safeties.map(&:id) + cbs.map(&:id))).limit(2)
    puts "a="*200
    puts flex_defense
    puts "+1"
    puts des.map(&:id)
    puts "+1"
    puts edges.map(&:id)
    puts "+1"
    puts lbs.map(&:id)
    puts safeties.map(&:id)
    puts cbs.map(&:id)
    puts "++"
    puts [des.map(&:id), edges.map(&:id), lbs.map(&:id), safeties.map(&:id), cbs.map(&:id)]
    puts "b="*200
    puts (des.map(&:id) + edges.map(&:id) + lbs.map(&:id) + safeties.map(&:id) + cbs.map(&:id))
    puts "c="*200
    puts teammates.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(overall_grade: :desc).where.not(id: (des.map(&:id) + edges.map(&:id))).select(:id)
    puts "d="*200

    # Find or create roster
    roster = Roster.find_or_create_by(game: game.slug, team: team.slug)
    # Create roster
    roster.update(
        season: season,
        week: week,
        o1: qb&.slug,
        o2: rb&.slug,
        o3: wrs[0]&.slug,
        o4: wrs[1]&.slug,
        o5: te&.slug,
        o6: flex&.slug,
        o7: center&.slug,
        o8: guards[0]&.slug,
        o9: guards[1]&.slug,
        o10: tackles[0]&.slug,
        o11: tackles[1]&.slug,
        d1: des[0]&.slug,
        d2: des[1]&.slug,
        d3: edges[0]&.slug,
        d4: lbs[0]&.slug,
        d5: lbs[1]&.slug,
        d6: safeties[0]&.slug,
        d7: safeties[1]&.slug,
        d8: cbs[0]&.slug,
        d9: cbs[1]&.slug,
        d10: flex_defense[0]&.slug,
        d11: flex_defense[1]&.slug
    )

    puts "="*100
    puts "Roster for Week #{week}, Season #{season} Buffalo Bills created successfully!"
    puts "-"*100
    puts roster.inspect
  end
end
