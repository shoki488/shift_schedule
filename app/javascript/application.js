import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import * as Turbo from "@hotwired/turbo-rails"
import "channels"

Rails.start()
ActiveStorage.start()
Turbo.start()
