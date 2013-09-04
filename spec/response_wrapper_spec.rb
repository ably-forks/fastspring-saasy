require File.expand_path(File.join(File.dirname(__FILE__), '../lib/fastspring-saasy.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper.rb'))

describe FastSpring::ResponseWrapper do
  context 'successful case' do
    subject {
      response = double('MockResponse')
      response.stub(:success?) { true }
      response.stub(:code) { 201 }
      response.stub(:message) { 'Created' }
      response.stub(:body) { 'Object created successfully.' }
      response.stub(:headers) { {'location' => 'http://www.example.net/abcd/efgh'} }
      FastSpring::ResponseWrapper.new(response)
    }
    its(:success?) { should == true }
    its(:code) { should == 201 }
    its(:message) { should == 'Created' }
    its(:body) { should == 'Object created successfully.' }
    its(:location) { should == 'http://www.example.net/abcd/efgh' }
    its(:reference) { should == 'efgh' }
  end

  context 'failing case' do
    subject {
      response = double('MockResponse')
      response.stub(:success?) { false }
      response.stub(:code) { 422 }
      response.stub(:message) { 'Unprocessable entity' }
      response.stub(:body) { 'rebill-limit-exceeded' }
      response.stub(:headers) { {} }
      FastSpring::ResponseWrapper.new(response)
    }
    its(:success?) { should == false }
    its(:code) { should == 422 }
    its(:message) { should == 'Unprocessable entity' }
    its(:body) { should == 'rebill-limit-exceeded' }
    its(:location) { should == nil }
    its(:reference) { should == nil }
  end
end