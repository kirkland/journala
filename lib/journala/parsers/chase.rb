require 'hpricot'
require 'json'

module Journala
  module Parsers
    class Chase

      # for debugging. in normal usage you only need @journal, which is returned anyway
      attr_accessor :doc, :json, :data, :journal

      def self.parse(input_filename="Account Activity.html")
        @doc = open(input_filename) {|f| Hpricot(f) }

        # data is contained inside a script tag
        script = @doc.search("#chaseui-pagecontent").search("script")[0].inner_html

        @data = script.match(/activity = ({.*})/)[1]
        @json = JSON.parse(@data)

        @journal = Journal.new

        @json['Posted'].each do |raw_entry|
          entry = Entry.new

          m,d,y = raw_entry['tranDate'].split('/')
          entry.date = %{#{y}/#{m.rjust(2, '0')}/#{d.rjust(2, '0')}}

          m,d,y = raw_entry['postDate'].split('/')
          posted_date = %{#{y}/#{m.rjust(2, '0')}/#{d.rjust(2, '0')}}
          amount = raw_entry['amount'].gsub(/\$/, '')
          merchant = raw_entry['merchantName']
          trans_type = raw_entry['tranType']
          trans_id = raw_entry['tranId']

          entry.description = "#{merchant} (posted #{posted_date}) (transaction id: #{trans_id})"

          r1 = Row.new
          r1.account = 'Liabilities:Amazon/Chase CC'
          r1.amount = 0 - amount.to_f
          entry.rows << r1

          r2 = Row.new
          r2.account = trans_type == 'Payment' ? 'Assets:Current Assets:Central Bank' : 'Expenses:Uncategorized'
          r2.amount = 0 - r1.amount
          entry.rows << r2


          if !['Sale', 'Return', 'Payment'].include?(trans_type)
            raise "oh no found type: #{entry.type} ! what do i do?!"
          end

          @journal.entries << entry
        end

        @journal
      end
    end
  end
end
