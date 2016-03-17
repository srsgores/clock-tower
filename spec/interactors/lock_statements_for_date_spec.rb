describe LockStatementsForDate do
  before :each do
    @statement = create :statement, post_date: Date.today
    @statement2 = create :statement, post_date: Date.today
    @old_statement = create :statement, post_date: 1.week.ago
    @new_statement = create :statement, post_date: 1.week.from_now
    @result = LockStatementsForDate.call(date: Date.today)
  end

  it "should change the statements state to 'locked'" do
    expect(@statement.state).to eq('locked')
  end

  it "should not change statements that don't end today" do
    expect(@old_statement.state).to eq('pending')
    expect(@new_statement.state).to eq('pending')
  end

  it "should change all statements for that date" do
    expect(@statement2.state).to eq('locked')
  end

  it "should update the statement to include all time_entries before locking it" do
    expect(UpdateStatement).to receive(:call).with({ statement: @old_statement })
    LockStatementsForDate.call(date: 1.week.ago)
  end

end
