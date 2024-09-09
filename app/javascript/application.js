import "channels";
import * as ActiveStorage from "@rails/activestorage"
import { Turbo } from "@hotwired/turbo-rails";
ActiveStorage.start()
Turbo.start();
