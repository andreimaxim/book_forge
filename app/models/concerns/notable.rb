# frozen_string_literal: true

module Notable
  extend ActiveSupport::Concern

  included do
    has_many :note_records, class_name: "Note", as: :notable, dependent: :destroy
  end
end
