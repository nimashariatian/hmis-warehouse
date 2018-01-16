require 'rails_helper'

RSpec.describe GrdaWarehouse::Hud::Client, type: :model do  
  let(:client) { build :grda_warehouse_hud_client }
  let(:client_signed_yesterday) { build :grda_warehouse_hud_client, housing_release_status: client.class.full_release_string, consent_form_signed_on: Date.yesterday}
  let(:client_signed_2_years_ago) { build :grda_warehouse_hud_client, housing_release_status: client.class.full_release_string, consent_form_signed_on: 2.years.ago.to_date}
  let(:client_signed_2_years_ago_short_consent) { build :grda_warehouse_hud_client, housing_release_status: client.class.full_release_string, consent_form_signed_on: 2.years.ago.to_date}

  context 'when created' do
    before(:each) do
      client
    end
    context 'and send_notifications true' do
      it 'queues a notify job' do
        client.send_notifications = true
        client.save
        expect( Delayed::Job.count ).to eq 1
      end
    end
    context 'and send_notifications false' do
      it 'does not queue a notify job' do
        client.send_notifications = false
        client.save
        expect( Delayed::Job.count ).to eq 0
      end
    end
  end

  describe 'scopes' do
    describe 'age_group' do

      let(:eighteen_to_24_group) do 
        GrdaWarehouse::Hud::Client.age_group(start_age: 18, end_age: 24)
      end
      let(:sixty_plus_group) do 
        GrdaWarehouse::Hud::Client.age_group(start_age: 60)
      end

      before(:each) do
        @clients = [12,19,22,30,40,60,70].map do |age|
          create(:grda_warehouse_hud_client, DOB: age.years.ago)
        end
      end

      context 'when 18 to 24' do
        it 'has records' do
          expect( eighteen_to_24_group.count ).to eq 2
        end
        it 'returns correct clients' do
          expect( eighteen_to_24_group.map(&:DOB) ).to be_all do |dob|
            dob <= 18.years.ago && dob >= 24.years.ago
          end
        end
      end
      context 'when 60+' do
        it 'has records' do
          expect( sixty_plus_group.count ).to eq 2
        end
        it 'returns correct clients' do
          expect( sixty_plus_group.map(&:DOB) ).to be_all do |dob|
            dob <= 60.years.ago
          end
        end
      end

    end
  end

  describe 'consent form release validity' do
    context 'when consent validity is indefinite' do
      before(:each) do
        client.instance_variable_set(:@release_duration, 'Indefinite')
        client_signed_yesterday.instance_variable_set(:@release_duration, 'Indefinite')
        client_signed_2_years_ago_short_consent.instance_variable_set(:@release_duration, 'Indefinite')
      end
      context 'client with signed consent has ' do
        it 'valid consent when signed yesterday' do
          expect( client_signed_yesterday.consent_form_valid? ).to be true
        end
        it 'valid consent when signed 2 years ago' do
          expect( client_signed_2_years_ago.consent_form_valid? ).to be true
        end
        it 'invalid consent when release not set' do
          expect( client.consent_form_valid? ).to be false
        end
        it 'valid consent when release set but consent not signed' do
          client.housing_release_status = client.class.full_release_string
          expect( client.consent_form_valid? ).to be true
        end
      end
    end
    context 'when consent validity is one year' do
      before(:each) do
        client.instance_variable_set(:@release_duration, 'One Year')
        client_signed_yesterday.instance_variable_set(:@release_duration, 'One Year')
        client_signed_2_years_ago_short_consent.instance_variable_set(:@release_duration, 'One Year')
      end
      context 'client with signed consent has ' do
        it 'valid consent when signed yesterday' do
          expect( client_signed_yesterday.consent_form_valid? ).to be true
        end
        it 'invalid consent when signed 2 years ago' do
          expect( client_signed_2_years_ago_short_consent.consent_form_valid? ).to be false
        end
        it 'invalid consent when not signed' do
          expect( client.consent_form_valid? ).to be false
        end
        it 'invalid consent when release not set' do
          expect( client.consent_form_valid? ).to be false
        end
        it 'invalid consent when release set but consent not signed' do
          client.housing_release_status = client.class.full_release_string
          expect( client.consent_form_valid? ).to be false
        end
      end
      it 'there should be three clients with full housing release strings' do

        client_signed_yesterday.save
        client_signed_2_years_ago.save
        client_signed_2_years_ago_short_consent.save

        expect(GrdaWarehouse::Hud::Client.full_housing_release_on_file.count).to eq(3)
      end

      it 'after revoking consent, only one should have a full housing release string' do
        client_signed_yesterday.save
        client_signed_2_years_ago.save
        client_signed_2_years_ago_short_consent.save
        GrdaWarehouse::Hud::Client.instance_variable_set(:@release_duration, 'One Year')
        GrdaWarehouse::Hud::Client.revoke_expired_consent
        expect(GrdaWarehouse::Hud::Client.full_housing_release_on_file.count).to eq(1)
      end
    end
  end

end
