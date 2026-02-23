# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Assembly Line Settings
Setting.find_or_create_by!(key: "posts_per_cycle") { |s| s.value = "1" }
Setting.find_or_create_by!(key: "posts_to_generate") { |s| s.value = "4" }
Setting.find_or_create_by!(key: "sources_enabled") { |s| s.value = "yahoo,espn" }
