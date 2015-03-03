require 'spec_helper'

describe Lorry::Routes::Documents do

  describe 'POST /documents' do

    context 'when params are valid' do
      let(:request_body) do
        {
            file: {
                file_name: "test.yaml",
                file_content: "this is a sample yaml file."
            }
        }
      end

      before do
        allow(Document).to receive(:to_gist).with(request_body[:file]).and_return('https://gist.github.com/1111')
      end

      it 'creates a new document' do
        expect(Document).to receive(:to_gist).with(request_body[:file]).exactly(:once)
        post '/documents', request_body.to_json
      end

      it 'returns the document url in Location header' do
        post '/documents', request_body.to_json
        expect(last_response.headers['Location']).to_not eql(nil)
      end

      it 'status to be 201' do
        post '/documents', request_body.to_json
        expect(last_response.status).to eql(201)
      end

    end

    context 'when params are invalid' do
      let(:request_body) do
        {
          file: {}
        }
      end

      before do
        allow(Document).to receive(:to_gist).with(request_body[:file]).and_raise(Octokit::UnprocessableEntity)
      end

      it 'status to be 422' do
        post '/documents', request_body.to_json
        expect(last_response.status).to eql(422)
      end

    end
  end

  describe 'GET /documents/:gist_id' do

    let(:response) do
    {
        filename: 'foo.yaml',
        id: '1111',
        content: 'blah blah',
        html_url: 'https://gist.github.com/1111'
    }
    end

    before do
      allow(Document).to receive(:from_gist_by_id).with('1111').and_return(response)
    end

    it 'gets the document' do
      expect(Document).to receive(:from_gist_by_id).with('1111').exactly(:once)
      get '/documents/1111'
    end

    it 'returns the document json' do
      get '/documents/1111'
      expect(last_response.body).to eql(response.to_json)
    end

    it 'status to be 200' do
      get '/documents/1111'
      expect(last_response.status).to eql(200)
    end

  end
end