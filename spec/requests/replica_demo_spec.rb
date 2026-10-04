require "rails_helper"

RSpec.describe "Replica demo", type: :request do
  # The proxy keeps a SELECT on the primary while a transaction is open.
  # The example transaction would hide the replica route.
  self.use_transactional_tests = false

  after { Hit.delete_all }

  def sql_log
    response.body[/<pre id="sql">(.*?)<\/pre>/m, 1].to_s
  end

  it "sends the GET's count to the replica and its insert to the primary" do
    expect { get "/replica_demo", params: { mode: "off" } }.to change(Hit, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("ReadOnlyError")
    expect(sql_log).to match(/role=reading\s+SELECT/)
    expect(sql_log).to match(/role=writing\s+INSERT/)
  end

  it "still refuses the write when the GET is wrapped as a read-only replica request" do
    expect { get "/replica_demo", params: { mode: "selector" } }.not_to change(Hit, :count)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ReadOnlyError")
    expect(sql_log).to match(/role=reading\s+SELECT/)
    expect(sql_log).not_to include("INSERT")
  end

  it "still sends the SELECT to the replica inside the session stamp window" do
    expect { post "/replica_demo" }.to change(Hit, :count).by(1)

    expect { follow_redirect! }.to change(Hit, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("ReadOnlyError")
    expect(response.body).to include("session[:last_write]")
    expect(response.body).to include("proxy_delay")
    expect(sql_log).to match(/role=reading\s+SELECT/)
    expect(sql_log).to match(/role=writing\s+INSERT/)
  end

  it "reads on the replica and writes on the primary when the statements are split" do
    expect { get "/replica_demo", params: { mode: "split" } }.to change(Hit, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("ReadOnlyError")
    expect(sql_log).to match(/role=reading\s+SELECT/)
    expect(sql_log).to match(/role=writing\s+INSERT/)
  end
end