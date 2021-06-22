# frozen_string_literal: true

describe "rake swagcov", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end
end
