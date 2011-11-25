module Journala
  class Entry
    attr_accessor :date, :description, :confirmed, :rows

    def initialize(attrs={})
      @rows = []
      attrs.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def <<(new_row)
      @rows << new_row
    end

    def to_s
      confirmed_str = @confirmed? " *" : ""
      %{#{@date}#{confirmed_str} #{@description}\n#{@rows.collect(&:to_s).join("\n")}}
    end
  end
end
