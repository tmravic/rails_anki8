require "rails_helper"

RSpec.describe "Replica demo", type: :request do
  def sql_log
    response.body[/<pre id="sql">(.*?)<\/pre>/m, 1].to_s
  end

  it "writes a GET on the primary while the selector is off" do
    expect { get "/replica_demo", params: { mode: "off" } }.to change(Hit, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(sql_log).to include("role=writing")
    expect(sql_log).to include("INSERT")
    expect(response.body).not_to include("ReadOnlyError")
  end

  it "refuses the write when the GET is run like DatabaseSelector" do
    expect { get "/replica_demo", params: { mode: "selector" } }.not_to change(Hit, :count)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ReadOnlyError")
    expect(sql_log).to include("role=reading")
    expect(sql_log).to include("SELECT")
    expect(sql_log).not_to include("INSERT")
  end

  it "still refuses the write during the 2 second writer window" do
    expect { post "/replica_demo" }.to change(Hit, :count).by(1)
    follow_redirect!

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("2 second")
    expect(response.body).to include("ReadOnlyError")
    expect(sql_log).to include("role=writing")
    expect(sql_log).to include("SELECT")
    expect(sql_log).not_to include("INSERT")
  end

  it "reads on the replica and writes on the primary when the statements are split" do
    expect { get "/replica_demo", params: { mode: "split" } }.to change(Hit, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("ReadOnlyError")
    expect(sql_log).to match(/role=reading\s+SELECT/)
    expect(sql_log).to match(/role=writing\s+INSERT/)
  end
end