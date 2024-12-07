class OpenAi
  require 'openai'

  class << self
    def create_shift(user, calendar, shift_preferences)
      client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_KEY"))
      users = User.where.not(classification: 'ゲスト')
      shift_list = create_shift_list(users, shift_preferences)
      shift_messages = create_shift_messages(shift_list)

      begin
        response = client.chat(
          parameters: {
            model: 'gpt-3.5-turbo',
            messages: [
              system_message,
              { role: "system", content: "条件に従ってシフトを作成してください" },
              *shift_messages,
            ]
          }
        )
        shift_content = response.dig('choices', 0, 'message', 'content')
        generate_html_template(shift_content, calendar)
      rescue OpenAI::Error => e
        Rails.logger.error "OpenAI API error: #{e.message}"
        "<div class='alert alert-danger'>シフトの生成中にエラーが発生しました。</div>"
      rescue StandardError => e
        Rails.logger.error "Unexpected error: #{e.message}"
        "<div class='alert alert-danger'>予期せぬエラーが発生しました。お手数ですがもう一度作成し直してください。</div>"
      end
    end

    private

    def create_shift_list(users, shift_preferences)
      valid_users = users.pluck(:name)
      
      users.map do |user|
        user_preferences = shift_preferences[user] || []
        {
          name: user.name,
          classification: user.classification,
          shift_type: user.shift_type,
          start_time: calculate_start_time(user),
          end_time: calculate_end_time(user),
          preferences: user_preferences.map { |pref| format_preference(pref) }
        } if valid_users.include?(user.name)
      end.compact
    end

    def validate_shift(shift_content, users)
      lines = shift_content.split("\n")
      working_count = 0
      off_count = 0
      early_shift_count = 0
      late_shift_count = 0
      leader_working = false
      processed_employees = Set.new
    
      lines.each do |line|
        parts = line.split(":")
        next if parts.length < 3
        name = parts[1].strip
        
        if processed_employees.include?(name)
          return false
        end
        processed_employees.add(name)
    
        if line.include?('⚪︎')
          working_count += 1
          leader_working = true if line.include?('リーダー')
          if line.include?('早番')
            early_shift_count += 1
          elsif line.include?('遅番')
            late_shift_count += 1
          end

          if line.include?('パート・アルバイト')
            time_match = line.match(/(\d{2}:\d{2})-(\d{2}:\d{2})/)
            if time_match
              start_time = Time.parse(time_match[1])
              end_time = Time.parse(time_match[2])
              return false if (end_time - start_time) / 3600 < 5
            else
              return false
            end
          end
        elsif line.include?('x')
          off_count += 1
        end
      end
    
      working_count == 9 &&
      off_count == 4 &&
      early_shift_count >= 1 &&
      late_shift_count >= 1 &&
      leader_working &&
      processed_employees.size == users.size
    end

    def calculate_start_time(user)
      case user.classification
      when '社員'
        user.shift_type == '早番' ? '09:00' : '13:00'
      when 'リーダー'
        '11:00'
      else
        user.start_time&.strftime("%H:%M")
      end
    end

    def calculate_end_time(user)
      case user.classification
      when '社員'
        user.shift_type == '早番' ? '18:00' : '22:00'
      when 'リーダー'
        '20:00'
      else
        user.end_time&.strftime("%H:%M")
      end
    end

    def format_preference(preference)
      {
        date: preference.date,
        preference_type: preference.preference_type,
        shift_type: preference.shift_type,
        start_time: preference.start_time&.strftime("%H:%M"),
        end_time: preference.end_time&.strftime("%H:%M"),
        notes: preference.notes
      }
    end

    def create_shift_messages(shift_list)
      shift_list.map do |shift|
        next if shift.nil?
        content = "従業員情報:\n"
        content += "名前: #{shift[:name]}\n役職: #{shift[:classification]}\n"
        content += case shift[:classification]
                   when 'リーダー'
                     "シフトタイプ: 固定シフト\n"
                   when '社員'
                     "シフトタイプ: #{shift[:shift_type]}\n"
                   else
                     "通常シフト: #{shift[:start_time]} - #{shift[:end_time]}\n"
                   end
        content += "シフト希望（最優先で考慮すること）:\n"
        shift[:preferences].each do |pref|
          content += " 日付: #{pref[:date]}\n"
          content += " 希望: #{pref[:preference_type]}\n"
          if pref[:preference_type] == "休み"
            content += " 休日希望\n"
          else
            content += "    シフトタイプ: #{pref[:shift_type]}\n" if pref[:shift_type].present?
            content += "    時間: #{pref[:start_time]}-#{pref[:end_time]}\n" if pref[:start_time] && pref[:end_time]
          end
        end
        { role: "user", content: content.strip }
      end.compact
    end

    def system_message
      {
        role: "system",
        content: <<~EOS
          あなたはシフト作成者です。以下の条件を厳密に守り、従業員のシフト希望を最優先で反映してシフトを作成してください：
    
          1. 営業時間は9:00から22:00。
          2. 早番と遅番にそれぞれ最低2人ずつ社員がいること。
          3. 営業時間内で必ずリーダーが1人は入ること。ただし、リーダーの希望シフトがある場合はそれを優先すること。
          4. 必ず4人が休みになるシフトを作成すること。これは絶対条件です。
          5. 必ず9人が出勤になるシフトを作成すること。これは絶対条件です。
          6. 従業員のシフト希望（希望休、早番/遅番の希望、時間帯の希望）を最優先で反映すること。これは最も重要な条件です。
          7. 同じ従業員が出勤と休みの両方に記載されないようにすること。
          8. 全ての従業員が反映されていること。
    
          上記の条件を全て満たし、特にシフト希望を最優先で反映したシフトを作成してください。
          条件を満たさない場合、シフトの再生成を行います。
    
          出力形式：
          出勤者：
          リーダー : 山田太郎 : ⚪︎ : シフトタイプ: 11:00-20:00
          社員 : 太田慎二 : ⚪︎ : 早番 : 9:00-18:00
          パート・アルバイト : 菊池隆 : ⚪︎ : 15:00-19:00
          休み：
          リーダー : 中山悟 : x
          社員: 小池次郎 : x
          パート・アルバイト : 山崎毅 : x
          この形式を厳密に守ってください。
        EOS
      }
    end

    def generate_html_template(shift_content, calendar)
      lines = shift_content.split("\n")
      html = <<-HTML
        <div class="container">
          <table class="table table-bordered">
            <thead>
              <tr>
                <th>役職</th>
                <th>名前</th>
                <th>勤務状況</th>
                <th>シフトタイプ</th>
                <th>勤務時間</th>
              </tr>
            </thead>
            <tbody>
      HTML

      all_users = User.where.not(classification: 'ゲスト')
      processed_names = Set.new

      lines.each do |line|
        next if line.strip.empty? || !line.include?(":")
        parts = line.split(":")
        next unless parts.length >= 3

        role = parts[0].strip
        name = parts[1].strip
        status_and_time = parts[2].strip

        next if processed_names.include?(name)
        processed_names.add(name)

        is_working = status_and_time.include?("⚪︎")
        shift_type_match = status_and_time.match(/シフトタイプ: (.+?)$/)
        shift_type = shift_type_match ? shift_type_match[1] : ""

        time_match = status_and_time.match(/(\d{2}:\d{2})-(\d{2}:\d{2})/)
        start_time, end_time = time_match ? [time_match[1], time_match[2]] : ["", ""]

        user = User.find_by(name: name)
        preference = ShiftPreference.find_by(user: user, date: calendar)

        if preference
          if preference.preference_type == "希望休"
            is_working = false
          else
            shift_type = preference.shift_type if preference.shift_type.present?
            start_time = preference.start_time.strftime("%H:%M") if preference.start_time
            end_time = preference.end_time.strftime("%H:%M") if preference.end_time
          end
        end

        if shift_type.empty? || start_time.empty? || end_time.empty?
          case role
          when "リーダー"
            shift_type = "固定シフト" if shift_type.empty?
            start_time = "11:00" if start_time.empty?
            end_time = "20:00" if end_time.empty?
          when "社員"
            if shift_type.include?("早番")
              shift_type = "早番"
              start_time = "09:00" if start_time.empty?
              end_time = "18:00" if end_time.empty?
            elsif shift_type.include?("遅番")
              shift_type = "遅番"
              start_time = "13:00" if start_time.empty?
              end_time = "22:00" if end_time.empty?
            else
              shift_type = user.shift_type || "通常"
              start_time = user.start_time.strftime("%H:%M") if start_time.empty? && user.start_time
              end_time = user.end_time.strftime("%H:%M") if end_time.empty? && user.end_time
            end
          when "パート・アルバイト"
            shift_type = "パート" if shift_type.empty?
            start_time = user.start_time.strftime("%H:%M") if start_time.empty? && user.start_time
            end_time = user.end_time.strftime("%H:%M") if end_time.empty? && user.end_time
          end
        end

        html += <<-ROW
          <tr>
            <td>#{role}</td>
            <td>#{name}</td>
            <td>#{is_working ? "⚪︎" : "x"}</td>
            <td>#{is_working ? shift_type : ""}</td>
            <td>#{is_working ? "#{start_time} - #{end_time}" : ""}</td>
          </tr>
        ROW
      end

      all_users.each do |user|
        next if processed_names.include?(user.name)

        role = user.classification == "リーダー" ? "リーダー" : user.classification
        html += <<-ROW
          <tr>
            <td>#{role}</td>
            <td>#{user.name}</td>
            <td>x</td>
            <td></td>
            <td></td>
          </tr>
        ROW
      end

      html += <<-HTML
            </tbody>
          </table>
        </div>
      HTML

      html
    end
  end
end
