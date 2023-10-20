json.extract! voting, :id, :title, :user_id, :description, :choices, :deadline, :mode, :config, :created_at, :updated_at
json.url voting_url(voting, format: :json)
