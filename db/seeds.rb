3.times do |n|
  User.create!(
    name: "社員(早)#{n+1}",
    email: "userhaya#{n+1}@example.com", 
    password: "password",
    classification: "社員",
    shift_type: "早番"
  )
end

3.times do |n|
  User.create!(
    name: "社員(遅)#{n+1}",
    email: "useroso#{n+1}@example.com", 
    password: "password",
    classification: "社員",
    shift_type: "遅番"
  )
end

User.create!(
  name: "リーダー",
  email: "leader@example.com",
  password: "password",
  classification: "リーダー",
  shift_type: "固定シフト"
)

User.create!(
  name: "パート・アルバイト",
  email: "part1@example.com",
  password: "password",
  classification: "パート・アルバイト",
  start_time: Time.parse("10:00"),
  end_time: Time.parse("14:00")
)

User.create!(
  name: "パート・アルバイト",
  email: "part2@example.com",
  password: "password",
  classification: "パート・アルバイト",
  start_time: Time.parse("14:00"),
  end_time: Time.parse("18:00")
)

User.create!(
  name: "パート・アルバイト",
  email: "part3@example.com",
  password: "password",
  classification: "パート・アルバイト",
  start_time: Time.parse("18:00"),
  end_time: Time.parse("22:00")
)
