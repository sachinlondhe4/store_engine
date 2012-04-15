require 'spec_helper'

describe User do

  let!(:user) { User.new(name: "Example User", 
                         email: "user@example.com",
                         password: "foobar",
                         password_confirmation: "foobar") }

  it "has a name attribute" do
    user.should respond_to(:name)
  end

  it "has an e-mail attribute" do
    user.should respond_to(:email)
  end

  it "has a password_digest attribute" do
    user.should respond_to(:password_digest)
  end

  it "has a password attribute" do
    user.should respond_to(:password)
  end

  it "has a password_confirmation attribute" do
    user.should respond_to(:password_confirmation)
  end

  it "should respond to name and email validations" do
    user.should be_valid
  end

  context "when name is not present" do
    before { user.name = " " }
    it "should not be a valid user" do
      user.should_not be_valid
    end
  end

  context "when an email address is not present" do
    before { user.email = " " }
    it "should not be a valid user" do
      user.should_not be_valid
    end
  end

  context "when a user name is too long" do
    before { user.name = "a" * 51 }
    it "should not be a valid user" do
      user.should_not be_valid
    end
  end

  context "when an email format is invalid" do
    it "should not be a valid user" do
      addresses = %w[example_user@,foo.com user_at_example.org example.user@ppc.]
      addresses.each do |address|
        user.email = address
        user.should_not be_valid
      end
    end
  end

  context "when email format is valid" do
    it "should be a valid user" do
      addresses = %w[example_user@foo.com user@f.b.org example+user@baz.cn]
      addresses.each do |address|
        user.email = address
        user.should be_valid
      end
    end
  end

  context "when email is already taken" do
    it "should not be a valid user" do
      user_with_duplicate_email = user.dup
      user_with_duplicate_email.save
      user.should_not be_valid
    end
  end

  context "when email is already taken, irresepective of case" do
    it "should not be a valid user" do
      user_with_duplicate_email = user.dup
      user_with_duplicate_email.email = user.email.upcase
      user_with_duplicate_email.save
      user.should_not be_valid
    end
  end

  context "when password is not present" do
    it "should not be a valid user" do
      user.password = user.password_confirmation = " "
      user.should_not be_valid
    end
  end

  context "when password and password confirmation do not match" do
    it "should not be a valid user" do
      user.password_confirmation = "mismatch"
      user.should_not be_valid
    end
  end

  context "when password confirmation is nil" do
    it "should not be a valid user" do
      user.password_confirmation = nil
      user.should_not be_valid
    end
  end

  describe "return value of authenticate method" do
  before(:each) do 
    user.save
  end

  let(:found_user) { User.find_by_email(user.email) }

    context "with valid password" do
      it "should return return the user" do
        user.should == found_user.authenticate(user.password)
      end
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it "should return false" do
        user.should_not == user_for_invalid_password
        user_for_invalid_password.should be_false
      end
    end
  end
end
