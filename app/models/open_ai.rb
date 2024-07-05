class OpenAi
  require 'openai'

  def self.create_shift(user)
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_KEY"))

    users = User.all
    shift_list = users.map do |user_instance|
     
      if user_instance.classification == '社員'
        if user_instance.shift_type == '早番'
          start_time = '09:00'
          end_time = '18:00'
        elsif user_instance.shift_type == '遅番'
          start_time = '13:00'
          end_time = '22:00'
        end
      elsif user_instance.classification == 'リーダー'
        start_time = '11:00'
        end_time = '20:00'
      else
        start_time = user_instance.start_time&.strftime("%H:%M")
        end_time = user_instance.end_time&.strftime("%H:%M")
      end

      {
        name: user_instance.name,
        classification: user_instance.classification,
        shift_type: user_instance.shift_type,
        start_time: start_time,
        end_time: end_time
      }
    end

    shift_messages = shift_list.map do |shift|
      if shift[:classification] == '社員' || shift[:classification] == 'リーダー'
        {
          role: "user",
          content: "名前: #{shift[:name]}\n役職: #{shift[:classification]}\nシフトタイプ: #{shift[:shift_type]}"
        }
      else
        {
          role: "user",
          content: "名前: #{shift[:name]}\n役職: #{shift[:classification]}\nシフト: #{shift[:start_time]} ~ #{shift[:end_time]}"
        }
      end
    end
    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: "system",
            content: <<~EOS
              あなたはシフト作成者です。以下の条件でシフトを作成してください：
              1. 営業時間は9:00から22:00です。
              2. 営業時間内に少なくとも1人は常時出勤していること。
              3. パート、アルバイト、社員、リーダーがバランス良くシフトに配置されること。
              4. 社員は早番か遅番でシフトを組むこと。
              5. リーダーは固定のシフトで組むこと。
              6. パート・アルバイトは希望の時間帯で働くことができる。
              7. 常に4人以上が出勤していること。
              8. 営業時間内で必ず早番と遅番にそれぞれ1人ずつの社員がいること。
              9. 4人の出勤者の中に必ず社員、リーダーが含まれること。
              10. 見やすく表示されるように役職ごとに表示してください。
              形式例
              リーダー: 山本
              シフトタイプ: 固定シフト
              社員: 田中
              シフトタイプ: 早番
              このような形式で作成してください。
            EOS
          },
          { role: "user", content: "シフトを作成してください" },
          *shift_messages,
        ]
      }
    )
    shift_content = response.dig('choices', 0, 'message', 'content')
    shift_content
  end
end
