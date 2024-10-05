class OpenAi
  require 'openai'

  class << self
    def create_shift(user, calendar)
      client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_KEY"))
      users = User.where.not(classification: 'ゲスト')
      shift_list = create_shift_list(users)
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
        "<div class='alert alert-danger'>予期せぬエラーが発生しました。</div>"
      end
    end

    private

    def create_shift_list(users)
      off_count = 4
      valid_users = users.pluck(:name)
      shuffled_users = users.shuffle
      shift_list = shuffled_users.map.with_index do |user, index|
        if valid_users.include?(user.name)
          {
            name: user.name,
            classification: user.classification,
            shift_type: user.shift_type,
            start_time: calculate_start_time(user),
            end_time: calculate_end_time(user),
            is_working: index >= off_count
          }
        end
      end.compact  
      off_users = shift_list.select { |shift| !shift[:is_working] }
      if off_users.size != off_count
        Rails.logger.error "休みの人数が正しく設定されていません。再生成を行います。"
        return create_shift_list(users)
      end
  
      shift_list
    end

    def validate_shift(shift_content, users)
      lines = shift_content.split("\n")
      valid_users = users.pluck(:name)

      valid_user_check = lines.all? do |line|
        valid_users.any? { |user_name| line.include?(user_name) }
      end

      working_count = lines.count { |line| line.include?('⚪') }
      off_count = lines.count { |line| line.include?('x') } 
      early_shift = lines.any? { |line| line.include?('早番') }
      late_shift = lines.any? { |line| line.include?('遅番') }
      leader_working = lines.select { |line| line.include?('リーダー') && line.include?('⚪') }.count == 1
      all_employees_included = users.all? { |user| lines.any? { |line| line.include?(user.name) } }
      working_count.between?(8, 9) &&
      off_count == 4 && 
      early_shift &&
      late_shift &&
      leader_working &&
      all_employees_included &&
      valid_user_check 
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

    def create_shift_messages(shift_list)
      shift_list.map do |shift|
        next if shift.nil?
        if shift[:classification] == 'リーダー'
          {
            role: "system",
            content: "名前: #{shift[:name]}\n役職: #{shift[:classification]}\nシフトタイプ: 固定シフト"
          }
        elsif shift[:classification] == '社員'
          {
            role: "system",
            content: "名前: #{shift[:name]}\n役職: #{shift[:classification]}\nシフトタイプ: #{shift[:shift_type]}"
          }
        else
          {
            role: "system",
            content: "名前: #{shift[:name]}\n役職: #{shift[:classification]}\nシフト: #{shift[:start_time]} ~ #{shift[:end_time]}"
          }
        end
      end.compact
    end

    def system_message
      {
        role: "system",
        content: <<~EOS
          ###あなたはシフト作成者です。以下の条件を守ってシフトを作成してください："""
          1. 営業時間は9:00から22:00。
          2. 早番と遅番にそれぞれ最低1人ずつ社員がいること。
          3. 営業時間内で必ずリーダーが1人は入ること。
          4. 見やすく表示されるように出勤者と休みの人を区別して表示すること。
          5. 必ず4人が休みになるシフトを作成すること。これは絶対条件です。
          6. 必ず9人が出勤であるシフトを作成すること。これは絶対条件です

          上記の条件を全て満たすまで、シフトの再生成を行ってください。

          形式例：
          出勤者：
         リーダー: 山本 : ⚪︎ : （固定シフト）
          社員: 佐藤 : ⚪︎ :（早番）
          社員: 鈴木 : ⚪︎ :（遅番)
          パート・アルバイト: 渡辺 : ⚪︎ : （17:00-22:00）
          休み：
          リーダー: 山本 : x
          社員: 田中 : x
          パート・アルバイト: 伊藤: x
          """
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
                <th>出勤</th>
                <th>休み</th>
                <th>シフトタイプ</th>
              </tr>
            </thead>
          <tbody>

      HTML

      processed_employees = Set.new
  
      lines.each do |line|
        if line.strip.empty? || line.exclude?(":")
          next
        end

        parts = line.split(":")
        if parts.length >= 3
          role = parts[0].strip
          name = parts[1].strip
          status_and_time = parts[2..-1].join(":").strip

          next if processed_employees.include?(name)
          processed_employees.add(name)

          is_working = status_and_time.include?("⚪︎")
          role.downcase.include?("パート・アルバイト")

          time_match = status_and_time.match(/（(.+)）/)
          time_info = time_match ? time_match[1] : ""
          shift_type = if is_working
                         if role == "社員"
                           if time_info.downcase.include?("早番")
                             "早番"
                           elsif time_info.downcase.include?("遅番")
                             "遅番"
                           end
                         elsif role == "リーダー"
                           "固定シフト"
                         elsif role == "パート・アルバイト"
                           time_info
                         end
                       end

          html += <<-ROW
            <tr>
              <td>#{role}</td>
              <td>#{name}</td>
              <td>#{is_working ? "⚪" : ""}</td>
              <td>#{!is_working ? "x" : ""}</td>
              <td>#{shift_type}</td>
            </tr>
          ROW
        else
          Rails.logger.warn "Invalid line format: #{line}"
        end
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
