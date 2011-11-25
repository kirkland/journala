module Journala
  class Journal
    attr_accessor :entries

    def initialize
      @entries = []
    end

    def print
      sort_by_date

      @entries.each do |x|
        puts x
        puts "\n"
      end
      nil
    end

    def sort_by_date
      @entries = @entries.sort do |a,b|
        a.date <=> b.date
      end
    end

    def write_to_file(filename, overwrite=false)
      if File.exist?(filename) && !overwrite
        raise "File #{filename} already exists. Set second parameter to true to overwrite anyway"
      end

      sort_by_date

      f = File.open(filename, 'w')

      @entries.each do |e|
        f.puts(e)
        f.puts "\n"
      end

      f.close
    end

    # merge journal with another journal. when an identical transaction is found,
    # keep our own entry, and discard other_journal's entry.
    # the idea is that we read in an existing journal from a file, and then add
    # new entries only to it
    def merge(other_journal)
      puts "before merge: #{@entries.count} entries"
      other_journal.entries.each do |entry|
        transaction_id = entry.description.match(/\(transaction id: (\d+)\)/)[1]

        if @entries.none? {|e| e.description.match(/\(transaction id: \d+\)/) }
          @entries << entry
        end
      end
      puts "after merge: #{@entries.count} entries"
    end

    class << self
      def create_from_file(filename)
        file = File.open(filename, 'r')

        journal = Journal.new

        file.each_line do |line|
          if line =~ /^$/
            next
          elsif line =~ /^(\d\d\d\d\/\d\d\/\d\d)\s*(\*)*\s*(.*)/
            date = $1
            confirmed = $2
            description = $3
    
            entry = Entry.new(:date => date, :confirmed => confirmed.present?, :description => description)

            journal.entries << entry

          # row with amount
          elsif line =~ /\s+(.*)\s{2,}\$(.*)/
            row = Row.new(:account => $1, :amount => $2)
            journal.entries.last.rows << row

          # row without amount
          elsif line =~ /\s+(.*)/
            other_amount = journal.entries.last.rows.first.amount
            row = Row.new(:account => $1, :amount => 0-other_amount)
            journal.entries.last.rows << row
          end
    
        end

        f.close

        journal
      end
    end
  end
end
