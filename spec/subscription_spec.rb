require File.expand_path(File.join(File.dirname(__FILE__), '../lib/fastspring-saasy.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper.rb'))

describe FastSpring::Subscription do

  before do
    FastSpring::Account.setup do |config|
      config[:username] = 'admin'
      config[:password] = 'test'
      config[:company] = 'acme'
    end
  end

  context 'url for subscriptions' do
    subject { FastSpring::Subscription.find('test_ref') }
    before do
      stub_request(:get, "https://admin:test@api.fastspring.com/company/acme/subscription/test_ref").
        to_return(:status => 200, :body => "", :headers => {})
    end

    it 'returns the path for the company and reference' do
      subject.base_subscription_path.should == "/company/acme/subscription/test_ref"
    end
  end

  context 'subscription details' do
    subject { FastSpring::Subscription.find('test_ref') }
    let(:customer) { mock(:customer) }
    before do
      stub_request(:get, "https://admin:test@api.fastspring.com/company/acme/subscription/test_ref").
        to_return(stub_http_response_with('basic_subscription.xml'))
      FastSpring::Customer.stub(:new => customer)
    end

    context 'when active' do
      it 'returns the status' do
        subject.status.should == 'active'
      end

      it 'returns the status changed date' do
        subject.status_changed.should be_an_instance_of(DateTime)
      end

      it 'returns the reason for status change' do
        subject.status_reason.should == 'completed'
      end

      it 'is active' do
        subject.should be_active
      end
    end

    it 'returns the cancelable state' do
      subject.should be_cancelable
    end

    it 'returns the referrer' do
      subject.referrer.should == 'acme_app'
    end

    it 'returns the source name' do
      subject.source_name.should == 'acme_source'
    end

    it 'returns the source key' do
      subject.source_key.should == 'acme_source_key'
    end

    it 'returns the source campaign' do
      subject.source_campaign.should == 'acme_source_campaign'
    end

    it 'returns a customer' do
      subject.customer.should == customer
    end

    it 'returns the product name' do
      subject.product_name.should == 'Acme Inc Web'
    end

    it 'returns the next period date' do
      subject.next_period_date.should be_an_instance_of(Date)
    end

    it 'returns the end date' do
      subject.ends_on.should be_an_instance_of(Date)
    end
    
    it 'returns the tags as a symbolized hash' do
      subject.tags[:number1].should == "1"
      subject.tags[:number2].should == "2"
    end
  end

  context 'create subscriptions path' do
    it 'returns the path for creating a new subscription' do
      FastSpring::Subscription.create_subscription_url('tnt','acme_co').should == "http://sites.fastspring.com/acme/product/tnt?referrer=acme_co"
    end
  end

  context '#subscriptions_url' do
    it 'returns url for detail type' do
      FastSpring::Subscription.subscription_url(:detail, product: 'tnt').should == "http://sites.fastspring.com/acme/product/tnt"
      FastSpring::Subscription.subscription_url(:detail, product: 'tnt', referrer: 'acme_co').should == "http://sites.fastspring.com/acme/product/tnt?referrer=acme_co"
    end
    it 'returns url for order type' do
      FastSpring::Subscription.subscription_url(:order, product: 'tnt').should == "http://sites.fastspring.com/acme/product/tnt?action=order"
      FastSpring::Subscription.subscription_url(:order, product: 'tnt', referrer: 'acme_co').should == "http://sites.fastspring.com/acme/product/tnt?action=order&referrer=acme_co"
    end
    it 'returns url for instant type' do
      FastSpring::Subscription.subscription_url(:instant, product: 'tnt').should == "https://sites.fastspring.com/acme/instant/tnt?contact_fname=+&contact_lname=+"
      FastSpring::Subscription.subscription_url(:instant, product: 'tnt', referrer: 'acme_co', tags: 'tag1=10,tag2,tag3=30', contact_company: 'ABC Company', contact_phone: '123-4567890', contact_email: 'john+smith@abccompany.com', contact_fname: 'John').should == "https://sites.fastspring.com/acme/instant/tnt?contact_company=ABC+Company&contact_email=john%2Bsmith%40abccompany.com&contact_fname=John&contact_lname=+&contact_phone=123-4567890&referrer=acme_co&tags=tag1%3D10%2Ctag2%2Ctag3%3D30"
      FastSpring::Subscription.subscription_url(:instant, product: 'tnt', referrer: 'acme_co').should == "https://sites.fastspring.com/acme/instant/tnt?contact_fname=+&contact_lname=+&referrer=acme_co"
    end
    it 'returns url for add type' do
      FastSpring::Subscription.subscription_url(:add, product: 'tnt').should == "http://sites.fastspring.com/acme/product/tnt?action=add"
      FastSpring::Subscription.subscription_url(:add, product: 'tnt', referrer: 'acme_co').should == "http://sites.fastspring.com/acme/product/tnt?action=add&referrer=acme_co"
    end
    it 'returns url for adds type' do
      FastSpring::Subscription.subscription_url(:adds, product: 'tnt').should == "http://sites.fastspring.com/acme/product/tnt?action=adds"
      FastSpring::Subscription.subscription_url(:adds, product: 'tnt', referrer: 'acme_co').should == "http://sites.fastspring.com/acme/product/tnt?action=adds&referrer=acme_co"
    end
    it 'returns url for api type' do
      FastSpring::Subscription.subscription_url(:api).should == 'http://sites.fastspring.com/acme/api/order'
    end
    it 'returns url for instant type with empty values' do
      FastSpring::Subscription.subscription_url(:instant, product: 'tnt', referrer: 'acme_co', tags: nil, contact_company: '', contact_phone: 1234567890, contact_email: 'john+smith@abccompany.com', contact_fname: 'John').should == "https://sites.fastspring.com/acme/instant/tnt?contact_email=john%2Bsmith%40abccompany.com&contact_fname=John&contact_lname=+&contact_phone=1234567890&referrer=acme_co"
    end
    it 'returns url for detail type with empty values' do
      FastSpring::Subscription.subscription_url(:detail, product: 'tnt', referrer: '').should == "http://sites.fastspring.com/acme/product/tnt"
    end
    it 'raise error when product is missing for instant' do
      expect {
        FastSpring::Subscription.subscription_url(:instant, referrer: 'acme_co', contact_company: 'ABC Company')
      }.to raise_error(ArgumentError)
    end
    it 'raise error when product is missing for detail' do
      expect {
        FastSpring::Subscription.subscription_url(:detail, referrer: 'acme_co')
      }.to raise_error(ArgumentError)
    end
  end

  context 'renew' do
    subject { FastSpring::Subscription.find('test_ref') }
    before do
      stub_request(:get, "https://admin:test@api.fastspring.com/company/acme/subscription/test_ref").
        to_return(stub_http_response_with('basic_subscription.xml'))
    end

    it 'returns a renewal path' do
      subject.renew_path.should == "/company/acme/subscription/test_ref/renew"
    end
  end
end
