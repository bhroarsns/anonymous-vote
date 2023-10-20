json.extract! ballot, :id, :voting_id, :voter, :password_digest, :choice, :exp, :created_at, :updated_at
json.url ballot_url(ballot, format: :json)
