module Journala
  class Row
    attr_accessor :account
    attr_reader :amount

    def initialize(attrs={})
      attrs.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def amount=(incoming_amount)
      @amount = Value.new(incoming_amount.to_s)
    end

    def valid?
      @account.present? && @amount.present?
    end

    def to_s
      spaces = ' ' * (70 - @account.length - @amount.length)
      "    #{@account}#{spaces}#{@amount}"
    end
  end
end
