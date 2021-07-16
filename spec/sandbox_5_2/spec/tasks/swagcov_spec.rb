# frozen_string_literal: true

describe "rake swagcov", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "exits normally" do
    task
  rescue SystemExit => e
    expect(e.status).not_to eq(0)
  end
end
