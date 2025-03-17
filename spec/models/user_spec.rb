require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'roles' do
    it 'should have the correct roles' do
      expect(User.roles.keys).to contain_exactly('user', 'moderator', 'admin')
    end

    it 'should set default role to user' do
      user = User.new
      expect(user.role).to eq('user')
    end
  end

  describe 'callbacks' do
    it 'should set default role on initialize' do
      user = User.new
      expect(user.role).to eq('user')
    end
  end

  describe 'factory' do
    let!(:moderator_user) { FactoryBot.build(:user, :moderator) }

    context 'FactoryBot.create trait :admin' do
      let!(:admin_user) { FactoryBot.create(:user, :admin) }

      it 'adds an user to the database' do
        expect(admin_user.id).not_to be_nil
        expect(admin_user.created_at).not_to be_nil
        expect(admin_user.updated_at).not_to be_nil
      end

      it 'gives the user an admin role' do
        expect(admin_user.role).to eq("admin")
      end
    end

    context 'FactoryBot.build trait :moderator' do
      let!(:moderator_user) { FactoryBot.build(:user, :moderator) }

      it 'adds an user to the database' do
        expect(moderator_user.id).to be_nil
        expect(moderator_user.created_at).to be_nil
        expect(moderator_user.updated_at).to be_nil
      end

      it 'gives the user an moderator role' do
        expect(moderator_user.role).to eq("moderator")
      end
    end

    context 'multiple factory objects' do
      before do
        FactoryBot.create_list(:user, 5)
      end

      it 'contains 5 unique email addresses for factory user objects' do
        emails = User.all.pluck(:email_address)
        expect(emails.count).to eq(5)
        expect(emails).to match_array(emails.uniq)
      end
    end
  end
end