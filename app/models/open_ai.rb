class OpenAi
  require 'openai'

  def self.create_shift(user)
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_KEY"))
    users = User.where.not(classification: 'ゲスト')
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
              あなたはシフト作成者です。以下の条件を厳密に守ってシフトを作成してください：
              1. 営業時間は9:00から22:00です。
              2. パート、アルバイト、社員、リーダーがバランス良くシフトに配置されること。
              3. シフトタイプバランスを考慮して、必ず3人以上が休みであること。これは絶対条件です。
              4. シフトタイプバランスを考慮して、常に4人以上が出勤していること。
              5. 営業時間内で必ず早番と遅番にそれぞれ1人ずつの社員がいること。
              6. 見やすく表示されるように出勤者と休みの人を区別して表示すること。
              7. シフト作成の際、ゲストを一緒にシフトには入れないこと。
              8. 出勤者と休みの人の合計が必ず従業員数と一致すること。

              形式例：
              出勤者：
              リーダー: 山本（9:00-18:00）
              社員: 佐藤（早番 9:00-18:00）
              社員: 鈴木（遅番 14:00-22:00）
              パート: 高橋（10:00-15:00）
              アルバイト: 渡辺（17:00-22:00）//
              休み：
              社員: 田中
              パート: 伊藤
              アルバイト: 中村
            EOS
          },
          { role: "user", content: "条件に従ってシフトを作成してください" },
          *shift_messages,
        ]
      }
    )
    shift_content = response.dig('choices', 0, 'message', 'content')
    shift_content
  end
end
