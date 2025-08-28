module TeamPopulations
  def buffalo_bills_populate
    self.location = "Buffalo"
    self.alias = "Bills"
    self.slug = :buf
    self.slug_long = :buffalo_bills
    self.emoji = '🦬'
    self.slug_sportrac = 'buffalo-bills'
    self.sportsradar_id = '768c92aa-75ff-4a43-bcc0-f2798c2e1724'
    self.active = true
    # Team colors from https://teamcolorcodes.com/buffalo-bills-color-codes/
    self.color_dark = '#00338D'      # Blue (primary)
    self.color_accent = '#C60C30'    # Red
    self.save
    return self
  end

  def new_york_jets_populate
    self.location = "New York"
    self.alias = "Jets"
    self.slug = :nyj
    self.slug_long = :new_york_jets
    self.emoji = '🛩️ '
    self.slug_sportrac = 'new-york-jets'
    self.sportsradar_id = '5fee86ae-74ab-4bdd-8416-42a9dd9964f3'
    self.active = true
    # Team colors from https://teamcolorcodes.com/new-york-jets-color-codes/
    self.color_dark = '#125740'      # Gotham Green (primary)
    self.color_accent = '#000000'    # Stealth Black
    self.color_alt1 = '#FFFFFF'      # Spotlight White
    self.color_rule = 'dark_accent'
    self.save
    return self
  end

  def miami_dolphins_populate
    self.location = "Miami"
    self.alias = "Dolphins"
    self.slug = :mia
    self.slug_long = :miami_dolphins
    self.emoji = '🐬'
    self.slug_sportrac = 'miami-dolphins'
    self.sportsradar_id = '4809ecb0-abd3-451d-9c4a-92a90b83ca06'
    self.active = true
    # Team colors from https://teamcolorcodes.com/miami-dolphins-color-codes/
    self.color_dark = '#008E97'      # Aqua (primary)
    self.color_accent = '#FC4C02'    # Orange
    self.color_alt1 = '#005778'      # Blue
    self.save
    return self
  end

  def new_england_patriots_populate
    self.location = "New England"
    self.alias = "Patriots"
    self.slug = :ne
    self.slug_long = :new_england_patriots
    self.emoji = '🇺🇸 '
    self.slug_sportrac = 'new-england-patriots'
    self.sportsradar_id = '97354895-8c77-4fd4-a860-32e62ea7382a'
    self.active = true
    # Team colors from https://teamcolorcodes.com/new-england-patriots-color-codes/
    self.color_dark = '#002244'      # Nautical Blue (primary)
    self.color_accent = '#C60C30'    # Red
    self.color_alt1 = '#B0B7BC'      # New Century Silver
    self.save
    return self
  end

  def kansas_city_chiefs_populate
    self.location = "Kansas City"
    self.alias = "Chiefs"
    self.slug = :kc
    self.slug_long = :kansas_city_chiefs
    self.emoji = '🏹'
    self.slug_sportrac = 'kansas-city-chiefs'
    self.sportsradar_id = '6680d28d-d4d2-49f6-aace-5292d3ec02c2'
    self.active = true
    # Team colors from https://teamcolorcodes.com/kansas-city-chiefs-color-codes/
    self.color_dark = '#E31837'      # Red (primary)
    self.color_accent = '#FFB81C'    # Gold
    self.save
    return self
  end

  def denver_broncos_populate
    self.location = "Denver"
    self.alias = "Broncos"
    self.slug = :den
    self.slug_long = :denver_broncos
    self.emoji = '🐴'
    self.slug_sportrac = 'denver-broncos'
    self.sportsradar_id = 'ce92bd47-93d5-4fe9-ada4-0fc681e6caa0'
    self.active = true
    # Team colors from https://teamcolorcodes.com/denver-broncos-color-codes/
    self.color_dark = '#FB4F14'      # Broncos Orange (primary)
    self.color_accent = '#002244'    # Broncos Navy
    self.color_rule = 'dark_accent'
    self.save
    return self
  end

  def los_angeles_chargers_populate
    self.location = "Los Angeles"
    self.alias = "Chargers"
    self.slug = :lac
    self.slug_long = :los_angeles_chargers
    self.emoji = '⚡️'
    self.slug_sportrac = 'los-angeles-chargers'
    self.sportsradar_id = '1f6dcffb-9823-43cd-9ff4-e7a8466749b5'
    self.active = true
    # Team colors from https://teamcolorcodes.com/los-angeles-chargers-color-codes/
    self.color_dark = '#0080C6'      # Powder Blue (primary)
    self.color_accent = '#FFC20E'    # Sunshine Gold
    self.color_alt1 = '#002A5E'      # Navy Blue
    self.save
    return self
  end

  def las_vegas_raiders_populate
    self.location = "Las Vegas"
    self.alias = "Raiders"
    self.slug = :lv
    self.slug_long = :las_vegas_raiders
    self.emoji = '🎲'
    self.slug_sportrac = 'las-vegas-raiders'
    self.sportsradar_id = '7d4fcc64-9cb5-4d1b-8e75-8a906d1e1576'
    self.active = true
    # Team colors from https://teamcolorcodes.com/oakland-raiders-color-codes/
    self.color_dark = '#000000'      # Raiders Black (primary)
    self.color_accent = '#A5ACAF'    # Raiders Silver
    self.save
    return self
  end

  def cincinnati_bengals_populate
    self.location = "Cincinnati"
    self.alias = "Bengals"
    self.slug = :cin
    self.slug_long = :cincinnati_bengals
    self.emoji = '🐯'
    self.slug_sportrac = 'cincinnati-bengals'
    self.sportsradar_id = 'ad4ae08f-d808-42d5-a1e6-e9bc4e34d123'
    self.active = true
    # Team colors from https://teamcolorcodes.com/cincinnati-bengals-color-codes/
    self.color_dark = '#FB4F14'      # Orange (primary)
    self.color_accent = '#000000'    # Black
    self.color_rule = 'dark_accent'
    self.save
    return self
  end

  def baltimore_ravens_populate
    self.location = "Baltimore"
    self.alias = "Ravens"
    self.slug = :bal
    self.slug_long = :baltimore_ravens
    self.emoji = '🐦‍⬛'
    self.slug_sportrac = 'baltimore-ravens'
    self.sportsradar_id = 'ebd87119-b331-4469-9ea6-d51fe3ce2f1c'
    self.active = true
    # Team colors from https://teamcolorcodes.com/baltimore-ravens-color-codes/
    self.color_dark = '#241773'      # Purple (primary)
    self.color_accent = '#000000'    # Black
    self.color_alt1 = '#9E7C0C'      # Metallic Gold
    self.color_alt2 = '#C60C30'      # Red
    self.color_rule = 'dark_accent'
    self.save
    return self
  end

  def pittsburgh_steelers_populate
    self.location = "Pittsburgh"
    self.alias = "Steelers"
    self.slug = :pit
    self.slug_long = :pittsburgh_steelers
    self.emoji = '👷‍♂️'
    self.slug_sportrac = 'pittsburgh-steelers'
    self.sportsradar_id = 'cb2f9f1f-ac67-424e-9e72-1475cb0ed398'
    self.active = true
    # Team colors from https://teamcolorcodes.com/pittsburgh-steelers-color-codes/
    self.color_dark = '#000000'      # Black (primary)
    self.color_accent = '#FFB612'    # Gold
    self.color_alt1 = '#003087'      # Blue
    self.color_alt2 = '#c60c30'      # Blue
    self.color_alt1 = '#a5acaf'      # Silver
    self.save
    return self
  end

  def cleveland_browns_populate
    self.location = "Cleveland"
    self.alias = "Browns"
    self.slug = :cle
    self.slug_long = :cleveland_browns
    self.emoji = '🟤'
    self.slug_sportrac = 'cleveland-browns'
    self.sportsradar_id = 'd5a2eb42-8065-4174-ab79-0a6fa820e35e'
    self.active = true
    # Team colors from https://teamcolorcodes.com/cleveland-browns-color-codes/
    self.color_dark = '#311D00'      # Dark Brown (primary)
    self.color_accent = '#FF3C00'    # Orange
    self.color_alt1 = '#FFFFFF'      # White
    self.save
    return self
  end

  def jacksonville_jaguars_populate
    self.location = "Jacksonville"
    self.alias = "Jaguars"
    self.slug = :jax
    self.slug_long = :jacksonville_jaguars
    self.emoji = '🐆'
    self.slug_sportrac = 'jacksonville-jaguars'
    self.sportsradar_id = 'f7ddd7fa-0bae-4f90-bc8e-669e4d6cf2de'
    self.active = true
    # Team colors from https://teamcolorcodes.com/jacksonville-jaguars-color-codes/
    self.color_dark = '#101820'      # Black (primary)
    self.color_accent = '#D7A22A'    # Gold
    self.color_alt1 = '#006778'      # Teal
    self.color_alt2 = '#9F792C'      # Dark Gold
    
    self.save
    return self
  end

  def houston_texans_populate
    self.location = "Houston"
    self.alias = "Texans"
    self.slug = :hou
    self.slug_long = :houston_texans
    self.emoji = '🐂'
    self.slug_sportrac = 'houston-texans'
    self.sportsradar_id = '82d2d380-3834-4938-835f-aec541e5ece7'
    self.active = true
    # Team colors from https://teamcolorcodes.com/houston-texans-color-codes/
    self.color_dark = '#03202F'      # Deep Steel Blue (primary)
    self.color_accent = '#A71930'    # Battle Red
    self.save
    return self
  end

  def tennessee_titans_populate
    self.location = "Tennessee"
    self.alias = "Titans"
    self.slug = :ten
    self.slug_long = :tennessee_titans
    self.emoji = '🗡️ '
    self.slug_sportrac = 'tennessee-titans'
    self.sportsradar_id = 'd26a1ca5-722d-4274-8f97-c92e49c96315'
    self.active = true
    # Team colors from https://teamcolorcodes.com/tennessee-titans-color-codes/
    self.color_dark = '#0C2340'      # Titans Navy (primary)
    self.color_accent = '#4B92DB'    # Navy
    self.color_alt1 = '#C8102E'      # Red
    self.color_alt2 = '#A5ACAF'      # Silver
    self.color_alt3 = '#54585A'      # Steel Grey
    self.save
    return self
  end

  def indianapolis_colts_populate
    self.location = "Indianapolis"
    self.alias = "Colts"
    self.slug = :ind
    self.slug_long = :indianapolis_colts
    self.emoji = '🐎'
    self.slug_sportrac = 'indianapolis-colts'
    self.sportsradar_id = '82cf9565-6eb9-4f01-bdbd-5aa0d472fcd9'
    self.active = true
    # Team colors from https://teamcolorcodes.com/indianapolis-colts-color-codes/
    self.color_dark = '#002C5F'      # Speed Blue (primary)
    self.color_accent = '#A2AAAD'    # Gray
    self.save
    return self
  end

  def green_bay_packers_populate
    self.location = "Green Bay"
    self.alias = "Packers"
    self.slug = :gb
    self.slug_long = :green_bay_packers
    self.emoji = '🧀'
    self.slug_sportrac = 'green-bay-packers'
    self.sportsradar_id = 'a20471b4-a8d9-40c7-95ad-90cc30e46932'
    self.active = true
    # Team colors from https://teamcolorcodes.com/green-bay-packers-color-codes/
    self.color_dark = '#203731'      # Dark Green (primary)
    self.color_accent = '#FFB612'    # Gold
    self.color_alt1 = '#FFFFFF'      # White
    self.save
    return self
  end

  def minnesota_vikings_populate
    self.location = "Minnesota"
    self.alias = "Vikings"
    self.slug = :min
    self.slug_long = :minnesota_vikings
    self.emoji = '😈'
    self.slug_sportrac = 'minnesota-vikings'
    self.sportsradar_id = '33405046-04ee-4058-a950-d606f8c30852'
    self.active = true
    # Team colors from https://teamcolorcodes.com/minnesota-vikings-color-codes/
    self.color_dark = '#4F2683'      # Purple (primary)
    self.color_accent = '#FFC62F'    # Gold
    self.save
    return self
  end

  def chicago_bears_populate
    self.location = "Chicago"
    self.alias = "Bears"
    self.slug = :chi
    self.slug_long = :chicago_bears
    self.emoji = '🐻'
    self.slug_sportrac = 'chicago-bears'
    self.sportsradar_id = '7b112545-38e6-483c-a55c-96cf6ee49cb8'
    self.active = true
    # Team colors from https://teamcolorcodes.com/chicago-bears-color-codes/
    self.color_dark = '#0B162A'      # Navy Blue (primary)
    self.color_accent = '#C83803'    # Orange
    self.save
    return self
  end

  def detroit_lions_populate
    self.location = "Detroit"
    self.alias = "Lions"
    self.slug = :det
    self.slug_long = :detroit_lions
    self.emoji = '🦁'
    self.slug_sportrac = 'detroit-lions'
    self.sportsradar_id = 'c5a59daa-53a7-4de0-851f-fb12be893e9e'
    self.active = true
    # Team colors from https://teamcolorcodes.com/detroit-lions-color-codes/
    self.color_dark = '#0076B6'      # Honolulu Blue (primary)
    self.color_accent = '#B0B7BC'    # Silver
    self.color_alt1 = '#000000'      # Black
    self.color_alt2 = '#FFFFFF'      # White
    self.save
    return self
  end

  def dallas_cowboys_populate
    self.location = "Dallas"
    self.alias = "Cowboys"
    self.slug = :dal
    self.slug_long = :dallas_cowboys
    self.emoji = '🤠'
    self.slug_sportrac = 'dallas-cowboys'
    self.sportsradar_id = 'e627eec7-bbae-4fa4-8e73-8e1d6bc5c060'
    self.active = true
    # Team colors from https://teamcolorcodes.com/dallas-cowboys-color-codes/
    self.color_dark = '#003594'      # Royal Blue (primary)
    self.color_accent = '#869397'      # Silver
    self.color_alt1 = '#041E42'    # Blue
    self.color_alt2 = '#7F9695'      # Silver-Green
    self.save
    return self
  end

  def new_york_giants_populate
    self.location = "New York"
    self.alias = "Giants"
    self.slug = :nyg
    self.slug_long = :new_york_giants
    self.emoji = '🗽'
    self.slug_sportrac = 'new-york-giants'
    self.sportsradar_id = '04aa1c9d-66da-489d-b16a-1dee3f2eec4d'
    self.active = true
    # Team colors from https://teamcolorcodes.com/new-york-giants-color-codes/
    self.color_dark = '#0B2265'      # Blue (primary)
    self.color_accent = '#A71930'    # Red
    self.color_alt1 = '#A5ACAF'      # Gray
    self.save
    return self
  end

  def philadelphia_eagles_populate
    self.location = "Philadelphia"
    self.alias = "Eagles"
    self.slug = :phi
    self.slug_long = :philadelphia_eagles
    self.emoji = '🦅'
    self.slug_sportrac = 'philadelphia-eagles'
    self.sportsradar_id = '386bdbf9-9eea-4869-bb9a-274b0bc66e80'
    self.active = true
    # Team colors from https://teamcolorcodes.com/philadelphia-eagles-color-codes/
    self.color_dark = '#004C54'      # Midnight Green (primary)
    self.color_accent = '#A5ACAF'    # Silver
    self.color_alt1 = '#000000'      # Black
    self.color_alt2 = '#FFFFFF'      # White
    self.save
    return self
  end

  def washington_commanders_populate
    self.location = "Washington"
    self.alias = "Commanders"
    self.slug = :was
    self.slug_long = :washington_commanders
    self.emoji = '🪖'
    self.slug_sportrac = 'washington-commanders'
    self.sportsradar_id = '22052ff7-c065-42ee-bc8f-c4691c50e624'
    self.active = true
    # Team colors from https://teamcolorcodes.com/washington-redskins-color-codes/
    self.color_dark = '#5A1414'      # Burgundy (primary)
    self.color_accent = '#FFB612'    # Gold
    self.save
    return self
  end

  def seattle_seahawks_populate
    self.location = "Seattle"
    self.alias = "Seahawks"
    self.slug = :sea
    self.slug_long = :seattle_seahawks
    self.emoji = '‍‍🐦'
    self.slug_sportrac = 'seattle-seahawks'
    self.sportsradar_id = '3d08af9e-c767-4f88-a7dc-b920c6d2b4a8'
    self.active = true
    # Team colors from https://teamcolorcodes.com/seattle-seahawks-color-codes/
    self.color_dark = '#002244'      # College Navy (primary)
    self.color_accent = '#69BE28'    # Action Green
    self.color_alt1 = '#A5ACAF'      # Wolf Gray
    self.save
    return self
  end

  def los_angeles_rams_populate
    self.location = "Los Angeles"
    self.alias = "Rams"
    self.slug = :lar
    self.slug_long = :los_angeles_rams
    self.emoji = '🐏'
    self.slug_sportrac = 'los-angeles-rams'
    self.sportsradar_id = '2eff2a03-54d4-46ba-890e-2bc3925548f3'
    self.active = true
    # Team colors from https://teamcolorcodes.com/los-angeles-rams-team-colors/
    self.color_dark = '#003594'      # Royal Blue (primary)
    self.color_accent = '#FFA300'    # Sol (Gold)
    self.color_alt1 = '#ffffff'    # White
    self.color_alt2 = '#ff8200'    # Dark Gold
    self.color_alt3 = '#ffd100'    # Yellow
    self.save
    return self
  end

  def san_francisco_49ers_populate
    self.location = "San Francisco"
    self.alias = "49ers"
    self.slug = :sf
    self.slug_long = :san_francisco_49ers
    self.emoji = '🌉'
    self.slug_sportrac = 'san-francisco-49ers'
    self.sportsradar_id = 'f0e724b0-4cbf-495a-be47-013907608da9'
    self.active = true
    # Team colors from https://teamcolorcodes.com/san-francisco-49ers-team-colors/
    self.color_dark = '#AA0000'      # 49ers Red (primary)
    self.color_accent = '#B3995D'    # Gold
    self.color_alt1 = '#FFFFFF'      # White
    self.save
    return self
  end

  def arizona_cardinals_populate
    self.location = "Arizona"
    self.alias = "Cardinals"
    self.slug = :ari
    self.slug_long = :arizona_cardinals
    self.emoji = '🐤'
    self.slug_sportrac = 'arizona-cardinals'
    self.sportsradar_id = 'de760528-1dc0-416a-a978-b510d20692ff'
    self.active = true
    # Team colors from https://teamcolorcodes.com/arizona-cardinals-color-codes/
    self.color_dark = '#97233F'      # Cardinal Red (primary)
    self.color_accent = '#FFB612'    # Yellow
    self.color_alt1 = '#000000'      # Black
    self.save
    return self
  end

  def atlanta_falcons_populate
    self.location = "Atlanta"
    self.alias = "Falcons"
    self.slug = :atl
    self.slug_long = :atlanta_falcons
    self.emoji = '🐦‍🔥'
    self.slug_sportrac = 'atlanta-falcons'
    self.sportsradar_id = 'e6aa13a4-0055-48a9-bc41-be28dc106929'
    self.active = true
    # Team colors from https://teamcolorcodes.com/atlanta-falcons-color-codes/
    self.color_dark = '#A71930'      # Red (primary)
    self.color_accent = '#000000'      # Black
    self.color_alt1 = '#A5ACAF'    # Silver
    self.color_rule = 'dark_accent'
    self.save
    return self
  end

  def carolina_panthers_populate
    self.location = "Carolina"
    self.alias = "Panthers"
    self.slug = :car
    self.slug_long = :carolina_panthers
    self.emoji = '🐈‍⬛'
    self.slug_sportrac = 'carolina-panthers'
    self.sportsradar_id = 'f14bf5cc-9a82-4a38-bc15-d39f75ed5314'
    self.active = true
    # Team colors from https://teamcolorcodes.com/carolina-panthers-color-codes/
    self.color_dark = '#0085CA'      # Carolina Blue (primary)
    self.color_accent = '#101820'    # Black
    self.color_alt1 = '#BFC0BF'      # Silver
    self.color_rule = 'dark_accent'
    self.save
    return self
  end

  def tampa_bay_buccaneers_populate
    self.location = "Tampa Bay"
    self.alias = "Buccaneers"
    self.slug = :tb
    self.slug_long = :tampa_bay_buccaneers
    self.emoji = '🏴‍☠️'
    self.slug_sportrac = 'tampa-bay-buccaneers'
    self.sportsradar_id = '4254d319-1bc7-4f81-b4ab-b5e6f3402b69'
    self.active = true
    # Team colors from https://teamcolorcodes.com/tampa-bay-buccaneers-team-colors/
    self.color_dark = '#D50A0A'      # Buccaneer Red (primary)
    self.color_accent = '#34302B'    # Pewter
    self.color_alt1 = '#FF7900'      # Bay Orange
    self.color_alt2 = '#000000'      # Black
    self.color_alt3 = '#b1babf'      # Gray
    self.color_rule = 'dark_accent'
    self.save
    return self
  end

  def new_orleans_saints_populate
    self.location = "New Orleans"
    self.alias = "Saints"
    self.slug = :no
    self.slug_long = :new_orleans_saints
    self.emoji = '⚜️ '
    self.slug_sportrac = 'new-orleans-saints'
    self.sportsradar_id = '0d855753-ea21-4953-89f9-0e20aff9eb73'
    self.active = true
    # Team colors from https://teamcolorcodes.com/new-orleans-saints-color-codes/
    self.color_dark = '#101820'      # Black (primary)
    self.color_accent = '#D3BC8D'    # Old Gold
    self.save
    return self
  end
end